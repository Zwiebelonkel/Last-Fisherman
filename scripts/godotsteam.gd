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

const MAX_LEADERBOARD_SCORE = 2147483647

func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	_init_steam()

func _process(_delta: float) -> void:
	if steam_ready:
		Steam.run_callbacks()

func _init_steam() -> void:
	print("🔧 Starte Steam Initialisierung...")
	
	if not Engine.has_singleton("Steam"):
		print("⚠️ Steam nicht verfügbar")
		initialization_complete = true
		leaderboards_loaded.emit()
		return
	
	OS.set_environment("SteamAppId", str(STEAM_APP_ID))
	OS.set_environment("SteamGameId", str(STEAM_APP_ID))
	
	var ok: bool = Steam.steamInit()
	if not ok:
		print("⚠️ Steam Init fehlgeschlagen")
		initialization_complete = true
		leaderboards_loaded.emit()
		return
	
	steam_id = int(Steam.getSteamID())
	steam_ready = bool(Steam.loggedOn())
	
	if not steam_ready:
		print("⚠️ Steam nicht eingeloggt")
		return
	
	print("✅ Steam bereit | ID:", steam_id)
	
	if not Steam.leaderboard_find_result.is_connected(_on_leaderboard_find):
		Steam.leaderboard_find_result.connect(_on_leaderboard_find)
	
	if not Steam.leaderboard_score_uploaded.is_connected(_on_score_uploaded):
		Steam.leaderboard_score_uploaded.connect(_on_score_uploaded)
	
	await get_tree().create_timer(1.0).timeout
	
	print("🔍 Suche Leaderboards...")
	Steam.findOrCreateLeaderboard("fish_total", Steam.LEADERBOARD_SORT_METHOD_DESCENDING, Steam.LEADERBOARD_DISPLAY_TYPE_NUMERIC)
	await get_tree().create_timer(0.5).timeout
	Steam.findOrCreateLeaderboard("money_total", Steam.LEADERBOARD_SORT_METHOD_DESCENDING, Steam.LEADERBOARD_DISPLAY_TYPE_NUMERIC)

func _on_leaderboard_find(handle: int, found: int) -> void:
	if handle <= 0:
		return
	
	var name := Steam.getLeaderboardName(handle)
	leaderboards[name] = handle
	leaderboards_ready += 1
	
	print("✅ Leaderboard:", name, "| Handle:", handle)
	
	if leaderboards_ready >= expected_leaderboards:
		initialization_complete = true
		print("✅ Alle Leaderboards bereit")
		leaderboards_loaded.emit()

func _on_score_uploaded(success: int, steam_leaderboard: int, score_details: Dictionary) -> void:
	if steam_leaderboard <= 0:
		return
	
	var leaderboard_name := Steam.getLeaderboardName(steam_leaderboard)
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
	
	Steam.uploadLeaderboardScore(
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
