extends Node

var fish_inventory: Array = []  # Liste aller gefangenen Fische

func add_fish(fish_data: Dictionary) -> void:
	fish_inventory.append(fish_data)
	print("Fisch ins Inventar hinzugefügt:", fish_data)

func remove_fish(index: int) -> void:
	if index >= 0 and index < fish_inventory.size():
		fish_inventory.remove_at(index)

func clear_inventory():
	fish_inventory.clear()

func get_total_value() -> int:
	var total = 0
	for f in fish_inventory:
		var rarity_bonus = FishDB.RARITY_DATA[f["rarity"]]["value"]
		total += int(f["base_value"] * rarity_bonus)
	return total
