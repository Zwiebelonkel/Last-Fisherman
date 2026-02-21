extends Control

# ===========================
#  FISCHBUCH UI SCENE
# ===========================

var grid_container: GridContainer
var location_selector: OptionButton
var stats_label: Label
var title_label: Label

var current_location = "lake"
var fish_entry_scene = preload("res://scenes/FishBookEntry.tscn")
var fish_detail_popup_scene
var fish_book
var detail_popup: Control

# 🌍 Localized Texts
var localized_texts := {
	"caught_text": {
		"de": "Gefangen: %d / %d (%d%%)",
		"en": "Caught: %d / %d (%d%%)"
	},
	"collected_text": {  # 🆕 Für Zettel
		"de": "Gesammelt: %d / %d (%d%%)",
		"en": "Collected: %d / %d (%d%%)"
	},
	"fishbook_title": {
		"de": "📖 Fischbuch - %s",
		"en": "📖 Fishbook - %s"
	},
	"location_lake": {
		"de": "🌊 Strand",
		"en": "🌊 Beach"
	},
	"location_city": {
		"de": "🏢 Stadt",
		"en": "🏢 City"
	},
	"location_sewer": {
		"de": "🐀 U-Bahn",
		"en": "🐀 Subway"
	},
	"location_forest": {
		"de": "🌲 Wald",
		"en": "🌲 Forest"
	},
	"location_desert": {
		"de": "🌵 Wüste",
		"en": "🌵 Desert"
	},
	"location_iceland": {
		"de": "❄️ Eisland",
		"en": "❄️ Iceland"
	},
	"location_ocean": {
		"de": "🌊 Ozean",
		"en": "🌊 Ocean"
	},
	"location_lore": {  # 🆕 Lore-Kategorie
		"de": "❓ ???",
		"en": "❓ ???"
	},
	"location_all": {
		"de": "🌍 Alle",
		"en": "🌍 All"
	}
}

func _ready():
	fish_book = load("res://scripts/FishBook.gd").new()
	
	# Popup Scene laden
	print("Versuche FishDetailPopup zu laden...")
	if ResourceLoader.exists("res://scenes/FishDetailPopup.tscn"):
		fish_detail_popup_scene = load("res://scenes/FishDetailPopup.tscn")
		print("  ✅ FishDetailPopup.tscn geladen")
	else:
		print("  ❌ res://scenes/FishDetailPopup.tscn nicht gefunden!")
	
	# Nodes finden
	if has_node("VBoxContainer/ScrollContainer/GridContainer"):
		grid_container = get_node("VBoxContainer/ScrollContainer/GridContainer")
	
	if has_node("VBoxContainer/HBoxContainer/LocationSelector"):
		location_selector = get_node("VBoxContainer/HBoxContainer/LocationSelector")
	
	if has_node("VBoxContainer/HBoxContainer/StatsLabel"):
		stats_label = get_node("VBoxContainer/HBoxContainer/StatsLabel")
	
	if has_node("VBoxContainer/TitleLabel"):
		title_label = get_node("VBoxContainer/TitleLabel")
	
	# Detail-Popup erstellen
	if fish_detail_popup_scene:
		detail_popup = fish_detail_popup_scene.instantiate()
		add_child(detail_popup)
		detail_popup.visible = false
		print("  ✅ Detail Popup instantiiert")
	
	if not grid_container or not location_selector or not stats_label or not title_label:
		print("❌ ERROR: Nicht alle Nodes gefunden!")
		return
	
	# Grid-Einstellungen
	grid_container.columns = 5
	
	# Location-Selector Setup
	if location_selector is OptionButton:
		location_selector.item_selected.connect(_on_location_changed)
		location_selector.clear()
		location_selector.add_item(get_text("location_lake"))
		location_selector.add_item(get_text("location_city"))
		location_selector.add_item(get_text("location_sewer"))
		location_selector.add_item(get_text("location_forest"))
		location_selector.add_item(get_text("location_desert"))
		location_selector.add_item(get_text("location_iceland"))
		location_selector.add_item(get_text("location_ocean"))
		
		# 🆕 LORE KATEGORIE (nur wenn Zettel vorhanden)
		if LoreManager.get_note_count() > 0:
			location_selector.add_item(get_text("location_lore"))
		
		location_selector.add_item(get_text("location_all"))
	
	# Signal verbinden
	visibility_changed.connect(_on_visibility_changed)
	
	# 🆕 Verbinde Lore-Signal
	LoreManager.note_added.connect(_on_note_added)
	
	print("✅ FishBook UI erfolgreich geladen!")

