extends Node

const STEAM_APP_ID: int = 4262030

var steam_ready: bool = false
var steam_id: int = 0

# Leaderboard handles
var leaderboards: Dictionary = {}

# 🆕 Lokaler Cache für Scores
var cached_scores: Dictionary = {
	"fishcaught": 0,
	"moneyearned": 0
}

# 🆕 Dirty Flags - zeigt an ob Upload nötig ist
var needs_upload: Dictionary = {
	"fishcaught": false,
	"moneyearned": false
}

# Verhindert Crash beim Start
var initialization_complete: bool = false

func _ready() -> void:
	# Verzögere Init um Crash zu vermeiden
	await get_tree().create_timer(0.5).timeout
	_init_steam()

func _process(_delta: float) -> void:
	if steam_ready and initialization_complete:
		Steam.run_callbacks()

func _init_steam() -> void:
	print("🔧 Starte Steam Initialisierung...")
	
	# Check singleton
	if not Engine.has_singleton("Steam"):
		print("⚠️ Steam nicht verfügbar (Editor Modus)")
		initialization_complete = true
		return
	
	# Set environment variables
	OS.set_environment("SteamAppId", str(STEAM_APP_ID))
	OS.set_environment("SteamGameId", str(STEAM_APP_ID))
	
	# Initialize Steam
	var ok: bool = Steam.steamInit()
	if not ok:
		print("⚠️ Steam Init fehlgeschlagen")
		initialization_complete = true
		return
	
	# Get Steam ID
	steam_id = int(Steam.getSteamID())
	steam_ready = bool(Steam.loggedOn())
	
	if not steam_ready:
		print("⚠️ Steam nicht eingeloggt")
		initialization_complete = true
		return
	
	print("✅ Steam bereit | ID:", steam_id)
	print("✅ Steam Username:", Steam.getPersonaName())
	
	# Connect signals
	if not Steam.leaderboard_find_result.is_connected(_on_leaderboard_find):
		Steam.leaderboard_find_result.connect(_on_leaderboard_find)
	
	if not Steam.leaderboard_score_uploaded.is_connected(_on_score_uploaded):
		Steam.leaderboard_score_uploaded.connect(_on_score_uploaded)
	
	# Warte vor Leaderboard-Suche
	await get_tree().create_timer(1.0).timeout
	
	print("🔍 Suche Leaderboards...")
	Steam.findLeaderboard("fishcaught")
	await get_tree().create_timer(0.5).timeout
	Steam.findLeaderboard("moneyearned")
	
	initialization_complete = true
	print("✅ Steam Initialisierung abgeschlossen")

func _on_leaderboard_find(handle: int, found: int) -> void:
	if found == 0:
		print("⚠️ Leaderboard nicht gefunden - bitte im Dashboard erstellen")
		return
	
	var name: String = str(Steam.getLeaderboardName(handle))
	leaderboards[name] = handle
	print("✅ Leaderboard bereit:", name)

func _on_score_uploaded(success: int, handle: int, score: Dictionary) -> void:
	var name: String = str(Steam.getLeaderboardName(handle))
	
	if success == 1:
		print("✅ Score hochgeladen:", name, "→", score.get("score", "?"))
	else:
		print("ℹ️ Score Upload Info:", name, "(evtl. nicht besser)")

# -----------------------------
# PUBLIC API - LOKALES CACHING
# -----------------------------

func update_fish(total_fish: int) -> void:
	# 🆕 Nur lokal cachen, NICHT sofort uploaden
	if cached_scores["fishcaught"] != total_fish:
		cached_scores["fishcaught"] = total_fish
		needs_upload["fishcaught"] = true
		print("💾 Fish Score gecached:", total_fish)

func update_money(money: int) -> void:
	# 🆕 Nur lokal cachen, NICHT sofort uploaden
	if cached_scores["moneyearned"] != money:
		cached_scores["moneyearned"] = money
		needs_upload["moneyearned"] = true
		print("💾 Money Score gecached:", money)

# 🆕 Manueller Upload - wird beim Szenenwechsel aufgerufen
func flush_scores() -> void:
	if not steam_ready or not initialization_complete:
		return
	
	print("📤 Flush Scores zu Steam...")
	
	for leaderboard_name in needs_upload.keys():
		if needs_upload[leaderboard_name]:
			_upload_score(leaderboard_name, cached_scores[leaderboard_name])
			needs_upload[leaderboard_name] = false

func _upload_score(name: String, score: int) -> void:
	if not leaderboards.has(name):
		print("⚠️ Leaderboard nicht gefunden:", name)
		return
	
	var handle: int = int(leaderboards[name])
	if handle == 0:
		return
	
	print("📤 Upload Score:", name, "→", score)
	
	Steam.uploadLeaderboardScore(
		handle,
		Steam.LEADERBOARD_UPLOAD_SCORE_METHOD_KEEP_BEST,
		PackedInt32Array([score]),
		0
	)

# 🆕 Upload bei bestimmten Events
func upload_on_milestone() -> void:
	# Z.B. wenn Biom komplett ist, Achievement unlocked, etc.
	flush_scores()

# Graceful shutdown - uploaded beim Beenden
func _exit_tree() -> void:
	if steam_ready:
		flush_scores()
		# Warte kurz damit Upload durchgeht
		await get_tree().create_timer(0.5).timeout
		Steam.steamShutdown()
