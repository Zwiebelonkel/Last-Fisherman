extends Node

var fish_inventory: Array = []  # Liste aller gefangenen Fische

func _ready():
	load_inventory()

func add_fish(fish_data: Dictionary) -> void:
	fish_inventory.append(fish_data)
	var fish_name := FishDB.get_fish_name(fish_data)
	print("Fisch ins Inventar hinzugefügt:", fish_name)
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
		total += FishDB.get_fish_value(f)
	return total

func save_inventory() -> void:
	var save_data = {
		"fish_inventory": fish_inventory,
		"version": 2  # ✅ Version 2 = ID-basiertes System
	}
	var file = FileAccess.open("user://inventory.dat", FileAccess.WRITE)
	file.store_var(save_data)
	print("Inventar gespeichert!")

func load_inventory() -> void:
	if FileAccess.file_exists("user://inventory.dat"):
		var file = FileAccess.open("user://inventory.dat", FileAccess.READ)
		var save_data = file.get_var()
		
		# ✅ Prüfe Version
		var version: int = save_data.get("version", 1)
		fish_inventory = save_data.get("fish_inventory", [])
		
		print("Inventar geladen! Version:", version, "Fische:", fish_inventory.size())
		
		if version == 1:
			# ✅ MIGRATION: Alte name-basierte Saves
			print("🔄 Migriere altes Inventar-Format...")
			_migrate_v1_to_v2()
		else:
			# Auch bei Version 2 Emergency Fix laufen lassen (für Sicherheit)
			_emergency_fix_all_fish()
	else:
		print("Keine Inventar-Speicherdatei gefunden")

# ✅ MIGRATION: Version 1 (name) → Version 2 (id)
func _migrate_v1_to_v2() -> void:
	print("🚨 Starte Migration von V1 zu V2...")
	
	var migrated_inventory: Array = []
	var migrated_count := 0
	var failed_count := 0
	
	for old_fish in fish_inventory:
		# Hole den alten Namen
		var old_name: String = old_fish.get("name", "")
		if old_name == "":
			print("  ❌ Überspringe Fish ohne Namen")
			failed_count += 1
			continue
		
		# Finde die ID für diesen Namen
		var fish_id := _find_id_by_old_name(old_name)
		if fish_id == "":
			print("  ❌ Keine ID gefunden für:", old_name)
			failed_count += 1
			continue
		
		# Hole komplette Fisch-Daten aus FishDB
		var complete_fish := FishDB.get_fish_by_id(fish_id)
		if complete_fish.is_empty():
			print("  ❌ FishDB hat keine Daten für ID:", fish_id)
			failed_count += 1
			continue
		
		# Erstelle neuen Fisch mit ID
		var new_fish := complete_fish.duplicate(true)
		
		# Behalte individuelles Gewicht falls vorhanden
		if old_fish.has("weight"):
			new_fish["weight"] = old_fish["weight"]
		elif not new_fish.has("weight"):
			# Generiere zufälliges Gewicht
			if new_fish.has("weight_min") and new_fish.has("weight_max"):
				new_fish["weight"] = randf_range(new_fish["weight_min"], new_fish["weight_max"])
			else:
				new_fish["weight"] = 1.0
		
		migrated_inventory.append(new_fish)
		migrated_count += 1
		print("  ✅ Migriert:", old_name, "→", fish_id)
	
	# Ersetze Inventar
	fish_inventory = migrated_inventory
	
	print("✅ Migration abgeschlossen:")
	print("  - Erfolgreich:", migrated_count)
	print("  - Fehlgeschlagen:", failed_count)
	print("  - Verbleibend:", fish_inventory.size())
	
	# Speichere migrierte Daten
	if migrated_count > 0:
		save_inventory()

# ✅ Findet ID für alten Namen (Case-Insensitive)
func _find_id_by_old_name(old_name: String) -> String:
	var all_lists = [
		FishDB.FISH_LAKE,
		FishDB.FISH_CITY,
		FishDB.FISH_SEWER,
		FishDB.FISH_FOREST,
		FishDB.FISH_DESERT,
		FishDB.FISH_ICELAND
	]
	
	var old_name_lower := old_name.to_lower()
	
	for list in all_lists:
		for fish in list:
			# Vergleiche mit übersetztem Namen (case-insensitive)
			var translated_name := FishDB.get_fish_name(fish).to_lower()
			if translated_name == old_name_lower:
				return fish.get("id", "")
			
			# Fallback: Vergleiche auch mit name_key (falls direct match)
			if fish.get("name_key", "").to_lower() == old_name_lower:
				return fish.get("id", "")
	
	return ""

# 🚨 NOTFALL-REPARATUR: Für Version 2 Fische mit fehlenden Daten
func _emergency_fix_all_fish() -> void:
	print("🚨 Emergency Fish Fix gestartet...")
	
	var fixed_count := 0
	var removed_count := 0
	var valid_inventory: Array = []
	
	for fish in fish_inventory:
		# ✅ Prüfe ob Fisch ID hat (Version 2)
		if not fish.has("id") or fish["id"] == "":
			print("  ❌ Entferne Fisch ohne ID")
			removed_count += 1
			continue
		
		var was_fixed := false
		var fish_id: String = fish["id"]
		
		# Hole komplette Daten aus FishDB
		var complete_fish := FishDB.get_fish_by_id(fish_id)
		
		if complete_fish.is_empty():
			print("  ❌ Entferne Fisch mit ungültiger ID:", fish_id)
			removed_count += 1
			continue
		
		# Fix 1: Fehlende Keys ergänzen
		var required_keys := ["name_key", "description_key", "science_key", "rarity", "base_value", "icon"]
		for key in required_keys:
			if not fish.has(key) and complete_fish.has(key):
				fish[key] = complete_fish[key]
				was_fixed = true
		
		# Fix 2: Weight fehlt
		if not fish.has("weight") or fish["weight"] <= 0:
			if complete_fish.has("weight_min") and complete_fish.has("weight_max"):
				fish["weight"] = randf_range(complete_fish["weight_min"], complete_fish["weight_max"])
			else:
				fish["weight"] = 1.0
			was_fixed = true
		
		# Fix 3: Rarity validieren
		if not FishDB.RARITY_DATA.has(fish.get("rarity", -1)):
			print("  🔧 Korrigiere ungültige rarity für:", fish_id)
			fish["rarity"] = complete_fish.get("rarity", FishDB.RARITY.NORMAL)
			was_fixed = true
		
		if was_fixed:
			fixed_count += 1
			print("  🔧 Repariert:", fish_id)
		
		valid_inventory.append(fish)
	
	# Ersetze Inventar mit reparierter Version
	fish_inventory = valid_inventory
	
	if fixed_count > 0 or removed_count > 0:
		print("✅ Emergency Fix abgeschlossen:")
		print("  - Repariert:", fixed_count)
		print("  - Entfernt:", removed_count)
		print("  - Verbleibend:", fish_inventory.size())
		save_inventory()  # Speichere reparierte Daten sofort!
	else:
		print("✅ Emergency Fix: Keine Probleme gefunden")
