extends Control

@onready var fish_grid: GridContainer = $PanelContainer/VBoxContainer/ScrollContainer/MarginContainer/FishGrid
@onready var sell_button: Button = $PanelContainer/VBoxContainer/Button
@onready var title_label: Label = $PanelContainer/VBoxContainer/Label
@onready var total_value_label: Label = $PanelContainer/VBoxContainer/TotalValue

@onready var bait_grid: GridContainer = $PanelContainer2/VBoxContainer/ScrollContainer/MarginContainer/BaitGrid
@onready var click: AudioStreamPlayer = $Audio/click


var item_scene := preload("res://scenes/FishingItem.tscn")
var is_open := false

var context_menu: PanelContainer = null
var context_menu_canvas: CanvasLayer = null
var context_menu_index: int = -1

func _ready() -> void:
	visible = false
	sell_button.pressed.connect(_on_sell_all_pressed)
	visibility_changed.connect(_on_visibility_changed)

	if fish_grid:
		fish_grid.columns = 3
	_build_context_menu()  # 🆕
	refresh()
	
func _build_context_menu() -> void:
	# CanvasLayer damit es über allem liegt
	context_menu_canvas = CanvasLayer.new()
	context_menu_canvas.layer = 100
	add_child(context_menu_canvas)

	context_menu = PanelContainer.new()
	context_menu.visible = false
	context_menu.mouse_filter = Control.MOUSE_FILTER_STOP
	context_menu.top_level = true
	context_menu.z_index = 1000

	# Gleicher Style wie FishBookItem Tooltip
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 0.95)
	style.border_color = Color(0.8, 0.6, 0.2)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_left = 5
	style.corner_radius_bottom_right = 5
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	context_menu.add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(180, 0)
	vbox.add_theme_constant_override("separation", 4)
	context_menu.add_child(vbox)

	# --- Header: Fisch-Name + Rarity (wird beim Öffnen befüllt) ---
	var header := RichTextLabel.new()
	header.name = "Header"
	header.bbcode_enabled = true
	header.fit_content = true
	header.scroll_active = false
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.custom_minimum_size = Vector2(160, 0)
	var custom_font = load("res://fonts/VCR_OSD_MONO_1.001.ttf")
	header.add_theme_font_override("normal_font", custom_font)
	header.add_theme_font_override("bold_font", custom_font)
	header.add_theme_font_size_override("normal_font_size", 12)
	header.add_theme_font_size_override("bold_font_size", 12)
	header.add_theme_color_override("default_color", Color(0.95, 0.95, 0.95))
	vbox.add_child(header)

	# --- Trennlinie ---
	var sep := HSeparator.new()
	sep.modulate = Color(0.8, 0.6, 0.2, 0.5)
	sep.MOUSE_FILTER_IGNORE
	vbox.add_child(sep)

	# --- Buttons ---
	var sell_btn := _make_menu_button("💰 " + tr("FISH_ACTION_SELL"), Color(1.0, 0.8, 0.2))
	sell_btn.name = "SellBtn"
	sell_btn.pressed.connect(_on_context_sell)
	vbox.add_child(sell_btn)

	var bait_btn := _make_menu_button("🎣 " + tr("FISH_ACTION_USE_AS_BAIT"), Color(0.3, 1.0, 0.5))
	bait_btn.name = "BaitBtn"
	bait_btn.pressed.connect(_on_context_use_as_bait)
	vbox.add_child(bait_btn)

	context_menu_canvas.add_child(context_menu)

func _make_menu_button(label_text: String, hover_color: Color) -> Button:
	var btn := Button.new()
	btn.text = label_text
	btn.flat = true
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.custom_minimum_size = Vector2(0, 32)
	btn.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	btn.add_theme_color_override("font_hover_color", hover_color)
	btn.add_theme_color_override("font_pressed_color", hover_color)
	var custom_font = load("res://fonts/VCR_OSD_MONO_1.001.ttf")
	btn.add_theme_font_override("font", custom_font)
	btn.add_theme_font_size_override("font_size", 13)

	# Hover-Hintergrund
	var hover_style := StyleBoxFlat.new()
	hover_style.bg_color = Color(hover_color.r, hover_color.g, hover_color.b, 0.12)
	hover_style.corner_radius_top_left = 4
	hover_style.corner_radius_top_right = 4
	hover_style.corner_radius_bottom_left = 4
	hover_style.corner_radius_bottom_right = 4
	btn.add_theme_stylebox_override("hover", hover_style)

	var empty_style := StyleBoxEmpty.new()
	btn.add_theme_stylebox_override("normal", empty_style)
	btn.add_theme_stylebox_override("pressed", empty_style)
	btn.add_theme_stylebox_override("focus", empty_style)

	return btn