# ===========================
#  🆕 LORE SIGNAL HANDLER
# ===========================

func _on_note_added(note_id: String, digit: int) -> void:
	print("📝 FishBook: Neuer Zettel - %s" % note_id)
	
	# Füge ??? Kategorie hinzu wenn noch nicht vorhanden
	if location_selector:
		var has_lore_category = false
		for i in range(location_selector.item_count):
			if location_selector.get_item_text(i) == get_text("location_lore"):
				has_lore_category = true
				break
		
		if not has_lore_category:
			# Füge vor "Alle" ein
			var all_index = location_selector.item_count - 1
			location_selector.add_item(get_text("location_lore"))
			
			# Verschiebe "Alle" ans Ende
			location_selector.move_item(location_selector.item_count - 1, all_index)
			
			print("  ✅ ??? Kategorie hinzugefügt")
	
	# Refresh wenn aktuell in ??? Kategorie
	if current_location == "???":
		load_bestiary()

# ===========================
#  LOCALIZATION HELPER
# ===========================

func get_text(key: String) -> String:
	var current_lang = Player.current_language
	if localized_texts.has(key) and localized_texts[key].has(current_lang):
		return localized_texts[key][current_lang]
	elif localized_texts.has(key) and localized_texts[key].has("de"):
		return localized_texts[key]["de"]
	return key

# ===========================
#  POPUP
# ===========================

func show_fish_detail_popup(fish_data: Dictionary):
	print("show_fish_detail_popup() aufgerufen mit:", fish_data.get("name", fish_data.get("id", "Unknown")))
	
	if not detail_popup:
		print("  ❌ detail_popup ist null!")
		return
	
	if not detail_popup.has_method("show_fish_details"):
		print("  ❌ Methode 'show_fish_details' nicht gefunden!")
		return
	
	var fish_id: String = fish_data.get("id", "")
	if LoreManager.NOTES.has(fish_id):
		var note: Dictionary = LoreManager.NOTES[fish_id].duplicate()
		note["id"]      = fish_id
		note["is_lore"] = true
		note["caught"]  = true
		detail_popup.show_fish_details(note)
		return
	
	detail_popup.show_fish_details(fish_data)
# ===========================
#  VISIBILITY
# ===========================

func _on_visibility_changed() -> void:
	if visible:
		print("📖 FishBook wurde geöffnet - Lade aktuellen Ort...")
		
		# Versuche fishing_location aus FishingRod zu holen
		var fishing_rod = get_tree().root.get_node_or_null("MainScene3/PlayerCamera/FishingRod")
		
		if not fishing_rod:
			for scene_name in ["MainScene", "MainScene2", "forest", "ocean"]:
				fishing_rod = get_tree().root.get_node_or_null(scene_name + "/PlayerCamera/FishingRod")
				if fishing_rod:
					break
		
		if fishing_rod and "fishing_location" in fishing_rod:
			var detected_location = fishing_rod.fishing_location
			print("  ✅ Ort erkannt: ", detected_location)
			current_location = detected_location
			
			var location_index = get_location_index(detected_location)
			if location_index >= 0:
				location_selector.select(location_index)
		else:
			print("  ⚠️ FishingRod nicht gefunden, nutze Standard: lake")
			current_location = "lake"
			location_selector.select(0)
		
		load_bestiary()

# ===========================
#  LOCATION INDEX
# ===========================

