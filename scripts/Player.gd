extends Node

# --- PLAYER DATA ---
var money: int = 0
var level: int = 1
var xp: int = 0
var upgrade_grip: int = 1
var upgrade_bait: int = 1
var upgrade_line: int = 1
var last_scene: String = "res://scenes/MainScene.tscn"
var options: String = "res://scenes/OptionsControl.tscn"

var fish_inventory: Array = []
var caught_fish_species: Dictionary = {}

# 🆕 Biom-spezifische Fang-Zähler
var catches_lake: int = 0
var catches_city: int = 0
var catches_sewer: int = 0
var catches_forest: int = 0
var catches_desert: int = 0

var unlocked_spots = {
	"lake": true,
	"city": false,
	"sewer": false,
	"forest": false,
	"desert": false,
}

var spot_prices = {
	"lake": 0,
	"city": 500,
	"sewer": 1200,
	"forest": 2000,
	"desert": 4000
}

func _ready():
	load_game()

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
	get_tree().change_scene_to_file(last_scene)

func add_fish(fish_data: Dictionary) -> void:
	fish_inventory.append(fish_data)
	print("Fisch ins Inventar hinzugefügt:", fish_data)
	
	if not caught_fish_species.has(fish_data["name"]):
		caught_fish_species[fish_data["name"]] = true
		print("🐟 Neue Fischart entdeckt:", fish_data["name"])
	
	save_game()

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

func clear_inventory():
	fish_inventory.clear()
	save_game()

func get_inventory_value() -> int:
	var total = 0
	for f in fish_inventory:
		var rarity_bonus = FishDB.RARITY_DATA[f["rarity"]]["value"]
		total += int(f["base_value"] * rarity_bonus)
	return total

func reset():
	money = 0
	level = 1
	xp = 0
	upgrade_grip = 1
	upgrade_bait = 1
	upgrade_line = 1
	last_scene = "res://scenes/MainScene.tscn"
	fish_inventory.clear()
	caught_fish_species.clear()
	
	# 🆕 Biom-Zähler zurücksetzen
	catches_lake = 0
	catches_city = 0
	catches_sewer = 0
	catches_forest = 0
	catches_desert = 0
	
	unlocked_spots = {
		"lake": true,
		"city": false,
		"sewer": false,
		"forest": false,
		"desert": false
	}
	save_game()

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
		# 🆕 Biom-Zähler speichern
		"catches_lake": catches_lake,
		"catches_city": catches_city,
		"catches_sewer": catches_sewer,
		"catches_forest": catches_forest,
		"catches_desert": catches_desert
	}
	var file = FileAccess.open("user://savegame.dat", FileAccess.WRITE)
	file.store_var(save_data)
	print("Spiel gespeichert!")

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
		
		# 🆕 Biom-Zähler laden
		catches_lake = save_data.get("catches_lake", 0)
		catches_city = save_data.get("catches_city", 0)
		catches_sewer = save_data.get("catches_sewer", 0)
		catches_forest = save_data.get("catches_forest", 0)
		catches_desert = save_data.get("catches_desert", 0)
		
		print("Spiel geladen!")
	else:
		print("Keine Speicherdatei gefunden, starte neues Spiel")
