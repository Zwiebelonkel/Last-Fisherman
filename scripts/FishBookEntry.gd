extends PanelContainer
# ===========================
#  FISCHBUCH EINTRAG / ENTRY mit TOOLTIP
# ===========================

var icon: TextureRect
var name_label: Label
var rarity_label: Label
var value_label: Label
var separator : HSeparator
var fish_data: Dictionary = {}

# 🎯 TOOLTIP
var tooltip_panel: PanelContainer
var tooltip_label: RichTextLabel
var is_hovering: bool = false

func _ready():
	# Nodes finden
	icon = $VBoxContainer/MarginContainer/Icon
	name_label = $VBoxContainer/NameLabel
	rarity_label = $VBoxContainer/RarityLabel
	value_label = $VBoxContainer/ValueLabel
	separator = $VBoxContainer/VSeparator
	
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
	tooltip_panel.z_index = 1000
	tooltip_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tooltip_panel.top_level = true
	
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
	
	# Custom Font laden
	var custom_font = load("res://fonts/VCR_OSD_MONO_1.001.ttf")
	tooltip_label.add_theme_font_override("normal_font", custom_font)
	tooltip_label.add_theme_font_override("bold_font", custom_font)
	
	# Font Farbe
	tooltip_label.add_theme_color_override("default_color", Color(0.95, 0.95, 0.95))
	
	tooltip_panel.add_child(tooltip_label)
	
	# Tooltip als CanvasLayer hinzufügen
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100
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
	
	# 🎨 RARITY & VALUE & RAHMEN
	if fish_data.get("caught", false):
		var rarity = fish_data["rarity"]
		var rarity_data = FishDB.RARITY_DATA[rarity]
		var rarity_color = rarity_data["color"]
		
		rarity_label.text = rarity_data["name"]
		rarity_label.modulate = rarity_color
		separator.modulate = rarity_color
		rarity_label.add_theme_font_size_override("font_size", 12)
		
		# 💰 VALUE
		value_label.text = "💰 %d" % fish_data["base_value"]
		value_label.add_theme_font_size_override("font_size", 11)
		value_label.show()
		
		# 🎨 RAHMEN IN SELTENHEITS-FARBE
		update_border_color(rarity_color)
		
		# Hintergrund hell
		modulate = Color.WHITE
	else:
		rarity_label.text = "???"
		rarity_label.modulate = Color.GRAY
		rarity_label.add_theme_font_size_override("font_size", 12)
		value_label.hide()
		
		# 🎨 GRAUER RAHMEN für unbekannte Fische
		update_border_color(Color.GRAY)
		
		# Hintergrund grau
		modulate = Color(0.6, 0.6, 0.6)

func update_border_color(color: Color):
	# Erstelle neues StyleBoxFlat mit der gewünschten Border-Farbe
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.0980392, 0.0980392, 0.0980392, 0.572549)
	style_box.border_width_left = 2
	style_box.border_width_top = 2
	style_box.border_width_right = 2
	style_box.border_width_bottom = 2
	style_box.border_color = color  # 🎨 Hier die Seltenheits-Farbe
	style_box.corner_radius_top_left = 5
	style_box.corner_radius_top_right = 5
	style_box.corner_radius_bottom_right = 5
	style_box.corner_radius_bottom_left = 5
	style_box.corner_detail = 13
	
	add_theme_stylebox_override("panel", style_box)

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
		return
	
	is_hovering = true
	
	# Beschreibung aus FishDB holen
	var description = fish_data.get("description", "")
	
	if description == "":
		description = get_description_from_fishdb()
	
	# Tooltip Text zusammenbauen
	var tooltip_text = ""
	
	# Name (groß und fett)
	tooltip_text += "[b][font_size=16]%s[/font_size][/b]\n" % fish_data["name"]
	
	# Seltenheit und Wert
	var rarity_data = FishDB.RARITY_DATA[fish_data["rarity"]]
	tooltip_text += "[color=%s]%s[/color]" % [rarity_data["color"].to_html(), rarity_data["name"]]
	tooltip_text += " • 💰 %d\n" % fish_data["base_value"]
	
	# Höchstes gefangenes Gewicht anzeigen
	var max_weight = Player.get_max_caught_weight(fish_data["name"])
	if max_weight > 0:
		tooltip_text += "\n[color=#FFD700]⚖️ Rekord: %.2f kg[/color]\n" % max_weight
	
	# Beschreibung
	if description != "":
		tooltip_text += "\n[color=#CCCCCC]%s[/color]" % description
	else:
		tooltip_text += "\n[color=#888888][i]Keine Beschreibung verfügbar.[/i][/color]"
	
	tooltip_label.text = tooltip_text
	tooltip_panel.visible = true
	update_tooltip_position()

func get_description_from_fishdb() -> String:
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
	if tooltip_panel and is_instance_valid(tooltip_panel):
		var canvas_layer = tooltip_panel.get_parent()
		if canvas_layer and is_instance_valid(canvas_layer):
			canvas_layer.queue_free()