# Header beim Öffnen mit Fisch-Daten befüllen
func _update_context_menu_header(fish: Dictionary) -> void:
	var vbox: VBoxContainer = context_menu.get_child(0)
	if not vbox:
		return
	var header: RichTextLabel = vbox.get_node_or_null("Header")
	if not header:
		return

	var fish_name := FishDB.get_fish_name(fish)
	# Namen kürzen wenn zu lang
	if fish_name.length() > 16:
		fish_name = fish_name.substr(0, 14) + ".."

	var rarity_enum: int = fish.get("rarity", FishDB.RARITY.NORMAL)
	var rarity_data: Dictionary = FishDB.RARITY_DATA[rarity_enum]
	var rarity_color: Color = rarity_data["color"]
	var rarity_text: String = tr(rarity_data["name_key"])
	var value := FishDB.get_fish_value(fish)

	# Alles in einer Zeile
	header.text = "[b]%s[/b]  [color=%s]%s[/color]  💰%d" % [
		fish_name,
		rarity_color.to_html(),
		rarity_text,
		value
	]
func _on_item_clicked(event: InputEvent, index: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT:
			if index < 0 or index >= Inventory.fish_inventory.size():
				return
			context_menu_index = index
			_update_context_menu_header(Inventory.fish_inventory[index])
			context_menu.visible = true
			# Position an Maus
			var mouse_pos := get_viewport().get_mouse_position()
			var viewport_size := get_viewport().get_visible_rect().size
			await get_tree().process_frame  # warte einen Frame damit size korrekt ist
			var menu_size := context_menu.size
			var pos_x := mouse_pos.x + 10
			var pos_y := mouse_pos.y - menu_size.y / 2
			pos_x = min(pos_x, viewport_size.x - menu_size.x - 5)
			pos_y = clamp(pos_y, 5, viewport_size.y - menu_size.y - 5)
			context_menu.position = Vector2(pos_x, pos_y)

# Klick außerhalb schließt Menü
func _input(event: InputEvent) -> void:
	if context_menu and context_menu.visible:
		if event is InputEventMouseButton and event.pressed:
			var menu_rect := Rect2(context_menu.position, context_menu.size)
			if not menu_rect.has_point(get_viewport().get_mouse_position()):
				context_menu.visible = false
				context_menu_index = -1

func _on_context_sell() -> void:
	context_menu.visible = false
	_sell_single_fish(context_menu_index)
	context_menu_index = -1

func _on_context_use_as_bait() -> void:
	context_menu.visible = false
	_use_fish_as_bait(context_menu_index)
	context_menu_index = -1
	

func _sell_single_fish(index: int) -> void:
	if index < 0 or index >= Inventory.fish_inventory.size():
		return

	var fish = Inventory.fish_inventory[index]
	var value := FishDB.get_fish_value(fish)
	var fish_name := FishDB.get_fish_name(fish)

	if Player.get_total_fish_caught() > 0:
		SteamAchievements.on_first_sale()

	Inventory.remove_fish(index)
	Player.add_money(value)

	print("🐟 Verkauft: %s für %d $" % [fish_name, value])
	click.play()
	refresh()

# 🆕 Fisch als Köder nutzen
func _use_fish_as_bait(index: int) -> void:
	if index < 0 or index >= Inventory.fish_inventory.size():
		return

	var fish = Inventory.fish_inventory[index]
	var fish_name := FishDB.get_fish_name(fish)

	var success : bool= Player.use_fish_as_bait(fish, index)

	if success:
		print("🎣 Fisch als Köder verwendet: %s" % fish_name)
		click.play()
		refresh()
	else:
		print("❌ Fisch konnte nicht als Köder verwendet werden")

func _on_visibility_changed() -> void:
	if visible:
		is_open = true
		refresh()
	else:
		is_open = false
		if context_menu and context_menu.visible:
			context_menu.visible = false
			context_menu_index = -1

func toggle() -> void:
	is_open = !is_open
	visible = is_open
	if not is_open and context_menu and context_menu.visible:
		context_menu.visible = false
		context_menu_index = -1

func refresh() -> void:
	# ----------------------------
	# 🧹 GRIDS LEEREN
	# ----------------------------
	for child in fish_grid.get_children():
		child.queue_free()

	for child in bait_grid.get_children():
		child.queue_free()

	var total_value := 0
	var fish_count := Inventory.fish_inventory.size()

	# ----------------------------
	# 🐟 FISCHE LADEN
	# ----------------------------
	for i in range(fish_count):
		var f = Inventory.fish_inventory[i]
		
		# 🔧 DEBUG: Steam-Player erkennen
		if f.get("is_steam_player", false):
			print("🔧 [InventoryUI] Zeige Steam-Player:")
			print("  - ID:", f.get("id"))
			print("  - Name:", f.get("steam_name", "FEHLT"))
			print("  - Hat steam_avatar:", f.has("steam_avatar"))
			print("  - Avatar Typ:", typeof(f.get("steam_avatar")))
		
		var item := item_scene.instantiate()

		var rarity = f.get("rarity", FishDB.RARITY.NORMAL)
		var rarity_data = FishDB.RARITY_DATA[rarity]
		var rarity_color: Color = rarity_data["color"]

		# Style
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.15, 0.15, 0.15, 0.9)
		style.border_width_left = 3
		style.border_width_top = 3
		style.border_width_right = 3
		style.border_width_bottom = 3
		style.border_color = rarity_color
		style.corner_radius_top_left = 8
		style.corner_radius_top_right = 8
		style.corner_radius_bottom_left = 8
		style.corner_radius_bottom_right = 8
		style.shadow_size = 4
		style.shadow_color = Color(0, 0, 0, 0.5)
		item.add_theme_stylebox_override("panel", style)

		# Icon - 🆕 Unterstützt Texture2D für Steam-Avatare
		var icon: TextureRect = item.get_node("VBoxContainer/IconContainer/MarginContainer/FishIcon")
		var fish_icon = _get_fish_icon(f)
		if fish_icon is Texture2D:
			icon.texture = fish_icon
		elif fish_icon is String and ResourceLoader.exists(fish_icon):
			icon.texture = load(fish_icon)
		else:
			icon.texture = load("res://assets/fish/unknown.png")

		# ✅ FIX: Name über FishDB.get_fish_name() oder steam_name
		var fish_name := FishDB.get_fish_name(f)
		item.get_node("VBoxContainer/InfoContainer/MarginContainer/Name").text = fish_name

		# ✅ FIX: Rarity über get_rarity_name_key()
		var rarity_label: Label = item.get_node("VBoxContainer/InfoContainer/MarginContainer2/Rarity")
		var rarity_key := FishDB.get_rarity_name_key(f)
		rarity_label.text = tr(rarity_key)
		rarity_label.modulate = rarity_color

		# Gewicht
		var weight_label: Label = item.get_node("VBoxContainer/InfoContainer/StatsContainer/MarginContainer3/Weight")
		if f.has("weight"):
			weight_label.text = "⚖️ %.2f kg" % f["weight"]
		else:
			weight_label.text = "⚖️ ??? kg"

		# Wert
		var value := FishDB.get_fish_value(f)
		item.get_node("VBoxContainer/InfoContainer/StatsContainer/MarginContainer4/Value").text = "💰 %d $" % value
		total_value += value

		# Rechtsklick verkaufen
		item.gui_input.connect(_on_item_clicked.bind(i))

		fish_grid.add_child(item)
		
		item.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		item.mouse_filter = Control.MOUSE_FILTER_STOP

