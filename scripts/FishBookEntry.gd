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

# 🌍 Localized Texts
var localized_texts := {
	"unknown": {
		"de": "Unbekannt",
		"en": "Unknown"
	},
	"record": {
		"de": "⚖️ Rekord: %.2f kg",
		"en": "⚖️ Record: %.2f kg"
	},
	"no_description": {
		"de": "Keine Beschreibung verfügbar.",
		"en": "No description available."
	}
}

func _ready():
	# Nodes finden
	icon = $VBoxContainer/IconContainer/MarginContainer/Icon
	question_overlay = $VBoxContainer/IconContainer/MarginContainer/QuestionOverlay
	name_label = $VBoxContainer/InfoContainer/MarginContainer/NameLabel
	rarity_label = $VBoxContainer/InfoContainer/StatsContainer/MarginContainer2/RarityLabel
	value_label = $VBoxContainer/InfoContainer/StatsContainer/MarginContainer3/ValueLabel
	separator = $VBoxContainer/InfoContainer/VSeparator
	name_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	rarity_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	value_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	
	# Größe setzen
	size_flags_horizontal = Control.SIZE_FILL
	
	# Mouse Filter
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Tooltip erstellen
	create_tooltip()


# ============================================
# 🌍 LOCALIZATION HELPER
# ============================================

func get_text(key: String) -> String:
	var current_lang = Player.current_language
	if localized_texts.has(key) and localized_texts[key].has(current_lang):
		return localized_texts[key][current_lang]
	elif localized_texts.has(key) and localized_texts[key].has("de"):
		return localized_texts[key]["de"]
	return key

func _get_rarity_key(rarity_name: String) -> String:
	match rarity_name:
		"Normal":
			return "NORMAL"
		"Ungewöhnlich":
			return "UNCOMMON"
		"Selten":
			return "RARE"
		"Episch":
			return "EPIC"
		"Legendär":
			return "LEGENDARY"
		"Exotisch":
			return "EXOTIC"
		"Antik":
			return "ANTIQUE"
		_:
			return "NORMAL"


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
		
		# 🐟 ICON - Steam-Player oder normal
		icon.modulate = Color.WHITE
		
		# 🆕 Prüfe ob Icon ein Texture2D ist (Steam Avatar)
		icon.texture = FishDB.get_fish_icon(fish_data)
		
		# ❓ Fragezeichen ausblenden
		if question_overlay:
			question_overlay.visible = false
		
		# 📝 NAME - Steam-Player oder normal
		var display_name = fish_data.get("name", "???")
		name_label.text = display_name
		name_label.add_theme_font_size_override("font_size", 15)
		
		# 🌍 SELTENHEIT (Übersetzt)
		var rarity_key: String = rarity_data["name_key"]
		rarity_label.text = tr(rarity_key)
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
		
		# 🌍 "Unbekannt" übersetzt
		rarity_label.text = get_text("unknown")
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

	# ----------------------------
	# Vollständige FishDB-Daten
	# ----------------------------
	var fish_id: String = fish_data.get("id", "")
	if fish_id == "":
		return

	var full_fish: Dictionary

	if fish_data.get("is_steam_player", false):
		full_fish = fish_data
	else:
		full_fish = FishDB.get_fish_by_id(fish_id)
	
	if full_fish.is_empty():
		return


	# ----------------------------
	# Name (lokalisiert oder Steam)
	# ----------------------------
	var fish_name : String = fish_data.get("name", FishDB.get_fish_name(full_fish))

	# ----------------------------
	# Beschreibung (lokalisiert)
	# ----------------------------
	var description := FishDB.get_fish_description(full_fish)

	# ----------------------------
	# Rarity
	# ----------------------------
	var rarity: int = full_fish["rarity"]
	var rarity_data: Dictionary = FishDB.RARITY_DATA[rarity]
	var rarity_color: Color = rarity_data["color"]
	var rarity_text: String = tr(rarity_data["name_key"])

	# ----------------------------
	# Tooltip Text
	# ----------------------------
	var tooltip_text := ""
	tooltip_text += "[b][font_size=16]%s[/font_size][/b]\n" % fish_name
	tooltip_text += "[color=%s]%s[/color]" % [rarity_color.to_html(), rarity_text]
	tooltip_text += " • 💰 %d\n" % FishDB.get_fish_value(full_fish)

	# ----------------------------
	# Rekord-Gewicht (ID!)
	# ----------------------------
	var max_weight := Player.get_max_caught_weight(fish_id)
	if max_weight > 0:
		var record_text := get_text("record") % max_weight
		tooltip_text += "\n[color=#FFD700]%s[/color]\n" % record_text

	# ----------------------------
	# Beschreibung
	# ----------------------------
	if description != "":
		tooltip_text += "\n[color=#CCCCCC]%s[/color]" % description
	else:
		tooltip_text += "\n[color=#888888][i]%s[/i][/color]" % get_text("no_description")

	tooltip_label.text = tooltip_text
	tooltip_panel.visible = true
	update_tooltip_position()

func get_description_from_fishdb() -> String:
	var fish_id: String = fish_data.get("id", "")
	if fish_id == "":
		return ""

	var full_fish: Dictionary = FishDB.get_fish_by_id(fish_id)
	if full_fish.is_empty():
		return ""

	return FishDB.get_fish_description(full_fish)

func _on_mouse_exited():
	is_hovering = false
	if tooltip_panel:
		tooltip_panel.visible = false

func _exit_tree():
	if tooltip_panel and is_instance_valid(tooltip_panel):
		var canvas_layer = tooltip_panel.get_parent()
		if canvas_layer and is_instance_valid(canvas_layer):
			canvas_layer.queue_free()
