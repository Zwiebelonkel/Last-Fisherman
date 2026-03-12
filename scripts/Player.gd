extends Node

signal biome_completed(biome_name: String, reward: int)
signal fish_caught(fish_id: String)
signal money_gained(amount: int)
signal vendor_unlocked  # 🆕 Neues Signal
signal biome_progress(biome_name: String, percent: int)

var touch_buttons: Node = null

# --- PLAYER DATA ---
var money: int = 0
var level: int = 1
var xp: int = 0
var upgrade_grip: int = 1
var upgrade_bait: int = 1
var upgrade_line: int = 1
var last_scene: String = "res://scenes/MainScene.tscn"
var options: String = "res://scenes/OptionsControl.tscn"
var caught_fish_species: Dictionary = {}  # ✅ Speichert fish_id: bool
var used_story_items: Array = []
var tutorial_seen: bool = false  # 🆕 Tutorial wurde angesehen
var visited_biomes: Dictionary = {}

# 🆕 Story Items für Vendor Unlock
const REQUIRED_STORY_ITEMS = ["van", "opensign", "friteuse", "sushimesser"]

# --- SETTINGS ---
var master_volume: float = 1.0
var music_volume: float = 1.0
var sfx_volume: float = 1.0
var resolution_scale: float = 1.0
var frame_limit: int = 0
var fullscreen: bool = false
var current_language: String = "de"

# Gewichtsrekorde pro Fischart (✅ fish_id als Key)
var fish_weight_records: Dictionary = {}
var fish_catch_count: Dictionary = {}  # ✅ fish_id als Key

const BIOME_COLORS = {
	"lake":    Color(0.99, 0.55, 0.27),
	"city":    Color(0.0, 0.80, 1.0),
	"sewer":   Color(0.12, 0.80, 0.61),
	"forest":  Color(0.12, 0.61, 0.54),
	"desert":  Color(0.96, 0.88, 0.54),
	"iceland": Color(0.55, 1.0, 1.0),
	"ocean":   Color(0.55, 0.16, 1.0),
}

# Biom-Completion Tracking
var completed_biomes: Dictionary = {
	"lake": false, "city": false, "sewer": false,
	"forest": false, "desert": false, "iceland": false, "ocean": false
}

var unlocked_spots = {
	"lake": true, "city": false, "sewer": false,
	"forest": false, "desert": false, "iceland": false, "home": true, "ocean": false, "van": false  # 🔧 van startet locked
}

var spot_prices = {
	"lake": 0, "city": 500, "sewer": 1200,
	"forest": 2000, "desert": 4000, "iceland": 6000, "home": 0,"ocean": 0, "van": 0  # 🔧 van kostet 0 (wird durch Items freigeschaltet)
}

# Köder-Inventar
var bait_inventory: Dictionary = {
	"Common": 0,"Uncommon": 0, "Rare": 0, "Epic": 0, "Legendary": 0, "Exotic": 0
}

var active_bait: String = ""

const BAIT_PRICES = {
	"Common": 50,"Uncommon": 150, "Rare": 400, "Epic": 900, "Legendary": 2000, "Exotic": 4500
}

func buy_bait(rarity: String, amount: int = 1) -> bool:
	var total_cost = BAIT_PRICES[rarity] * amount
	if remove_money(total_cost):
		bait_inventory[rarity] += amount
		save_game()
		return true
	return false

func activate_bait(rarity: String) -> bool:
	if bait_inventory[rarity] > 0:
		active_bait = rarity
		bait_inventory[rarity] -= 1
		save_game()
		return true
	return false
	
	
const RARITY_TO_BAIT_KEY = {
	0: "Common",     # RARITY.NORMAL
	1: "Uncommon",   # RARITY.UNGEWOEHNLICH
	2: "Rare",       # RARITY.SELTEN
	3: "Epic",       # RARITY.EPISCH
	4: "Legendary",  # RARITY.LEGENDAER
	5: "Exotic",     # RARITY.EXOTISCH
	6: "Common"      # RARITY.ANTIK → fallback auf Common
}
# 🆕 Fisch direkt in Köder seiner Rarity umwandeln und equippen
func use_fish_as_bait(fish_data: Dictionary, inventory_index: int) -> bool:
	var rarity_enum: int = fish_data.get("rarity", FishDB.RARITY.NORMAL)
	
	# Enum → Bait-Key
	var rarity_string: String = RARITY_TO_BAIT_KEY.get(rarity_enum, "Common")
	
	if not bait_inventory.has(rarity_string):
		push_error("❌ use_fish_as_bait: Unbekannter Bait-Key: " + rarity_string)
		return false
	
	# Falls bereits ein Köder aktiv ist, zurück ins Inventar
	if active_bait != "":
		bait_inventory[active_bait] += 1
		print("🔄 Aktiver Köder '%s' zurückgelegt" % active_bait)
	
	# Fisch aus Inventar entfernen
	Inventory.remove_fish(inventory_index)
	
	# Direkt equippen
	active_bait = rarity_string
	
	print("🎣 Fisch [Rarity %d] → Köder: %s (equipped)" % [rarity_enum, rarity_string])
	save_game()
	return true
