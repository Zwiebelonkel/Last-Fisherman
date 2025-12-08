extends Node

# 🆕 Signal für UI-Benachrichtigungen
signal biome_completed(biome_name: String, reward: int)
signal fish_caught(fish_name: String)  # 🆕 NEU für Aquarium


# 🆕 Touch-Button Referenz
var touch_buttons: Node = null

# --- PLAYER DATA ---
var money: int = 0
var level: int = 1
var xp: int = 0
var upgrade_grip: int = 1
var upgrade_bait: int = 1
var upgrade_line: int = 1
var last_scene: String = "res://scenes/MainScene.tscn"
var options: String = "res://scenes/OptionsCOntrol.tscn"
var fish_inventory: Array = []
var caught_fish_species: Dictionary = {}
var used_story_items: Array = []

# --- SETTINGS ---
var master_volume: float = 1.0
var music_volume: float = 1.0
var sfx_volume: float = 1.0
var resolution_scale: float = 1.0
var frame_limit: int = 0
var fullscreen: bool = false


# 🆕 Gewichtsrekorde pro Fischart
var fish_weight_records: Dictionary = {}  # {"Fischname": max_weight}

# 🆕 Anzahl gefangener Fische pro Art
var fish_catch_count: Dictionary = {}  # {"Fischname": count}

# 🆕 Biom-Completion Tracking
var completed_biomes: Dictionary = {
	"lake": false,
	"city": false,
	"sewer": false,
	"forest": false,
	"desert": false,
	"iceland": false,
}

var unlocked_spots = {
	"lake": true,
	"city": false,
	"sewer": false,
	"forest": false,
	"desert": false,
	"iceland": false,
	"home": true,

}

var spot_prices = {
	"lake": 0,
	"city": 500,
	"sewer": 1200,
	"forest": 2000,
	"desert": 4000,
	"iceland": 6000,
	"home": 0,
}

func _ready():
	load_game()
	load_settings()

func save_settings() -> void:
	var settings_data = {
		"master_volume": master_volume,
		"music_volume": music_volume,
		"sfx_volume": sfx_volume,
		"resolution_scale": resolution_scale,
		"frame_limit": frame_limit,
		"fullscreen": fullscreen
	}
	var file = FileAccess.open("user://settings.dat", FileAccess.WRITE)
	file.store_var(settings_data)
	print("Einstellungen gespeichert!")

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
		
		# Wende Einstellungen an
		apply_settings()
		print("Einstellungen geladen!")
	else:
		print("Keine Einstellungen gefunden, verwende Standardwerte")

func apply_settings() -> void:
	# Audio
	var master_bus = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(master_volume))
	
	var music_bus = AudioServer.get_bus_index("Music")
	if music_bus != -1:
		AudioServer.set_bus_volume_db(music_bus, linear_to_db(music_volume))
	
	var sfx_bus = AudioServer.get_bus_index("SFX")
	if sfx_bus != -1:
		AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(sfx_volume))
	
	# 3D Resolution Scale
	get_tree().root.scaling_3d_scale = resolution_scale
	
	# Fullscreen
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

	# 🆕 Frame-Limit anwenden
	Engine.max_fps = frame_limit



# 🆕 Touch-Button Sichtbarkeit steuern
func set_touch_buttons_visible(visible: bool) -> void:
	if touch_buttons:
		touch_buttons.visible = visible
		print("Touch-Buttons Sichtbarkeit:", visible)

func add_money(amount: int) -> void:
	money += amount
	print("Geld hinzugefügt:", amount, " → Neues Guthaben:", money)
	save_game()

func remove_money(amount: int) -> bool:
	if money >= amount:
		money -= amount
		print("Geld ausgegeben:", amount, " → Neues Guthaben:", money)
		save_game()
		return true
	return false

func set_money(amount: int) -> void:
	money = amount
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

func add_fish(fish_data: Dictionary) -> void:
	Inventory.add_fish(fish_data)
	print("Fisch ins Inventar hinzugefügt:", fish_data)
	
	# Gewichtsrekord aktualisieren
	if fish_data.has("weight"):
		update_weight_record(fish_data["name"], fish_data["weight"])
	
	# Fangzähler erhöhen
	update_catch_count(fish_data["name"])
	
	# Fisch ins Fischbuch eintragen
	var is_new_fish = false
	if not caught_fish_species.has(fish_data["name"]):
		caught_fish_species[fish_data["name"]] = true
		is_new_fish = true
		print("🐟 Neue Fischart entdeckt:", fish_data["name"])
		
		# 🆕 Signal für Aquarium emittieren (nur bei neuen Fischen!)
		emit_signal("fish_caught", fish_data["name"])
	
	save_game()
