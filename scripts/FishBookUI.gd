extends Control

# ===========================
#  FISCHBUCH UI SCENE
# ===========================

var grid_container: GridContainer
var location_selector: Control  # Kann Button oder OptionButton sein
var stats_label: Label
var title_label: Label

var current_location = "lake"
var fish_entry_scene = preload("res://scenes/FishBookEntry.tscn")
var fish_book

func _ready():
	print("📖 FishBook UI Starting...")
	print_scene_structure(self, 0)
	
	fish_book = load("res://scripts/FishBook.gd").new()
	
	# Versuche verschiedene Pfade
	if has_node("VBoxContainer/ScrollContainer/GridContainer"):
		grid_container = get_node("VBoxContainer/ScrollContainer/GridContainer")
	
	if has_node("VBoxContainer/HBoxContainer/LocationSelector"):
		location_selector = get_node("VBoxContainer/HBoxContainer/LocationSelector")
	
	if has_node("VBoxContainer/HBoxContainer/StatsLabel"):
		stats_label = get_node("VBoxContainer/HBoxContainer/StatsLabel")
	
	if has_node("VBoxContainer/TitleLabel"):
		title_label = get_node("VBoxContainer/TitleLabel")
	
	# Debug-Ausgabe
	print("Grid Container: ", grid_container, " (", grid_container.get_class() if grid_container else "null", ")")
	print("Location Selector: ", location_selector, " (", location_selector.get_class() if location_selector else "null", ")")
	print("Stats Label: ", stats_label, " (", stats_label.get_class() if stats_label else "null", ")")
	print("Title Label: ", title_label, " (", title_label.get_class() if title_label else "null", ")")
	
	if not grid_container or not location_selector or not stats_label or not title_label:
		print("❌ ERROR: Nicht alle Nodes gefunden!")
		return
	
	# Location-Buttons Setup
	if location_selector is OptionButton:
		location_selector.item_selected.connect(_on_location_changed)
		location_selector.clear()
		location_selector.add_item("🌊 See")
		location_selector.add_item("🏙️ Stadt")
		location_selector.add_item("🏙️ Kanal")

		location_selector.select(0)
	elif location_selector is Button:
		print("⚠️ LocationSelector ist ein Button, kein OptionButton")
		# Hier könnten wir später Button-Handling hinzufügen
	
	load_bestiary()
	print("✅ FishBook UI erfolgreich geladen!")

func print_scene_structure(node: Node, indent: int) -> void:
	var spaces = " ".repeat(indent * 2)
	print(spaces + "→ " + node.name + " (" + node.get_class() + ")")
	for child in node.get_children():
		print_scene_structure(child, indent + 1)

func load_bestiary():
	print("📖 load_bestiary() - Starting...")
	
	# Alte Einträge löschen
	for child in grid_container.get_children():
		child.queue_free()
	
	await get_tree().process_frame  # Warte bis alles gelöscht ist
	
	print("  GridContainer Size: ", grid_container.size)
	print("  GridContainer Position: ", grid_container.position)
	print("  GridContainer Columns: ", grid_container.columns)
	
	# Neue Einträge laden
	var entries = fish_book.get_bestiary_entries(current_location)
	print("  Entries zu laden: ", entries.size())
	
	for i in range(entries.size()):
		var entry = entries[i]
		var entry_ui = fish_entry_scene.instantiate()
		entry_ui.set_fish_data(entry)
		grid_container.add_child(entry_ui)
		print("    [", i, "] ", entry["name"], " hinzugefügt")
	
	print("  GridContainer Children nach laden: ", grid_container.get_child_count())
	
	# Stats aktualisieren
	update_stats()

func update_stats():
	var stats = fish_book.get_bestiary_stats(current_location)
	stats_label.text = "Gefangen: %d / %d (%d%%)" % [stats["caught"], stats["total"], stats["completion"]]
	
	match current_location:
		"lake":
			title_label.text = "📖 Fischbuch - See"
		"city":
			title_label.text = "📖 Fischbuch - Stadt"
		"sewer":
			title_label.text = "📖 Fischbuch - Kanal"

func _on_location_changed(index: int):
	match index:
		0:
			current_location = "lake"
		1:
			current_location = "city"
		2:
			current_location = "sewer"
	
	load_bestiary()

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if get_parent().has_method("toggle_bestiary"):
			get_parent().toggle_bestiary()
		get_tree().root.set_input_as_handled()

# ===========================
#  SZENE STRUKTUR (MANUELL ERSTELLEN)
# ===========================
# Control (Name: "FishBook")
# ├─ VBoxContainer
# │  ├─ TitleLabel (Label, Text: "📖 Fischbuch")
# │  ├─ HBoxContainer
# │  │  ├─ LocationSelector (OptionButton, Name: "LocationSelector")
# │  │  └─ StatsLabel (Label, Name: "StatsLabel")
# │  └─ ScrollContainer
# │     └─ GridContainer (Name: "GridContainer", Columns: 5)
#
# WICHTIG: Die Namen MÜSSEN exakt so sein!
