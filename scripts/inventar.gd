extends Node
var fish_inventory: Array = []  # Liste aller gefangenen Fische

func _ready():
	load_inventory()

func add_fish(fish_data: Dictionary) -> void:
	fish_inventory.append(fish_data)
	print("Fisch ins Inventar hinzugefügt:", fish_data)
	save_inventory()

func remove_fish(index: int) -> void:
	if index >= 0 and index < fish_inventory.size():
		fish_inventory.remove_at(index)
		save_inventory()

func clear_inventory():
	fish_inventory.clear()
	save_inventory()

func get_total_value() -> int:
	var total = 0
	for f in fish_inventory:
		var rarity_bonus = FishDB.RARITY_DATA[f["rarity"]]["value"]
		total += int(f["base_value"] * rarity_bonus)
	return total

func save_inventory() -> void:
	var save_data = {
		"fish_inventory": fish_inventory
	}
	var file = FileAccess.open("user://inventory.dat", FileAccess.WRITE)
	file.store_var(save_data)
	print("Inventar gespeichert!")

func load_inventory() -> void:
	if FileAccess.file_exists("user://inventory.dat"):
		var file = FileAccess.open("user://inventory.dat", FileAccess.READ)
		var save_data = file.get_var()
		fish_inventory = save_data.get("fish_inventory", [])
		print("Inventar geladen! Fische im Inventar:", fish_inventory.size())
	else:
		print("Keine Inventar-Speicherdatei gefunden")