# 🆕 Gewichtsrekord aktualisieren
func update_weight_record(fish_name: String, weight: float) -> void:
	if not fish_weight_records.has(fish_name):
		fish_weight_records[fish_name] = weight
		print("🏆 Neuer Gewichtsrekord für %s: %.2f kg" % [fish_name, weight])
	elif weight > fish_weight_records[fish_name]:
		var old_record = fish_weight_records[fish_name]
		fish_weight_records[fish_name] = weight
		print("🏆 NEUER REKORD für %s: %.2f kg (vorher: %.2f kg)" % [fish_name, weight, old_record])

# 🆕 Höchstes gefangenes Gewicht abrufen
func get_max_caught_weight(fish_name: String) -> float:
	return fish_weight_records.get(fish_name, 0.0)

# 🆕 Fangzähler erhöhen
func update_catch_count(fish_name: String) -> void:
	if not fish_catch_count.has(fish_name):
		fish_catch_count[fish_name] = 1
	else:
		fish_catch_count[fish_name] += 1
	print("📊 %s gefangen: %dx" % [fish_name, fish_catch_count[fish_name]])

# 🆕 Anzahl gefangener Fische abrufen
func get_catch_count(fish_name: String) -> int:
	return fish_catch_count.get(fish_name, 0)

# 🆕 Prüft ob alle Fische eines Bioms gefangen wurden
func check_biome_completion(fish_data: Dictionary) -> void:
	print("DEBUG: check_biome_completion gestartet für:", fish_data["name"])
	
	# Finde heraus zu welchem Biom der Fisch gehört
	var biome = get_fish_biome(fish_data["name"])
	print("DEBUG: Biom gefunden:", biome)
	
	if biome == "":
		print("DEBUG: Kein Biom gefunden - Abbruch")
		return
	
	# Wenn Biom bereits als komplett markiert, nichts tun
	if completed_biomes[biome]:
		print("DEBUG: Biom", biome, "ist bereits komplett - Abbruch")
		return
	
	# Hole alle Fische des Bioms
	var biome_fish = get_biome_fish_list(biome)
	print("DEBUG: Anzahl Fische im Biom", biome, ":", biome_fish.size())
	
	if biome_fish.is_empty():
		print("DEBUG: Biom-Liste ist leer - Abbruch")
		return
	
	# Prüfe ob ALLE Fische gefangen wurden
	var all_caught = true
	for fish in biome_fish:
		print("DEBUG: Prüfe Fisch:", fish["name"], "- Gefangen:", caught_fish_species.has(fish["name"]))
		if not caught_fish_species.has(fish["name"]):
			all_caught = false
			break
	
	print("DEBUG: Alle Fische gefangen?", all_caught)
	
	# Wenn alle gefangen: Event auslösen
	if all_caught:
		print("DEBUG: Triggere Biom-Completion Event!")
		trigger_biome_completion_event(biome)

# 🆕 Findet das Biom eines Fisches anhand des Namens
func get_fish_biome(fish_name: String) -> String:
	for fish in FishDB.FISH_LAKE:
		if fish["name"] == fish_name:
			return "lake"
	
	for fish in FishDB.FISH_CITY:
		if fish["name"] == fish_name:
			return "city"
	
	for fish in FishDB.FISH_SEWER:
		if fish["name"] == fish_name:
			return "sewer"
	
	for fish in FishDB.FISH_FOREST:
		if fish["name"] == fish_name:
			return "forest"
	
	for fish in FishDB.FISH_DESERT:
		if fish["name"] == fish_name:
			return "desert"
			
	for fish in FishDB.FISH_ICELAND:
		if fish["name"] == fish_name:
			return "iceland"
	
	return ""

