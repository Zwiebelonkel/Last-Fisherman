extends PanelContainer
# ===========================
#  FISCHBUCH EINTRAG / ENTRY mit TOOLTIP
# ===========================

var icon: TextureRect
var name_label: Label
var rarity_label: Label
var value_label: Label
var fish_data: Dictionary = {}

# 🎯 TOOLTIP
var tooltip_panel: PanelContainer
var tooltip_label: RichTextLabel  # RichTextLabel statt Label!
var is_hovering: bool = false

func _ready():
	# Nodes finden
	icon = $VBoxContainer/MarginContainer/Icon
	name_label = $VBoxContainer/NameLabel
	rarity_label = $VBoxContainer/RarityLabel
	value_label = $VBoxContainer/ValueLabel
	
	# Größe setzen
	custom_minimum_size = Vector2(70, 90)
	
	# Tooltip erstellen
	create_tooltip()
	
	# Mouse Events aktivieren
	mouse_filter = Control.MOUSE_FILTER_PASS

func create_tooltip():
	# Tooltip Panel erstellen
	tooltip_panel = PanelContainer.new()
	tooltip_panel.visible = false
	tooltip_panel.z_index = 1000  # Sehr hoher Z-Index
	tooltip_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tooltip_panel.top_level = true  # WICHTIG: Macht es unabhängig vom Parent
	
	# Style für Tooltip
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.1, 0.1, 0.1, 0.95)
	style_box.border_color = Color(0.8, 0.6, 0.2)
	style_box.border_width_left = 2
	style_box.border_width_right = 2
	style_box.border_width_top = 2
	style_box.border_width_bottom = 2
	style_box.corner_radius_top_left = 5
	style_box.corner_radius_top_right = 5
	style_box.corner_radius_bottom_left = 5
	style_box.corner_radius_bottom_right = 5
	style_box.content_margin_left = 10
	style_box.content_margin_right = 10
	style_box.content_margin_top = 8
	style_box.content_margin_bottom = 8
	tooltip_panel.add_theme_stylebox_override("panel", style_box)
	
	# Tooltip Label (RichTextLabel für BBCode Support)
	tooltip_label = RichTextLabel.new()
	tooltip_label.bbcode_enabled = true
	tooltip_label.fit_content = true
	tooltip_label.scroll_active = false
	tooltip_label.custom_minimum_size = Vector2(200, 0)
	
	# 🎨 SCHRIFTART ÄNDERN - Wähle eine Option:
	
	# OPTION 1: Custom Font laden (ersetze mit deinem Font-Pfad)
	var custom_font = load("res://fonts/VCR_OSD_MONO_1.001.ttf")
	tooltip_label.add_theme_font_override("normal_font", custom_font)
	tooltip_label.add_theme_font_override("bold_font", custom_font)
	
	# OPTION 2: System Font mit anderen Eigenschaften
	# var font_variation = SystemFont.new()
	# font_variation.font_names = ["Comic Sans MS", "Arial", "Helvetica"]  # Fallback-Liste
	# tooltip_label.add_theme_font_override("normal_font", font_variation)
	
	# Font Größe und Farbe
	#tooltip_label.add_theme_font_size_override("normal_font_size", 13)
	#tooltip_label.add_theme_font_size_override("bold_font_size", 16)
	tooltip_label.add_theme_color_override("default_color", Color(0.95, 0.95, 0.95))
	
	tooltip_panel.add_child(tooltip_label)
	
	# WICHTIG: Tooltip als CanvasLayer hinzufügen für oberste Ebene
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100  # Oberste Layer
	canvas_layer.add_child(tooltip_panel)
	get_tree().root.add_child(canvas_layer)

func set_fish_data(data: Dictionary):
	fish_data = data
	
	if not is_node_ready():
		await ready
	
	update_display()

