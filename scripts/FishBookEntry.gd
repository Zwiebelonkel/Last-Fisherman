extends PanelContainer

var icon: TextureRect
var question_overlay: Label
var name_label: Label
var rarity_label: Label
var value_label: Label
var separator: HSeparator
var fish_data: Dictionary = {}

# 🎯 TOOLTIP
var tooltip_panel: PanelContainer
var tooltip_label: RichTextLabel
var is_hovering: bool = false

# 🆕 Referenz zum FishBook UI
var fishbook_ui: Control = null

func _ready():
	# Nodes finden
	icon = $VBoxContainer/IconContainer/MarginContainer/Icon
	question_overlay = $VBoxContainer/IconContainer/MarginContainer/QuestionOverlay
	name_label = $VBoxContainer/InfoContainer/MarginContainer/NameLabel
	rarity_label = $VBoxContainer/InfoContainer/StatsContainer/MarginContainer2/RarityLabel
	value_label = $VBoxContainer/InfoContainer/StatsContainer/MarginContainer3/ValueLabel
	separator = $VBoxContainer/InfoContainer/VSeparator
	
	# Größe setzen
	custom_minimum_size = Vector2(160, 190)
	
	# Mouse Filter
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Tooltip erstellen
	create_tooltip()

func set_fishbook_ui(ui: Control):
	fishbook_ui = ui

func set_fish_data(data: Dictionary):
	fish_data = data
	
	if not is_node_ready():
		await ready
	
	update_display()

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if fish_data.get("caught", false):
				show_fish_details()

func show_fish_details():
	if fishbook_ui and fishbook_ui.has_method("show_fish_detail_popup"):
		fishbook_ui.show_fish_detail_popup(fish_data)
	else:
		# Fallback: Suche in Parent-Hierarchie
		var parent = get_parent()
		var depth = 0
		while parent and depth < 10:
			if parent.has_method("show_fish_detail_popup"):
				parent.show_fish_detail_popup(fish_data)
				return
			parent = parent.get_parent()
			depth += 1

func update_display():
	if fish_data.is_empty():
		return
	
	if icon == null or name_label == null or rarity_label == null or value_label == null:
		return
	
	# 🎨 RARITY & VALUE & RAHMEN
	if fish_data.get("caught", false):
		var rarity = fish_data["rarity"]
		var rarity_data = FishDB.RARITY_DATA[rarity]
		var rarity_color = rarity_data["color"]
		
		# 🐟 ICON - normal sichtbar
		icon.modulate = Color.WHITE
		if fish_data.has("icon") and ResourceLoader.exists(fish_data["icon"]):
			icon.texture = load(fish_data["icon"])
		
		# ❓ Fragezeichen ausblenden
		if question_overlay:
			question_overlay.visible = false
		
		# 📝 NAME
		name_label.text = fish_data["name"]
		name_label.add_theme_font_size_override("font_size", 15)
		
		# 🎨 SELTENHEIT
		rarity_label.text = rarity_data["name"]
		rarity_label.modulate = rarity_color
		separator.modulate = rarity_color
		rarity_label.add_theme_font_size_override("font_size", 12)
		
		# 💰 VALUE
		value_label.text = "💰 %d" % fish_data["base_value"]
		value_label.add_theme_font_size_override("font_size", 12)
		value_label.show()
		
		# 🎨 RAHMEN IN SELTENHEITS-FARBE
		update_border_color(rarity_color)
		
		# Hintergrund normal
		modulate = Color.WHITE
		
		# ✨ Glow-Effekt bei hohen Seltenheiten
		if rarity >= FishDB.RARITY.EPISCH:
			add_glow_effect(rarity_color)
		
	else:
		# 🔒 UNBEKANNTER FISCH
		icon.modulate = Color(0.3, 0.3, 0.3, 0.5)
		
		if question_overlay:
			question_overlay.visible = true
		
		name_label.text = "???"
		name_label.add_theme_font_size_override("font_size", 15)
		
		rarity_label.text = "Unbekannt"
		rarity_label.modulate = Color.GRAY
		separator.modulate = Color.GRAY
		rarity_label.add_theme_font_size_override("font_size", 12)
		
		value_label.hide()
		
		update_border_color(Color(0.4, 0.4, 0.4, 1))
		
		modulate = Color(0.7, 0.7, 0.7)