# 🆕 Gibt die Fischliste eines Bioms zurück
func get_biome_fish_list(biome: String) -> Array:
	match biome:
		"lake":
			return FishDB.FISH_LAKE
		"city":
			return FishDB.FISH_CITY
		"sewer":
			return FishDB.FISH_SEWER
		"forest":
			return FishDB.FISH_FOREST
		"desert":
			return FishDB.FISH_DESERT
		"iceland":
			return FishDB.FISH_ICELAND
		_:
			return []

# 🆕 Event wenn ein Biom komplett ist
func trigger_biome_completion_event(biome: String) -> void:
	completed_biomes[biome] = true
	save_game()
	
	print("🎉 BIOM KOMPLETT: ", biome.to_upper(), " - Alle Fische gefangen!")
	
	var reward = 0
	
	match biome:
		"lake":
			print("✨ See-Meister! Belohnung: 500 Gold")
			reward = 500
			add_money(reward)
		
		"city":
			print("✨ Stadt-Angler! Belohnung: 1000 Gold")
			reward = 1000
			add_money(reward)
		
		"sewer":
			print("✨ Kanalisation-Eroberer! Belohnung: 1500 Gold")
			reward = 1500
			add_money(reward)
		
		"forest":
			print("✨ Wald-Experte! Belohnung: 2000 Gold")
			reward = 2000
			add_money(reward)
		
		"desert":
			print("✨ Wüsten-Legende! Belohnung: 3000 Gold")
			reward = 3000
			add_money(reward)

		"iceland":
			print("✨ Eis-Legende! Belohnung: 4000 Gold")
			reward = 4000
			add_money(reward)
	
	emit_signal("biome_completed", biome, reward)

func remove_fish(index: int) -> void:
	if index >= 0 and index < fish_inventory.size():
		fish_inventory.remove_at(index)
		save_game()
		
func _add_all_fish() -> void:
	for fish in FishDB.FISH_LAKE:
		add_fish(fish)
	for fish in FishDB.FISH_CITY:
		add_fish(fish)
	for fish in FishDB.FISH_SEWER:
		add_fish(fish)
	for fish in FishDB.FISH_FOREST:
		add_fish(fish)
	for fish in FishDB.FISH_DESERT:
		add_fish(fish)
	for fish in FishDB.FISH_ICELAND:
		add_fish(fish)

func clear_inventory():
	Inventory.clear_inventory()
	fish_inventory.clear()
	save_game()

func get_inventory_value() -> int:
	var total = 0
	for f in fish_inventory:
		var rarity_bonus = FishDB.RARITY_DATA[f["rarity"]]["value"]
		total += int(f["base_value"] * rarity_bonus)
	return total


# Im save_game():
func save_game() -> void:
	var save_data = {
		"money": money,
		"level": level,
		"xp": xp,
		"upgrade_grip": upgrade_grip,
		"upgrade_bait": upgrade_bait,
		"upgrade_line": upgrade_line,
		"last_scene": last_scene,
		"fish_inventory": fish_inventory,
		"unlocked_spots": unlocked_spots,
		"caught_fish_species": caught_fish_species,
		"completed_biomes": completed_biomes,
		"fish_weight_records": fish_weight_records,
		"fish_catch_count": fish_catch_count,
		"used_story_items": used_story_items  # 🆕
	}
	var file = FileAccess.open("user://savegame.dat", FileAccess.WRITE)
	file.store_var(save_data)
	print("Spiel gespeichert!")


# Im load_game():
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
		fish_inventory = save_data.get("fish_inventory", [])
		unlocked_spots = save_data.get("unlocked_spots", unlocked_spots)
		caught_fish_species = save_data.get("caught_fish_species", {})
		completed_biomes = save_data.get("completed_biomes", completed_biomes)
		fish_weight_records = save_data.get("fish_weight_records", {})
		fish_catch_count = save_data.get("fish_catch_count", {})
		used_story_items = save_data.get("used_story_items", [])  # 🆕
		print("Spiel geladen!")


# Im reset():
func reset():
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
	used_story_items.clear()  # 🆕
	completed_biomes = {
		"lake": false,
		"city": false,
		"sewer": false,
		"forest": false,
		"desert": false,
		"iceland": false,
		"home": true,

	}
	unlocked_spots = {
		"lake": true,
		"city": false,
		"sewer": false,
		"forest": false,
		"desert": false,
		"iceland": false,
		"home": true,
	}
	save_game()
