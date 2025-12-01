extends Node

# ===========================
#  FISCHBUCH / BESTIARY MANAGER
# ===========================

# Alle verfügbaren Orte und ihre Fische
var LOCATION_FISH = {}

func _init():
	# Mapping von Location zu Fisch-Listen
	LOCATION_FISH = {
		"lake": FishDB.FISH_LAKE,
		"city": FishDB.FISH_CITY,
		"sewer": FishDB.FISH_SEWER,
		"forest": FishDB.FISH_FOREST,
		"desert": FishDB.FISH_DESERT,

		# SORTIERTE GESAMTLISTE
		"insgesamt": _sort_fish_by_rarity(
			FishDB.FISH_LAKE
			+ FishDB.FISH_CITY
			+ FishDB.FISH_SEWER
			+ FishDB.FISH_FOREST
			+ FishDB.FISH_DESERT
		)
	}
	

# ===========================
#  SORTIERFUNKTION
# ===========================
# Sortiert Fische nach rarity → NORMAL oben, EXOTISCH unten
func _sort_fish_by_rarity(fish_list: Array) -> Array:
	var sorted = fish_list.duplicate()

	sorted.sort_custom(func(a, b):
		if a["rarity"] == b["rarity"]:
			# Innerhalb gleicher rarity: Wert niedrig → hoch
			return a["base_value"] < b["base_value"]
		return a["rarity"] < b["rarity"]
	)

	return sorted




# ===========================
#  CAUGHT CHECK
# ===========================
func is_fish_caught(fish_name: String) -> bool:
	return Player.caught_fish_species.get(fish_name, false)



# ===========================
#  LOCATION FISHES
# ===========================
func get_fish_by_location(location: String) -> Array:
	if LOCATION_FISH.has(location):
		return LOCATION_FISH[location]
	return []



# ===========================
#  BESTIARY ENTRIES
# ===========================
func get_bestiary_entries(location: String) -> Array:
	var entries = []
	var fish_list = get_fish_by_location(location)
	
	for fish in fish_list:
		var caught = is_fish_caught(fish["name"])
		
		var entry = {
			"name": fish["name"] if caught else "???",
			"rarity": fish["rarity"] if caught else -1,
			"base_value": fish["base_value"] if caught else 0,
			"icon": fish["icon"] if caught else "res://assets/fish/unknown.png",
			"caught": caught,
			"original_name": fish["name"]
		}
		
		entries.append(entry)
	
	return entries



# ===========================
#  BESTIARY STATISTICS
# ===========================
func get_bestiary_stats(location: String) -> Dictionary:
	var fish_list = get_fish_by_location(location)
	var caught_count = 0
	var total_count = fish_list.size()
	
	for fish in fish_list:
		if is_fish_caught(fish["name"]):
			caught_count += 1
	
	var completion = int((float(caught_count) / float(total_count)) * 100) if total_count > 0 else 0
	
	return {
		"caught": caught_count,
		"total": total_count,
		"completion": completion
	}



# ===========================
#  ALL LOCATIONS STATS
# ===========================
func get_all_bestiary_stats() -> Dictionary:
	var stats = {}
	
	for location in LOCATION_FISH.keys():
		stats[location] = get_bestiary_stats(location)
	
	return stats



# ===========================
#  RESET (DEBUG)
# ===========================
func reset_bestiary() -> void:
	Player.caught_fish_species.clear()
	Player.save_game()
	print("📖 Fischbuch zurückgesetzt!")
