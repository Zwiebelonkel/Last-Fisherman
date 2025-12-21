extends Node
# ===========================
# STARTUP CHECKER (STRICT)
# ===========================

func _ready() -> void:
	FileLogger.log(">>> STARTUP CHECKER GESTARTET")

	FileLogger.log(">>> ROOT CHILDREN DUMP <<<")

	for child in get_tree().root.get_children():
		FileLogger.log("ROOT NODE: " + child.name)

	FileLogger.log(">>> END ROOT DUMP <<<")

	# ⏳ Autoloads + Steam sicher initialisieren lassen
	await get_tree().create_timer(0.1).timeout

	_check_autoloads()
	_check_fishdb_data()
	_check_save_files()
	_check_inventory()

	FileLogger.log("<<< STARTUP CHECKER BEENDET")
	FileLogger.log("")
	FileLogger.log("🎮 SPIEL KANN JETZT VERWENDET WERDEN")
	FileLogger.log("")


# -------------------------------------------------
# AUTOLOAD CHECK
# -------------------------------------------------
func _check_autoloads() -> void:
	FileLogger.log("=== AUTOLOAD CHECK ===")

	var autoloads: Array[String] = [
		"FileLogger",
		"FishDB",
		"Player",
		"Inventory",
		"GodotSteam",
		"Transition"
	]

	for name: String in autoloads:
		var exists: bool = has_node("/root/" + name)

		var icon: String = "✅" if exists else "❌"
		var text: String = name + (" OK" if exists else " FEHLT")

		FileLogger.log("%s %s" % [icon, text])


# -------------------------------------------------
# FISHDB CHECK
# -------------------------------------------------
func _check_fishdb_data() -> void:
	FileLogger.log("=== FISHDB DATA CHECK ===")

	if not has_node("/root/FishDB"):
		FileLogger.log("❌ FishDB existiert nicht!")
		return

	var rarity_data: Dictionary = FishDB.RARITY_DATA
	FileLogger.log("RARITY_DATA Size: %d" % rarity_data.size())

	for rarity: int in rarity_data.keys():
		var data: Dictionary = rarity_data[rarity]
		FileLogger.log("  Rarity %d → %s" % [rarity, data.get("name", "???")])

	var list_names: Array[String] = [
		"FISH_LAKE",
		"FISH_CITY",
		"FISH_SEWER",
		"FISH_FOREST",
		"FISH_DESERT",
		"FISH_ICELAND"
	]

	for list_name: String in list_names:
		var list_value = FishDB.get(list_name)
		if list_value == null:
			FileLogger.log("⚠️ %s existiert nicht!" % list_name)
			continue

		var list: Array = list_value
		FileLogger.log("%s: %d fish" % [list_name, list.size()])

		if list.is_empty():
			continue

		var fish: Dictionary = list[0]
		FileLogger.log("  Beispiel: %s" % fish.get("name", "NO NAME"))
		FileLogger.log("    - has rarity: %s" % fish.has("rarity"))
		FileLogger.log("    - has base_value: %s" % fish.has("base_value"))
		FileLogger.log("    - has icon: %s" % fish.has("icon"))

		if fish.has("rarity"):
			var rarity_value: int = fish["rarity"]
			FileLogger.log(
				"    - rarity valid: %s"
				% rarity_data.has(rarity_value)
			)


# -------------------------------------------------
# SAVE FILES
# -------------------------------------------------
func _check_save_files() -> void:
	FileLogger.log("=== SAVE FILES CHECK ===")

	var files: Array[String] = [
		"user://savegame.dat",
		"user://inventory.dat",
		"user://settings.dat"
	]

	for path: String in files:
		if not FileAccess.file_exists(path):
			FileLogger.log("⚠️ %s existiert nicht" % path)
			continue

		var f: FileAccess = FileAccess.open(path, FileAccess.READ)
		if f == null:
			FileLogger.log("❌ %s kann nicht gelesen werden" % path)
			continue

		FileLogger.log("✅ %s: %d bytes" % [path, f.get_length()])
		f.close()


# -------------------------------------------------
# INVENTORY CHECK
# -------------------------------------------------
func _check_inventory() -> void:
	FileLogger.log("=== INVENTORY CHECK ===")

	if not has_node("/root/Inventory"):
		FileLogger.log("❌ Inventory existiert nicht!")
		return

	var inventory: Array = Inventory.fish_inventory
	FileLogger.log("Fish Inventory Size: %d" % inventory.size())

	var broken_count: int = 0

	for i: int in range(inventory.size()):
		var fish: Dictionary = inventory[i]
		var issues: Array[String] = []

		if not fish.has("rarity"):
			issues.append("NO_RARITY")
		elif not FishDB.RARITY_DATA.has(int(fish["rarity"])):
			issues.append("INVALID_RARITY_%d" % int(fish["rarity"]))

		if not fish.has("base_value"):
			issues.append("NO_BASE_VALUE")

		if not fish.has("icon"):
			issues.append("NO_ICON")

		if issues.size() > 0:
			broken_count += 1
			FileLogger.log(
				"⚠️ Fish %d (%s): %s"
				% [i, fish.get("name", "???"), ", ".join(issues)]
			)

	if broken_count > 0:
		FileLogger.log("❌ %d kaputte Fische gefunden!" % broken_count)
	else:
		FileLogger.log("✅ Alle Fische im Inventar sind OK")