func update_border_color(color: Color):
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.12, 0.12, 0.12, 0.85)
	style_box.border_width_left = 3
	style_box.border_width_top = 3
	style_box.border_width_right = 3
	style_box.border_width_bottom = 3
	style_box.border_color = color
	style_box.corner_radius_top_left = 10
	style_box.corner_radius_top_right = 10
	style_box.corner_radius_bottom_right = 10
	style_box.corner_radius_bottom_left = 10
	style_box.corner_detail = 13
	style_box.shadow_size = 6
	style_box.shadow_offset = Vector2(0, 3)
	style_box.shadow_color = Color(0, 0, 0, 0.6)
	
	add_theme_stylebox_override("panel", style_box)

func add_glow_effect(color: Color):
	var tween = create_tween().set_loops()
	tween.tween_property(self, "modulate:a", 0.9, 1.0)
	tween.tween_property(self, "modulate:a", 1.0, 1.0)

func create_tooltip():
	tooltip_panel = PanelContainer.new()
	tooltip_panel.visible = false
	tooltip_panel.z_index = 1000
	tooltip_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tooltip_panel.top_level = true
	
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
	
	tooltip_label = RichTextLabel.new()
	tooltip_label.bbcode_enabled = true
	tooltip_label.fit_content = true
	tooltip_label.scroll_active = false
	tooltip_label.custom_minimum_size = Vector2(200, 0)
	
	var custom_font = load("res://fonts/VCR_OSD_MONO_1.001.ttf")
	tooltip_label.add_theme_font_override("normal_font", custom_font)
	tooltip_label.add_theme_font_override("bold_font", custom_font)
	tooltip_label.add_theme_color_override("default_color", Color(0.95, 0.95, 0.95))
	
	tooltip_panel.add_child(tooltip_label)
	
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100
	canvas_layer.add_child(tooltip_panel)
	get_tree().root.add_child(canvas_layer)

func _process(_delta):
	if is_hovering and tooltip_panel and tooltip_panel.visible:
		update_tooltip_position()

func update_tooltip_position():
	var mouse_pos = get_viewport().get_mouse_position()
	var tooltip_size = tooltip_panel.size
	var viewport_size = get_viewport().get_visible_rect().size
	
	var target_x = mouse_pos.x + 15
	var target_y = mouse_pos.y - tooltip_size.y / 2
	
	if target_x + tooltip_size.x > viewport_size.x:
		target_x = mouse_pos.x - tooltip_size.x - 15
	
	if target_y < 0:
		target_y = 0
	elif target_y + tooltip_size.y > viewport_size.y:
		target_y = viewport_size.y - tooltip_size.y
	
	tooltip_panel.position = Vector2(target_x, target_y)

func _notification(what):
	if what == NOTIFICATION_MOUSE_ENTER:
		_on_mouse_entered()
	elif what == NOTIFICATION_MOUSE_EXIT:
		_on_mouse_exited()

func _on_mouse_entered():
	if not fish_data.get("caught", false):
		return
	
	is_hovering = true
	
	var description = fish_data.get("description", "")
	if description == "":
		description = get_description_from_fishdb()
	
	var tooltip_text = ""
	tooltip_text += "[b][font_size=16]%s[/font_size][/b]\n" % fish_data["name"]
	
	var rarity_data = FishDB.RARITY_DATA[fish_data["rarity"]]
	tooltip_text += "[color=%s]%s[/color]" % [rarity_data["color"].to_html(), rarity_data["name"]]
	tooltip_text += " • 💰 %d\n" % fish_data["base_value"]
	
	var max_weight = Player.get_max_caught_weight(fish_data["name"])
	if max_weight > 0:
		tooltip_text += "\n[color=#FFD700]⚖️ Rekord: %.2f kg[/color]\n" % max_weight
	
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
