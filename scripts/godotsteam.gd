extends Node

var STEAM_APP_ID: int = 4262030   # dein echtes AppID
var steam_initialized: bool = false

func _ready() -> void:
	_initialize_steam()

func _process(_delta: float) -> void:
	if steam_initialized:
		Steam.run_callbacks()
		_handle_achievement_test()

func _initialize_steam() -> void:
	# Steam App ID setzen (wichtig für Editor-Start)
	OS.set_environment("SteamAppId", str(STEAM_APP_ID))
	OS.set_environment("SteamGameId", str(STEAM_APP_ID))

	# Prüfen ob Plugin existiert
	if not Engine.has_singleton("Steam"):
		push_warning("❌ Steam Plugin nicht gefunden")
		return

	# 🔥 DEINE Version: steamInit() → bool
	var init_ok := Steam.steamInit()

	print("Did Steam initialize? ", init_ok)

	if not init_ok:
		push_warning("❌ Steam Initialisierung fehlgeschlagen (Steam läuft?)")
		return

	steam_initialized = true

	print("✅ Steam erfolgreich initialisiert")
	print("👤 User:", Steam.getPersonaName())
	print("🆔 SteamID:", Steam.getSteamID())
	
	# -------------------------------------------------
# ACHIEVEMENT TEST (wie im Screenshot)
# -------------------------------------------------
func _handle_achievement_test() -> void:
	# Taste 1 → Achievement setzen
	if Input.is_key_pressed(KEY_1):
		Steam.setAchievement("TEST")
		Steam.storeStats()
		print("🏆 Achievement gesetzt")

	# Taste 2 → Achievement zurücksetzen
	if Input.is_key_pressed(KEY_2):
		Steam.clearAchievement("TEST")
		Steam.storeStats()
		print("🧹 Achievement gelöscht")