func deactivate_bait() -> void:
	if active_bait != "":
		bait_inventory[active_bait] += 1
		active_bait = ""
		save_game()

func consume_active_bait() -> void:
	if active_bait != "":
		active_bait = ""
		save_game()

func has_active_bait() -> bool:
	return active_bait != ""

func get_active_bait_rarity() -> String:
	return active_bait

func _ready():
	load_game()
	load_settings()
	TranslationServer.set_locale(current_language)
	
	# 🔧 OPTIMIERT: Warte auf Signal statt fixer Zeit
	if not GodotSteam.leaderboards_loaded.is_connected(_sync_steam_scores):
		GodotSteam.leaderboards_loaded.connect(_sync_steam_scores)
	
	# Falls Steam schon bereit ist
	if GodotSteam.initialization_complete:
		_sync_steam_scores()

# 🔧 OPTIMIERT: Direkt ohne Check (wird in GodotSteam gemacht)
func _sync_steam_scores() -> void:
	GodotSteam.update_fish(get_total_fish_caught())
	GodotSteam.update_money(money)

# 🆕 Prüfe ob Vendor freigeschaltet werden soll
func check_vendor_unlock() -> void:
	# Prüfe ob bereits freigeschaltet
	if unlocked_spots["van"]:
		print("ℹ️ Vendor bereits freigeschaltet")
		return
	
	# Prüfe ob alle Items gefunden wurden
	var all_found = true
	for item_id in REQUIRED_STORY_ITEMS:
		if not used_story_items.has(item_id):
			all_found = false
			break
	
	if all_found:
		unlock_vendor()

# 🆕 Schalte Vendor frei
func unlock_vendor() -> void:
	print("🎉 VENDOR FREIGESCHALTET!")
	unlocked_spots["van"] = true
	save_game()
	
	# Zeige Benachrichtigung
	show_vendor_unlock_notification()
	
	# Emittiere Signal
	emit_signal("vendor_unlocked")

# 🆕 Zeige Unlock-Benachrichtigung
func show_vendor_unlock_notification() -> void:
	# Erstelle eine temporäre Notification
	# Du kannst hier dein eigenes UI verwenden
	print("════════════════════════════════════")
	print("    🎊 IMBISS FREIGESCHALTET! 🎊    ")
	print("  Alle Teile gefunden! Besuche den  ")
	print("     Imbiss auf der Weltkarte!      ")
	print("════════════════════════════════════")

# 🆕 Prüfe Story Item Status
func get_story_item_progress() -> Dictionary:
	return {
		"found": used_story_items.size(),
		"total": REQUIRED_STORY_ITEMS.size(),
		"items": {
			"van": used_story_items.has("van"),
			"opensign": used_story_items.has("opensign"),
			"friteuse": used_story_items.has("friteuse"),
			"sushimesser": used_story_items.has("sushimesser")
		}
	}

func save_settings() -> void:
	var settings_data = {
		"master_volume": master_volume,
		"music_volume": music_volume,
		"sfx_volume": sfx_volume,
		"resolution_scale": resolution_scale,
		"frame_limit": frame_limit,
		"fullscreen": fullscreen,
		"language": current_language
	}
	var file = FileAccess.open("user://settings.dat", FileAccess.WRITE)
	file.store_var(settings_data)

func load_settings() -> void:
	if FileAccess.file_exists("user://settings.dat"):
		var file = FileAccess.open("user://settings.dat", FileAccess.READ)
		var settings_data = file.get_var()
		master_volume = settings_data.get("master_volume", 1.0)
		music_volume = settings_data.get("music_volume", 1.0)
		sfx_volume = settings_data.get("sfx_volume", 1.0)
		resolution_scale = settings_data.get("resolution_scale", 1.0)
		frame_limit = settings_data.get("frame_limit", 0)
		fullscreen = settings_data.get("fullscreen", false)
		current_language = settings_data.get("language", "de")
		
		apply_settings()
		TranslationServer.set_locale(current_language)
	else:
		current_language = "de"
		TranslationServer.set_locale("de")

