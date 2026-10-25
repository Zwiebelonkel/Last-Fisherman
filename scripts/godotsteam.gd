extends Node

const STEAM_APP_ID: int = 4262030

var steam_ready: bool = false
var steam_id: int = 0

var leaderboards: Dictionary = {}
var expected_leaderboards: int = 2
var leaderboards_ready: int = 0

var cached_scores: Dictionary = {
	"fish_total": 0,
	"money_total": 0
}

var initialization_complete: bool = false
signal leaderboards_loaded

const LEADERBOARD_NAMES := ["fish_total", "money_total"]
const FIND_TIMEOUT_MSEC := 8000
const MAX_FIND_ATTEMPTS := 3
var steam_api: Object
var _steam_initialized := false
var _find_queue: Array[String] = []
var _finding := ""
var _find_attempts: Dictionary = {}
var _find_started_at: int = 0
var _next_connection_check: int = 0
var _find_next_scheduled := false

const MAX_LEADERBOARD_SCORE = 2147483647

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	steam_api = Engine.get_singleton("Steam") if Engine.has_singleton("Steam") else null
	await get_tree().create_timer(0.5).timeout
	_init_steam()

func _process(_delta: float) -> void:
	if not _steam_initialized:
		return
	steam_api.run_callbacks()
	var now := Time.get_ticks_msec()
	if now >= _next_connection_check:
		_next_connection_check = now + 1000
		var connected: bool = steam_api.loggedOn()
		if connected != steam_ready:
			steam_ready = connected
			if connected:
				ensure_leaderboards()
			else:
				_finding = ""
				_find_queue.clear()
				initialization_complete = true
				leaderboards_loaded.emit()
	if steam_ready and not _finding.is_empty() and now - _find_started_at >= FIND_TIMEOUT_MSEC:
		_finish_find(false)

func _init_steam() -> void:
	print("🔧 Starte Steam Initialisierung...")
	
	if steam_api == null:
		print("⚠️ Steam nicht verfügbar")
		initialization_complete = true
		leaderboards_loaded.emit()
		return
	
	OS.set_environment("SteamAppId", str(STEAM_APP_ID))
	OS.set_environment("SteamGameId", str(STEAM_APP_ID))
	
	var ok: bool = steam_api.steamInit()
	if not ok:
		print("⚠️ Steam Init fehlgeschlagen")
		initialization_complete = true
		leaderboards_loaded.emit()
		return
	
	_steam_initialized = true
	steam_id = int(steam_api.getSteamID())
	steam_ready = bool(steam_api.loggedOn())
	if not steam_api.leaderboard_find_result.is_connected(_on_leaderboard_find):
		steam_api.leaderboard_find_result.connect(_on_leaderboard_find)
	if not steam_api.leaderboard_score_uploaded.is_connected(_on_score_uploaded):
		steam_api.leaderboard_score_uploaded.connect(_on_score_uploaded)
	
	if not steam_ready:
		print("⚠️ Steam nicht eingeloggt")
		initialization_complete = true
		leaderboards_loaded.emit()
		return
	
	print("✅ Steam bereit | ID:", steam_id)
	
	ensure_leaderboards()

func ensure_leaderboards() -> void:
	if not steam_ready or not _finding.is_empty() or not _find_queue.is_empty() or _find_next_scheduled:
		return
	for name: String in LEADERBOARD_NAMES:
		if int(leaderboards.get(name, 0)) <= 0:
			_find_queue.append(name)
			_find_attempts[name] = 0
	initialization_complete = false
	_start_next_find()

func _start_next_find() -> void:
	_find_next_scheduled = false
	if not steam_ready or not _finding.is_empty():
		return
	if _find_queue.is_empty():
		leaderboards_ready = leaderboards.size()
		initialization_complete = true
		leaderboards_loaded.emit()
		return
	_finding = _find_queue.pop_front()
	_find_attempts[_finding] = int(_find_attempts.get(_finding, 0)) + 1
	_find_started_at = Time.get_ticks_msec()
	steam_api.findOrCreateLeaderboard(_finding, Steam.LEADERBOARD_SORT_METHOD_DESCENDING, Steam.LEADERBOARD_DISPLAY_TYPE_NUMERIC)

func _finish_find(success: bool) -> void:
	var name := _finding
	_finding = ""
	if not success and int(_find_attempts.get(name, 0)) < MAX_FIND_ATTEMPTS:
		_find_queue.append(name)
	# Start the next call after the current Steam callback has returned.
	_find_next_scheduled = true
	_start_next_find.call_deferred()

func _on_leaderboard_find(handle: int, found: int) -> void:
	if _finding.is_empty():
		return
	if found != 1 or handle <= 0:
		_finish_find(false)
		return
	var name: String = steam_api.getLeaderboardName(handle)
	if name != _finding:
		return
	leaderboards[name] = handle
	leaderboards_ready = leaderboards.size()
	
	print("✅ Leaderboard:", name, "| Handle:", handle)
	
	_finish_find(true)

func _on_score_uploaded(success: int, steam_leaderboard: int, score_details: Dictionary) -> void:
	if steam_leaderboard <= 0:
		return
	
	var leaderboard_name: String = steam_api.getLeaderboardName(steam_leaderboard)
	var score = score_details.get("score", 0)
	var score_changed = score_details.get("score_changed", 0)
	var global_rank = score_details.get("global_rank_new", 0)
	
	if success == 1:
		if score_changed == 1:
			print("✅", leaderboard_name, "hochgeladen:", score, "| Rang:", global_rank)
		else:
			print("ℹ️", leaderboard_name, ":", score, "(nicht besser als vorheriger)")
	else:
		print("❌", leaderboard_name, "Upload fehlgeschlagen")

func update_fish(total_fish: int) -> void:
	cached_scores["fish_total"] = mini(total_fish, MAX_LEADERBOARD_SCORE)
	print("💾 Fish:", cached_scores["fish_total"])

func update_money(total_money: int) -> void:
	cached_scores["money_total"] = mini(total_money, MAX_LEADERBOARD_SCORE)
	print("💾 Money:", cached_scores["money_total"])

func flush_scores() -> void:
	if not steam_ready or not initialization_complete:
		return
	
	print("📤 Flush Scores:", cached_scores)
	_upload_score("fish_total", cached_scores["fish_total"])
	_upload_score("money_total", cached_scores["money_total"])

func _upload_score(name: String, score: int) -> void:
	if not leaderboards.has(name) or leaderboards[name] <= 0:
		return
	
	if score < 0 or score > MAX_LEADERBOARD_SCORE:
		print("❌", name, "Score ungültig:", score)
		return
	
	var handle: int = leaderboards[name]
	print("📤 Upload:", name, "→", score)
	
	steam_api.uploadLeaderboardScore(
		score,                     # 1️⃣ SCORE
		true,                      # 2️⃣ keep_best
		PackedInt32Array(),        # 3️⃣ Details (leer)
		handle                     # 4️⃣ Leaderboard Handle
	)


func _exit_tree() -> void:
	if steam_ready:
		flush_scores()
		await get_tree().create_timer(0.5).timeout
		Steam.steamShutdown()
