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
		# 🔒 CRITICAL FIX: Sichere rarity-Zugriffe
		if not f.has("rarity"):
			print("⚠️ Fisch ohne rarity übersprungen:", f.get("name", "Unknown"))
			continue
		
		if not FishDB.RARITY_DATA.has(f["rarity"]):
			print("⚠️ Fisch mit ungültiger rarity übersprungen:", f.get("name", "Unknown"))
			continue
		
		var rarity_bonus = FishDB.RARITY_DATA[f["rarity"]].get("value", 1.0)
		var base_value = f.get("base_value", 1)
		total += int(base_value * rarity_bonus)
	
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
		
		# 🚨 SOFORT REPARIEREN - BEVOR irgendwas crashen kann!
		_emergency_fix_all_fish()
	else:
		print("Keine Inventar-Speicherdatei gefunden")

# 🚨 NOTFALL-REPARATUR: Läuft sofort nach dem Laden
func _emergency_fix_all_fish() -> void:
	print("🚨 Emergency Fish Fix gestartet...")
	
	var fixed_count := 0
	var removed_count := 0
	var valid_inventory: Array = []
	
	for fish in fish_inventory:
		# Prüfe ob Fisch überhaupt einen Namen hat
		if not fish.has("name") or fish["name"] == "":
			print("  ❌ Entferne namenlosen Fisch")
			removed_count += 1
			continue
		
		var was_fixed := false
		
		# Fix 1: Rarity fehlt oder ungültig
		if not fish.has("rarity"):
			print("  🔧 Repariere rarity für:", fish["name"])
			var complete_fish = _get_complete_fish_by_name(fish["name"])
			if not complete_fish.is_empty():
				fish["rarity"] = complete_fish["rarity"]
			else:
				fish["rarity"] = FishDB.RARITY.NORMAL
			was_fixed = true
		
		# Prüfe ob rarity gültig ist
		if not FishDB.RARITY_DATA.has(fish["rarity"]):
			print("  🔧 Korrigiere ungültige rarity für:", fish["name"], "von", fish["rarity"], "zu NORMAL")
			fish["rarity"] = FishDB.RARITY.NORMAL
			was_fixed = true
		
		# Fix 2: Base Value fehlt
		if not fish.has("base_value"):
			print("  🔧 Repariere base_value für:", fish["name"])
			var complete_fish = _get_complete_fish_by_name(fish["name"])
			if not complete_fish.is_empty():
				fish["base_value"] = complete_fish["base_value"]
			else:
				fish["base_value"] = 1
			was_fixed = true
		
		# Fix 3: Icon fehlt
		if not fish.has("icon"):
			print("  🔧 Repariere icon für:", fish["name"])
			var complete_fish = _get_complete_fish_by_name(fish["name"])
			if not complete_fish.is_empty():
				fish["icon"] = complete_fish["icon"]
			else:
				fish["icon"] = "res://assets/fish/unknown.png"
			was_fixed = true
		
		# Fix 4: Weight fehlt
		if not fish.has("weight") or fish["weight"] <= 0:
			fish["weight"] = 1.0
			was_fixed = true
		
		# Fix 5: Weight Min/Max fehlt
		if not fish.has("weight_min"):
			var complete_fish = _get_complete_fish_by_name(fish["name"])
			if not complete_fish.is_empty():
				fish["weight_min"] = complete_fish["weight_min"]
			else:
				fish["weight_min"] = 1.0
			was_fixed = true
		
		if not fish.has("weight_max"):
			var complete_fish = _get_complete_fish_by_name(fish["name"])
			if not complete_fish.is_empty():
				fish["weight_max"] = complete_fish["weight_max"]
			else:
				fish["weight_max"] = 1.0
			was_fixed = true
		
		if was_fixed:
			fixed_count += 1
		
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

func _get_complete_fish_by_name(fish_name: String) -> Dictionary:
	# Suche in allen Biom-Listen
	var all_lists = [
		FishDB.FISH_LAKE,
		FishDB.FISH_CITY,
		FishDB.FISH_SEWER,
		FishDB.FISH_FOREST,
		FishDB.FISH_DESERT,
		FishDB.FISH_ICELAND
	]
	
	for list in all_lists:
		for fish in list:
			if fish["name"] == fish_name:
				return fish
	
	return {}  # Leer wenn nicht gefunden