# Hover-Effekt
		item.mouse_entered.connect(func():
			var hover_style := StyleBoxFlat.new()
			hover_style.bg_color = Color(0.22, 0.22, 0.22, 0.95)
			hover_style.border_width_left = 3
			hover_style.border_width_top = 3
			hover_style.border_width_right = 3
			hover_style.border_width_bottom = 3
			hover_style.border_color = rarity_color.lightened(0.3)
			hover_style.corner_radius_top_left = 8
			hover_style.corner_radius_top_right = 8
			hover_style.corner_radius_bottom_left = 8
			hover_style.corner_radius_bottom_right = 8
			hover_style.shadow_size = 6
			hover_style.shadow_color = Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.4)
			item.add_theme_stylebox_override("panel", hover_style)
			item.scale = Vector2(1.04, 1.04)
			item.pivot_offset = item.size / 2
		)

		item.mouse_exited.connect(func():
			item.add_theme_stylebox_override("panel", style)  # zurück zum Original-Style
			item.scale = Vector2.ONE
		)

		# Fade-in
		item.modulate.a = 0
		create_tween().tween_property(item, "modulate:a", 1.0, 0.3).set_delay(i * 0.05)

	# ----------------------------
	# 🎣 KÖDER LADEN
	# ----------------------------
	var bait_colors := {
		"Common": Color(0.4, 0.4, 0.4),
		"Uncommon": Color(0.4, 0.8, 0.4),
		"Rare": Color(0.3, 0.5, 1.0),
		"Epic": Color(0.7, 0.3, 1.0),
		"Legendary": Color(1.0, 0.6, 0.0),
		"Exotic": Color(1.0, 0.2, 0.5)
	}

	for rarity in Player.bait_inventory.keys():
		var amount: int = Player.bait_inventory[rarity]
		if amount <= 0:
			continue

		var bait_item := PanelContainer.new()

		var style_bait := StyleBoxFlat.new()
		style_bait.bg_color = Color(0.12, 0.12, 0.12, 0.9)
		style_bait.border_width_left = 3
		style_bait.border_color = bait_colors.get(rarity, Color.WHITE)
		style_bait.corner_radius_top_left = 6
		style_bait.corner_radius_top_right = 6
		style_bait.corner_radius_bottom_left = 6
		style_bait.corner_radius_bottom_right = 6
		bait_item.add_theme_stylebox_override("panel", style_bait)

		var vbox := VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.custom_minimum_size = Vector2(180, 0)

		# ✅ FIX: Köder-Namen über FishDB Translation System
		var bait_title := Label.new()
		var rarity_enum := FishDB.rarity_string_to_enum(rarity)
		if rarity_enum != -1:
			var rarity_key: String = FishDB.RARITY_DATA[rarity_enum]["name_key"]
			bait_title.text = tr(rarity_key) + " " + tr("BAIT_SUFFIX")
		else:
			bait_title.text = rarity + " Bait"
		bait_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

		var amount_label := Label.new()
		amount_label.text = "x%d" % amount
		amount_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

		# ✅ FIX: Buttons über Translation Keys
		var activate_button := Button.new()
		activate_button.text = tr("BAIT_ACTIVATE")
		activate_button.custom_minimum_size = Vector2(0, 35)

		activate_button.pressed.connect(func():
			_on_activate_bait_pressed(rarity)
		)

		if Player.active_bait == rarity:
			activate_button.text = tr("BAIT_ACTIVE")
			activate_button.disabled = true
			activate_button.modulate = Color(0.3, 1.0, 0.3)

		vbox.add_child(bait_title)
		vbox.add_child(amount_label)
		vbox.add_child(activate_button)

		bait_item.add_child(vbox)
		bait_grid.add_child(bait_item)

		# Fade
		bait_item.modulate.a = 0
		create_tween().tween_property(bait_item, "modulate:a", 1.0, 0.3)

	# ----------------------------
	# 📊 UI UPDATE
	# ----------------------------
	title_label.text = tr("INVENTORY_TITLE") + " (%d)" % fish_count
	total_value_label.text = tr("INVENTORY_TOTAL_VALUE") + ": %d $" % total_value

	if fish_count > 0:
		sell_button.text = tr("INVENTORY_SELL_ALL") + " (%d $)" % total_value
		sell_button.disabled = false
	else:
		sell_button.text = tr("INVENTORY_NO_FISH")
		sell_button.disabled = true


func _get_fish_icon(fish: Dictionary):
	# 🆕 Prüfe ob Icon bereits ein Texture2D ist (Steam-Avatar)
	if fish.has("steam_avatar") and fish["steam_avatar"] is Texture2D:
		return fish["steam_avatar"]
	
	# Sonst nutze normales Icon-System
	return FishDB.get_fish_icon(fish)

func _on_sell_all_pressed() -> void:
	if Inventory.fish_inventory.is_empty():
		return
	click.play()
	var money := Inventory.get_total_value()
	var fish_count := Inventory.fish_inventory.size()
	
	if Player.get_total_fish_caught() > 0:
		SteamAchievements.on_first_sale()
	
	Inventory.clear_inventory()
	Player.add_money(money)

	print("💰 Alle %d Fische verkauft für: %d $" % [fish_count, money])
	refresh()

func _on_activate_bait_pressed(rarity: String) -> void:
	if Player.activate_bait(rarity):
		print("🎣 Köder aktiviert:", rarity)
		click.play()
	else:
		print("❌ Kein Köder verfügbar:", rarity)

	refresh()

func _on_close_pressed() -> void:
	click.play()
	toggle()
