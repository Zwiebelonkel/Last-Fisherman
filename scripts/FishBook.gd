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
		"iceland": FishDB.FISH_ICELAND,  # ✅ Bleibt bestehen
		"ocean": FishDB.FISH_OCEAN,      # 🆕 Neue Map mit Steam-Player
		# SORTIERTE GESAMTLISTE
		"insgesamt": _sort_fish_by_rarity(
			FishDB.FISH_LAKE
			+ FishDB.FISH_CITY
			+ FishDB.FISH_SEWER
			+ FishDB.FISH_FOREST
			+ FishDB.FISH_DESERT
			+ FishDB.FISH_ICELAND
			+ FishDB.FISH_OCEAN
		)
	}

# ===========================
#  SORTIERFUNKTION (FIXED)
# ===========================
# Sortiert Fische nach rarity → NORMAL oben, EXOTISCH unten
func _sort_fish_by_rarity(fish_list: Array) -> Array:
	var sorted = fish_list.duplicate()
	sorted.sort_custom(func(a, b):
		# 🔒 FIX: Sichere rarity-Zugriffe mit .get()
		var rarity_a = a.get("rarity", FishDB.RARITY.NORMAL)
		var rarity_b = b.get("rarity", FishDB.RARITY.NORMAL)
		
		if rarity_a == rarity_b:
			# Innerhalb gleicher rarity: Wert niedrig → hoch
			var value_a = a.get("base_value", 0)
			var value_b = b.get("base_value", 0)
			return value_a < value_b
		return rarity_a < rarity_b
	)
	return sorted

# ===========================
#  CAUGHT CHECK
# ===========================
func is_fish_caught(fish_id: String) -> bool:
	return Player.caught_fish_species.has(fish_id)

# ===========================
#  🆕 GET CAUGHT FISH DATA
# ===========================
# Holt die gespeicherten Daten eines gefangenen Fisches (für Steam-Player)
func get_caught_fish_data(fish_id: String) -> Dictionary:
	# Suche im Inventar nach dem ersten Exemplar dieses Fisches
	for fish in Inventory.fish_inventory:
		if fish.get("id", "") == fish_id:
			return fish
	
	# Nicht im aktuellen Inventar? Prüfe Player.caught_fish_details
	#if Player.has("caught_fish_details") and Player.caught_fish_details.has(fish_id):
		#return Player.caught_fish_details[fish_id]
	
	return {}

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
		# 🔒 CRITICAL FIX: Prüfe rarity VOR Zugriff
		if not fish.has("rarity"):
			push_warning("⚠️ Fish ohne rarity im Bestiary: %s" % fish.get("id", "UNKNOWN"))
			continue
		
		if not FishDB.RARITY_DATA.has(fish["rarity"]):
			push_warning("⚠️ Ungültige rarity im Bestiary: %s" % fish["rarity"])
			continue
		
		var fish_id: String = String(fish.get("id", ""))
		var caught := is_fish_caught(fish_id)
		
		# 🆕 Für Steam-Player: Hole gespeicherte Daten aus Inventar
		var display_name: String
		var display_icon
		
		if caught:
			if fish.get("is_steam_player", false):
				# 🆕 Hole persistent gespeicherte Steam-Daten
				var caught_fish := get_caught_fish_data(fish_id)
				
				if not caught_fish.is_empty():
					# Verwende gespeicherten Steam-Namen
					display_name = caught_fish.get("steam_name", FishDB.get_fish_name(fish))
					
					# Verwende gespeicherten Avatar (bereits als Texture2D)
					if caught_fish.has("steam_avatar") and caught_fish["steam_avatar"] is Texture2D:
						display_icon = caught_fish["steam_avatar"]
					else:
						display_icon = fish.get("icon", "res://assets/fish/unknown.png")
				else:
					# Fallback: Fetche live (sollte nicht passieren)
					var temp_fish: Dictionary = fish.duplicate(true)
					FishDB._apply_steam_data_to_fish(temp_fish)
					display_name = temp_fish.get("steam_name", FishDB.get_fish_name(fish))
					display_icon = temp_fish.get("steam_avatar", fish.get("icon", "res://assets/fish/unknown.png"))
			else:
				# Normaler Fisch
				display_name = FishDB.get_fish_name(fish)
				display_icon = fish.get("icon", "res://assets/fish/unknown.png")
		else:
			# Nicht gefangen
			display_name = "???"
			display_icon = "res://assets/fish/unknown.png"
		
		var entry := {
			"id": fish_id,
			"name": display_name,
			"rarity": fish["rarity"] if caught else FishDB.RARITY.NORMAL,
			"base_value": fish.get("base_value", 0) if caught else 0,
			"icon": display_icon,
			"caught": caught,
			"is_steam_player": fish.get("is_steam_player", false)
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
		if is_fish_caught(fish.get("id", "")):
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