func apply_settings() -> void:
	var master_bus = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(master_volume))
	
	var music_bus = AudioServer.get_bus_index("Music")
	if music_bus != -1:
		AudioServer.set_bus_volume_db(music_bus, linear_to_db(music_volume))
	
	var sfx_bus = AudioServer.get_bus_index("SFX")
	if sfx_bus != -1:
		AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(sfx_volume))
	
	get_tree().root.scaling_3d_scale = resolution_scale
	
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	Engine.max_fps = frame_limit

func set_touch_buttons_visible(visible: bool) -> void:
	if touch_buttons:
		touch_buttons.visible = visible

func add_money(amount: int) -> void:
	if amount <= 0:
		return

	money += amount
	GodotSteam.update_money(money)
	print("Added: " + str(amount) + " money")
	save_game()

	emit_signal("money_gained", amount)

func remove_money(amount: int) -> bool:
	if money >= amount:
		money -= amount
		GodotSteam.update_money(money)
		save_game()
		return true
	return false

func set_money(amount: int) -> void:
	money = amount
	GodotSteam.update_money(money)
	save_game()

func get_money() -> int:
	return money

func add_xp(amount: int) -> void:
	xp += amount
	save_game()

func update_last_scene(scene_path: String) -> void:
	last_scene = scene_path
	save_game()

func go_to_last_scene() -> void:
	Transition.change_scene_reverse(last_scene, 0.5)

# ✅ Bereits korrekt: Nutzt fish_data["id"]
func add_fish(fish_data: Dictionary, biome: String = "") -> void:
	Inventory.add_fish(fish_data)
	
	if not fish_data.has("id"):
		push_error("❌ add_fish: Fish ohne ID!")
		return
	
	var fish_id: String = fish_data["id"]
	update_catch_count(fish_id)
	GodotSteam.update_fish(get_total_fish_caught())
	
	if fish_data.has("weight"):
		update_weight_record(fish_id, fish_data["weight"])
	
	if not caught_fish_species.has(fish_id):
		caught_fish_species[fish_id] = true
		emit_signal("fish_caught", fish_id)
	
	check_biome_progress(biome)  # ← direkt übergeben
	save_game()
# ✅ Bereits korrekt: fish_id als Parameter
func update_weight_record(fish_id: String, weight: float) -> void:
	if not fish_weight_records.has(fish_id) or weight > fish_weight_records.get(fish_id, 0.0):
		fish_weight_records[fish_id] = weight

# ✅ Bereits korrekt: fish_id als Parameter
func get_max_caught_weight(fish_id: String) -> float:
	return fish_weight_records.get(fish_id, 0.0)

# ✅ Bereits korrekt: fish_id als Parameter
func update_catch_count(fish_id: String) -> void:
	fish_catch_count[fish_id] = fish_catch_count.get(fish_id, 0) + 1

# ✅ Bereits korrekt: fish_id als Parameter
func get_catch_count(fish_id: String) -> int:
	return fish_catch_count.get(fish_id, 0)

# ✅ Bereits korrekt: Nutzt fish["id"]
func check_biome_completion(fish_data: Dictionary) -> void:
	var biome = fish_data.get("biome", "")
	if biome == "" or completed_biomes[biome]:
		return
	
	var biome_fish = get_biome_fish_list(biome)
	if biome_fish.is_empty():
		return
	
	for fish in biome_fish:
		if not caught_fish_species.has(fish["id"]):
			return
	
	trigger_biome_completion_event(biome)
	
func check_biome_progress(biome: String) -> void:
	var biome_fish = get_biome_fish_list(biome)
	if biome_fish.is_empty():
		return

	var caught := 0
	for fish in biome_fish:
		if caught_fish_species.has(fish["id"]):
			caught += 1

	var percent := float(caught) / float(biome_fish.size())

	# 50%
	if percent >= 0.5 and not completed_biomes.get(biome + "_half", false):
		completed_biomes[biome + "_half"] = true
		emit_signal("biome_progress", biome, 50)

	# 100%
# 100%
	if percent >= 1.0 and not completed_biomes.get(biome + "_full", false):
		completed_biomes[biome + "_full"] = true
		emit_signal("biome_progress", biome, 100)

func get_biome_fish_list(biome: String) -> Array:
	match biome:
		"lake": return FishDB.FISH_LAKE
		"city": return FishDB.FISH_CITY
		"sewer": return FishDB.FISH_SEWER
		"forest": return FishDB.FISH_FOREST
		"desert": return FishDB.FISH_DESERT
		"iceland": return FishDB.FISH_ICELAND
		"ocean": return FishDB.FISH_OCEAN

		_: return []