func update_display():
	if fish_data.is_empty():
		return
	
	if icon == null or name_label == null or rarity_label == null or value_label == null:
		return
	
	# 🐟 ICON
	if fish_data.has("icon") and ResourceLoader.exists(fish_data["icon"]):
		icon.texture = load(fish_data["icon"])
		icon.modulate = Color.WHITE
	else:
		icon.modulate = Color.GRAY
	
	# 📝 NAME
	var display_name = fish_data["name"] if fish_data.get("caught", false) else "???"
	name_label.text = display_name
	name_label.add_theme_font_size_override("font_size", 14)
	
	# 🎨 RARITY & VALUE
	if fish_data.get("caught", false):
		var rarity = fish_data["rarity"]
		var rarity_data = FishDB.RARITY_DATA[rarity]
		rarity_label.text = rarity_data["name"]
		rarity_label.modulate = rarity_data["color"]
		rarity_label.add_theme_font_size_override("font_size", 12)
		
		# 💰 VALUE
		value_label.text = "💰 %d" % fish_data["base_value"]
		value_label.add_theme_font_size_override("font_size", 11)
		value_label.show()
		
		# Hintergrund hell
		modulate = Color.WHITE
	else:
		rarity_label.text = "???"
		rarity_label.modulate = Color.GRAY
		rarity_label.add_theme_font_size_override("font_size", 12)
		value_label.hide()
		
		# Hintergrund grau
		modulate = Color(0.6, 0.6, 0.6)

func _process(_delta):
	# Tooltip Position aktualisieren wenn Maus sich bewegt
	if is_hovering and tooltip_panel and tooltip_panel.visible:
		update_tooltip_position()

func update_tooltip_position():
	var mouse_pos = get_viewport().get_mouse_position()
	var tooltip_size = tooltip_panel.size
	var viewport_size = get_viewport().get_visible_rect().size
	
	# Position: rechts neben der Maus mit Offset
	var target_x = mouse_pos.x + 15
	var target_y = mouse_pos.y - tooltip_size.y / 2
	
	# Verhindere, dass Tooltip aus dem Bildschirm geht
	if target_x + tooltip_size.x > viewport_size.x:
		target_x = mouse_pos.x - tooltip_size.x - 15
	
	if target_y < 0:
		target_y = 0
	elif target_y + tooltip_size.y > viewport_size.y:
		target_y = viewport_size.y - tooltip_size.y
	
	tooltip_panel.position = Vector2(target_x, target_y)

func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		if fish_data.get("caught", false):
			show_fish_details()

func show_fish_details():
	var name = fish_data.get("original_name", fish_data.get("name", "Unbekannt"))
	print("🐟 Details:", name)

# 🎯 MOUSE HOVER EVENTS
func _notification(what):
	if what == NOTIFICATION_MOUSE_ENTER:
		_on_mouse_entered()
	elif what == NOTIFICATION_MOUSE_EXIT:
		_on_mouse_exited()

func _on_mouse_entered():
	if not fish_data.get("caught", false):
		return  # Keine Tooltips für unbekannte Fische
	
	is_hovering = true
	
	# Beschreibung aus FishDB holen (falls nicht im fish_data vorhanden)
	var description = fish_data.get("description", "")
	
	# Wenn keine Beschreibung vorhanden, versuche sie aus FishDB zu holen
	if description == "":
		description = get_description_from_fishdb()
	
	# Tooltip Text zusammenbauen
	var tooltip_text = ""
	
	# Name (groß und fett)
	tooltip_text += "[b][font_size=16]%s[/font_size][/b]\n" % fish_data["name"]
	
	# Beschreibung
	if description != "":
		tooltip_text += "\n[color=#CCCCCC]%s[/color]" % description
	else:
		tooltip_text += "\n[color=#888888][i]Keine Beschreibung verfügbar.[/i][/color]"
	
	tooltip_label.text = tooltip_text
	tooltip_panel.visible = true
	update_tooltip_position()

func get_description_from_fishdb() -> String:
	# Durchsuche alle Fish-Listen in FishDB nach diesem Fisch
	var fish_name = fish_data.get("name", "")
	if fish_name == "":
		return ""
	
	var all_lists = [
		FishDB.FISH_LAKE,
		FishDB.FISH_CITY,
		FishDB.FISH_SEWER,
		FishDB.FISH_FOREST,
		FishDB.FISH_DESERT
	]
	
	for fish_list in all_lists:
		for fish in fish_list:
			if fish["name"] == fish_name:
				return fish.get("description", "")
	
	return ""

func _on_mouse_exited():
	is_hovering = false
	if tooltip_panel:
		tooltip_panel.visible = false

func _exit_tree():
	# Tooltip aufräumen (inkl. CanvasLayer)
	if tooltip_panel and is_instance_valid(tooltip_panel):
		var canvas_layer = tooltip_panel.get_parent()
		if canvas_layer and is_instance_valid(canvas_layer):
			canvas_layer.queue_free()