func get_location_index(location: String) -> int:
	match location:
		"lake":
			return 0
		"city":
			return 1
		"sewer":
			return 2
		"forest":
			return 3
		"desert":
			return 4
		"iceland":
			return 5
		"ocean":
			return 6
		"???":  # 🆕 Lore
			return 7
		"insgesamt":
			return 8  # 🆕 Verschoben
		_:
			return 0

# ===========================
#  LOAD BESTIARY
# ===========================

func load_bestiary():
	print("📖 load_bestiary() - Starting...")
	
	# Alte Einträge löschen
	for child in grid_container.get_children():
		child.queue_free()
	
	await get_tree().process_frame
	
	# Neue Einträge laden
	var entries = fish_book.get_bestiary_entries(current_location)
	print("  Entries zu laden: ", entries.size())
	
	for i in range(entries.size()):
		var entry = entries[i]
		var entry_ui = fish_entry_scene.instantiate()
		
		if entry_ui.has_method("set_fishbook_ui"):
			entry_ui.set_fishbook_ui(self)
		
		entry_ui.set_fish_data(entry)
		grid_container.add_child(entry_ui)
		
		# Fade-in Animation
		entry_ui.modulate.a = 0
		entry_ui.scale = Vector2(0.8, 0.8)
		
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(entry_ui, "modulate:a", 1.0, 0.3).set_delay(i * 0.03)
		tween.tween_property(entry_ui, "scale", Vector2(1.0, 1.0), 0.3).set_delay(i * 0.03).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# Stats aktualisieren
	update_stats()

# ===========================
#  UPDATE STATS
# ===========================

func update_stats():
	var stats = fish_book.get_bestiary_stats(current_location)
	
	# Farbiger Progress-Text
	var color = Color.WHITE
	var completion = stats["completion"]
	
	if completion == 100:
		color = Color(0.2, 1.0, 0.3)
	elif completion >= 75:
		color = Color(0.3, 0.8, 1.0)
	elif completion >= 50:
		color = Color(1.0, 0.85, 0.3)
	else:
		color = Color(0.8, 0.8, 0.8)
	
	stats_label.add_theme_color_override("font_color", color)
	
	# 🆕 Unterschiedlicher Text für Lore
	if current_location == "???":
		stats_label.text = get_text("collected_text") % [stats["caught"], stats["total"], completion]
	else:
		stats_label.text = get_text("caught_text") % [stats["caught"], stats["total"], completion]
	
	if completion == 100:
		stats_label.text += " 🏆"
	
	# Titel aktualisieren
	var location_text = ""
	match current_location:
		"lake":
			location_text = get_text("location_lake")
		"city":
			location_text = get_text("location_city")
		"sewer":
			location_text = get_text("location_sewer")
		"forest":
			location_text = get_text("location_forest")
		"desert":
			location_text = get_text("location_desert")
		"iceland":
			location_text = get_text("location_iceland")
		"ocean":
			location_text = get_text("location_ocean")
		"???":  # 🆕 Lore
			location_text = get_text("location_lore")
		"insgesamt":
			location_text = get_text("location_all")
	
	title_label.text = get_text("fishbook_title") % location_text

# ===========================
#  LOCATION CHANGED
# ===========================

func _on_location_changed(index: int):
	match index:
		0:
			current_location = "lake"
		1:
			current_location = "city"
		2:
			current_location = "sewer"
		3:
			current_location = "forest"
		4:
			current_location = "desert"
		5:
			current_location = "iceland"
		6:
			current_location = "ocean"
		7:
			# Könnte ??? oder insgesamt sein
			if LoreManager.get_note_count() > 0:
				current_location = "???"
			else:
				current_location = "insgesamt"
		8:
			current_location = "insgesamt"
	
	load_bestiary()

# ===========================
#  INPUT
# ===========================

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if get_parent().has_method("toggle_bestiary"):
			get_parent().toggle_bestiary()
		get_tree().root.set_input_as_handled()

func _on_close_pressed() -> void:
	hide()