func trigger_biome_completion_event(biome: String) -> void:
	completed_biomes[biome] = true
	save_game()
	
	var rewards = {
		"lake": 500, "city": 1000, "sewer": 1500,
		"forest": 2000, "desert": 3000, "iceland": 4000, "ocean":10000
	}
	
	var reward = rewards.get(biome, 0)
	if reward > 0:
		add_money(reward)
	
	SteamAchievements.on_biome_completed(biome)
	emit_signal("biome_completed", biome, reward)

func _add_all_fish() -> void:
	for fish in FishDB.FISH_LAKE:
		add_fish(fish)
	for fish in FishDB.FISH_CITY:
		add_fish(fish)
	for fish in FishDB.FISH_FOREST:
		add_fish(fish)
	for fish in FishDB.FISH_SEWER:
		add_fish(fish)
	for fish in FishDB.FISH_DESERT:
		add_fish(fish)
	for fish in FishDB.FISH_ICELAND:
		add_fish(fish)
	for fish in FishDB.FISH_OCEAN:
		add_fish(fish)

func clear_inventory():
	Inventory.clear_inventory()
	save_game()

func get_inventory_value() -> int:
	return Inventory.get_total_value()

func save_game() -> void:
	var save_data = {
		"money": money,
		"level": level,
		"xp": xp,
		"upgrade_grip": upgrade_grip,
		"upgrade_bait": upgrade_bait,
		"upgrade_line": upgrade_line,
		"last_scene": last_scene,
		"unlocked_spots": unlocked_spots,
		"caught_fish_species": caught_fish_species,
		"completed_biomes": completed_biomes,
		"fish_weight_records": fish_weight_records,
		"fish_catch_count": fish_catch_count,
		"used_story_items": used_story_items,
		"bait_inventory": bait_inventory,
		"active_bait": active_bait,
		"tutorial_seen": tutorial_seen,
		"visited_biomes": visited_biomes,
	}
	
	var file = FileAccess.open("user://savegame.dat", FileAccess.WRITE)
	file.store_var(save_data)
	
	# 🆕 LoreManager speichert separat
	LoreManager.save_data()
	
func load_game() -> void:
	if FileAccess.file_exists("user://savegame.dat"):
		var file = FileAccess.open("user://savegame.dat", FileAccess.READ)
		var save_data = file.get_var()
		money = save_data.get("money", 0)
		level = save_data.get("level", 1)
		xp = save_data.get("xp", 0)
		upgrade_grip = save_data.get("upgrade_grip", 1)
		upgrade_bait = save_data.get("upgrade_bait", 1)
		upgrade_line = save_data.get("upgrade_line", 1)
		last_scene = save_data.get("last_scene", "res://scenes/MainScene.tscn")
		unlocked_spots = save_data.get("unlocked_spots", unlocked_spots)
		caught_fish_species = save_data.get("caught_fish_species", {})
		completed_biomes = save_data.get("completed_biomes", completed_biomes)
		fish_weight_records = save_data.get("fish_weight_records", {})
		fish_catch_count = save_data.get("fish_catch_count", {})
		used_story_items = save_data.get("used_story_items", [])
		bait_inventory = save_data.get("bait_inventory", bait_inventory)
		active_bait = save_data.get("active_bait", "")
		tutorial_seen = save_data.get("tutorial_seen", false)  # 🆕 Tutorial-Status laden
		visited_biomes = save_data.get("visited_biomes", {})

func reset() -> void:
	money = 0
	level = 1
	xp = 0
	upgrade_grip = 1
	upgrade_bait = 1
	upgrade_line = 1
	last_scene = "res://scenes/MainScene.tscn"
	Inventory.clear_inventory()
	caught_fish_species.clear()
	fish_weight_records.clear()
	fish_catch_count.clear()
	used_story_items.clear()
	completed_biomes = {
		"lake": false, "city": false, "sewer": false,
		"forest": false, "desert": false, "iceland": false, "ocean": false
	}
	unlocked_spots = {
		"lake": true, "city": false, "sewer": false,
		"forest": false, "desert": false, "iceland": false,
		"home": true, "ocean": true, "van": false
	}
	bait_inventory = {
		"Common": 0, "Uncommon": 0, "Rare": 0,
		"Epic": 0, "Legendary": 0, "Exotic": 0
	}
	active_bait = ""
	tutorial_seen = false
	visited_biomes.clear()
	
	# 🆕 Reset Lore
	LoreManager.reset()
	
	GodotSteam.update_fish(0)
	GodotSteam.update_money(0)
	save_game()
	GodotSteam.flush_scores()
func get_total_fish_caught() -> int:
	var total := 0
	for v in fish_catch_count.values():
		total += v
	return total
	
func has_visited_biome(biome: String) -> bool:
	return visited_biomes.get(biome, false)

func mark_biome_visited(biome: String) -> void:
	visited_biomes[biome] = true
	save_game()
