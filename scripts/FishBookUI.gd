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
var fish_detail_popup_scene  # Wird in _ready() geladen
var fish_book
var detail_popup: Control


func _ready():
	fish_book = load("res://scripts/FishBook.gd").new()
	
	# Popup Scene laden - mit Fehlerbehandlung
	print("Versuche FishDetailPopup zu laden...")
	if ResourceLoader.exists("res://scenes/FishDetailPopup.tscn"):
		fish_detail_popup_scene = load("res://scenes/FishDetailPopup.tscn")
		print("  ✅ FishDetailPopup.tscn geladen")
	else:
		print("  ❌ res://scenes/FishDetailPopup.tscn nicht gefunden!")
		print("  → Bitte erstelle die Scene oder passe den Pfad an")
	
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
		print("  ✅ Detail Popup instantiiert und hinzugefügt")
		print("  → Popup Node:", detail_popup)
		print("  → Hat show_fish_details():", detail_popup.has_method("show_fish_details"))
	else:
		print("  ❌ Konnte Popup nicht erstellen - Scene nicht geladen")
	
	# Debug-Ausgabe
	print("Grid Container: ", grid_container)
	print("Location Selector: ", location_selector)
	print("Stats Label: ", stats_label)
	print("Title Label: ", title_label)
	
	if not grid_container or not location_selector or not stats_label or not title_label:
		print("❌ ERROR: Nicht alle Nodes gefunden!")
		return
	
	# Grid-Einstellungen
	grid_container.columns = 5  # 5 Karten pro Reihe
	
	# Location-Selector Setup
	if location_selector is OptionButton:
		location_selector.item_selected.connect(_on_location_changed)
		location_selector.clear()
		location_selector.add_item("🌊 See")
		location_selector.add_item("🏢 Stadt")
		location_selector.add_item("🐀 Kanal")
		location_selector.add_item("🌲 Wald")
		location_selector.add_item("🌵 Ödland")
		location_selector.add_item("❄️ Eisland")
		location_selector.add_item("🌍 Alle")
		location_selector.select(0)
	
	# Signal verbinden
	visibility_changed.connect(_on_visibility_changed)
	
	#load_bestiary()
	print("✅ FishBook UI erfolgreich geladen!")

# 🆕 Popup anzeigen
func show_fish_detail_popup(fish_data: Dictionary):
	print("show_fish_detail_popup() aufgerufen mit:", fish_data.get("name", "Unknown"))
	
	if detail_popup:
		print("  → detail_popup existiert")
		if detail_popup.has_method("show_fish_details"):
			print("  → Methode gefunden, rufe auf...")
			detail_popup.show_fish_details(fish_data)
		else:
			print("  ❌ Methode 'show_fish_details' nicht gefunden!")
			print("  → Verfügbare Methoden:", detail_popup.get_method_list())
	else:
		print("  ❌ detail_popup ist null!")
		print("  → Versuche Popup neu zu erstellen...")
		
		# Fallback: Popup neu erstellen
		if fish_detail_popup_scene:
			detail_popup = fish_detail_popup_scene.instantiate()
			add_child(detail_popup)
			detail_popup.visible = false
			
			# Warte einen Frame
			await get_tree().process_frame
			
			if detail_popup.has_method("show_fish_details"):
				detail_popup.show_fish_details(fish_data)
			else:
				print("  ❌ Auch nach Neuerstellen keine Methode gefunden")

func _on_visibility_changed() -> void:
	if visible:
		print("📖 FishBook wurde geöffnet - Aktualisiere Daten...")
		load_bestiary()

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
		
		# 🆕 WICHTIG: Setze Referenz zum FishBook UI
		if entry_ui.has_method("set_fishbook_ui"):
			entry_ui.set_fishbook_ui(self)
		
		entry_ui.set_fish_data(entry)
		grid_container.add_child(entry_ui)
		
		# ✨ Fade-in Animation (gestaffelt)
		entry_ui.modulate.a = 0
		entry_ui.scale = Vector2(0.8, 0.8)
		
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(entry_ui, "modulate:a", 1.0, 0.3).set_delay(i * 0.03)
		tween.tween_property(entry_ui, "scale", Vector2(1.0, 1.0), 0.3).set_delay(i * 0.03).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		
		 #🎭 Hover-Effekt hinzufügen
		#entry_ui.mouse_entered.connect(_on_entry_hover.bind(entry_ui, true))
		#entry_ui.mouse_exited.connect(_on_entry_hover.bind(entry_ui, false))
	
	# Stats aktualisieren
	update_stats()

#func _on_entry_hover(entry: PanelContainer, is_hovering: bool) -> void:
	## Nur für gefangene Fische
	#if not entry.fish_data.get("caught", false):
		#return
	#
	#var tween = create_tween()
	#
	#var start_pos = entry.position
	#var target_pos = start_pos + Vector2(0, -6)  # 6px nach oben
	#
	#if is_hovering:
		#entry.z_index = 10
		#tween.tween_property(entry, "position", target_pos, 0.05).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	#else:
		#entry.z_index = 0
		#tween.tween_property(entry, "position", entry.position + Vector2(0, 6), 0.05).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func update_stats():
	var stats = fish_book.get_bestiary_stats(current_location)
	
	# 🎨 Farbiger Progress-Text
	var color = Color.WHITE
	var completion = stats["completion"]
	
	if completion == 100:
		color = Color(0.2, 1.0, 0.3)  # Grün bei 100%
	elif completion >= 75:
		color = Color(0.3, 0.8, 1.0)  # Blau bei 75%+
	elif completion >= 50:
		color = Color(1.0, 0.85, 0.3)  # Gold bei 50%+
	else:
		color = Color(0.8, 0.8, 0.8)  # Grau unter 50%
	
	stats_label.add_theme_color_override("font_color", color)
	stats_label.text = "Gefangen: %d / %d (%d%%)" % [stats["caught"], stats["total"], completion]
	
	# 🏆 Komplettierungs-Badge
	if completion == 100:
		stats_label.text += " 🏆"
	
	# 📖 Titel aktualisieren
	match current_location:
		"lake":
			title_label.text = "📖 Fischbuch - 🌊 See"
		"city":
			title_label.text = "📖 Fischbuch - 🏢 Stadt"
		"sewer":
			title_label.text = "📖 Fischbuch - 🐀 Kanal"
		"forest":
			title_label.text = "📖 Fischbuch - 🌲 Wald"
		"desert":
			title_label.text = "📖 Fischbuch - 🌵 Ödland"
		"iceland":
			title_label.text = "📖 Fischbuch - ❄️ Eisland"
		"insgesamt":
			title_label.text = "📖 Fischbuch - 🌍 Alle Gebiete"

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
			current_location = "insgesamt"
	
	load_bestiary()

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if get_parent().has_method("toggle_bestiary"):
			get_parent().toggle_bestiary()
		get_tree().root.set_input_as_handled()


func _on_close_pressed() -> void:
	hide()
