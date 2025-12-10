extends Control

@onready var fish_grid: GridContainer = $PanelContainer/VBoxContainer/ScrollContainer/MarginContainer/FishGrid
@onready var sell_button: Button = $PanelContainer/VBoxContainer/Button
@onready var title_label: Label = $PanelContainer/VBoxContainer/Label
@onready var total_value_label: Label = $PanelContainer/VBoxContainer/TotalValue

@onready var bait_grid: GridContainer = $PanelContainer2/VBoxContainer/ScrollContainer/MarginContainer/BaitGrid

var item_scene := preload("res://scenes/FishingItem.tscn")
var is_open := false

func _ready() -> void:
	visible = false
	sell_button.pressed.connect(_on_sell_all_pressed)
	visibility_changed.connect(_on_visibility_changed)

	if fish_grid:
		fish_grid.columns = 4

	refresh()


func _on_visibility_changed() -> void:
	if visible:
		is_open = true
		refresh()
	else:
		is_open = false


func toggle() -> void:
	is_open = !is_open
	visible = is_open


func refresh() -> void:
	# ---------------------------------
	# 🐟 FISCHE LADEN
	# ---------------------------------
	for child in fish_grid.get_children():
		child.queue_free()

	for child in bait_grid.get_children():
		child.queue_free()

	var total_value := 0
	var fish_count := Inventory.fish_inventory.size()

	for i in range(fish_count):
		var f: Dictionary = Inventory.fish_inventory[i]
		var item: PanelContainer = item_scene.instantiate()

		var rarity = f.get("rarity", FishDB.RARITY.NORMAL)
		var rarity_data = FishDB.RARITY_DATA[rarity]
		var rarity_color: Color = rarity_data["color"]

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

		var icon: TextureRect = item.get_node("VBoxContainer/IconContainer/MarginContainer/FishIcon")
		icon.texture = _get_fish_icon(f)

		var name_label: Label = item.get_node("VBoxContainer/InfoContainer/MarginContainer/Name")
		name_label.text = str(f.get("name", "Unbekannter Fisch"))

		var rarity_label: Label = item.get_node("VBoxContainer/InfoContainer/MarginContainer2/Rarity")
		rarity_label.text = rarity_data["name"]
		rarity_label.modulate = rarity_color

		var weight_label: Label = item.get_node("VBoxContainer/InfoContainer/StatsContainer/MarginContainer3/Weight")
		if f.has("weight"):
			weight_label.text = "⚖️ %.2f kg" % f["weight"]
		else:
			weight_label.text = "⚖️ ??? kg"

		var value := int(f["base_value"] * rarity_data["value"])
		var value_label: Label = item.get_node("VBoxContainer/InfoContainer/StatsContainer/MarginContainer4/Value")
		value_label.text = "💰 %d €" % value

		total_value += value

		item.gui_input.connect(_on_item_clicked.bind(i))

		fish_grid.add_child(item)

		item.modulate.a = 0.0
		var tween = create_tween()
		tween.tween_property(item, "modulate:a", 1.0, 0.3).set_delay(i * 0.05)

	# ---------------------------------
	# 🎣 KÖDER LADEN
	# ---------------------------------
	var bait_colors := {
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
		style_bait.border_width_top = 3
		style_bait.border_width_right = 3
		style_bait.border_width_bottom = 3
		style_bait.corner_radius_top_left = 6
		style_bait.corner_radius_top_right = 6
		style_bait.corner_radius_bottom_left = 6
		style_bait.corner_radius_bottom_right = 6
		style_bait.border_color = bait_colors.get(rarity, Color.WHITE)

		bait_item.add_theme_stylebox_override("panel", style_bait)

		var vbox := VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER

		var bait_title := Label.new()
		bait_title.text = "%s-Köder" % rarity
		bait_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

		var amount_label := Label.new()
		amount_label.text = "x%d" % amount
		amount_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

		vbox.add_child(bait_title)
		vbox.add_child(amount_label)
		bait_item.add_child(vbox)

		bait_grid.add_child(bait_item)

		bait_item.modulate.a = 0.0
		create_tween().tween_property(bait_item, "modulate:a", 1.0, 0.3)

	# ---------------------------------
	# 📊 UI-TEXTE
	# ---------------------------------
	title_label.text = "Inventar (%d Fische)" % fish_count
	if total_value_label:
		total_value_label.text = "Gesamtwert: %d €" % total_value

	if fish_count > 0:
		sell_button.text = "Alle verkaufen (%d €)" % total_value
		sell_button.disabled = false
	else:
		sell_button.text = "Keine Fische zum Verkaufen"
		sell_button.disabled = true


func _on_item_clicked(event: InputEvent, index: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		_sell_single_fish(index)


func _sell_single_fish(index: int) -> void:
	if index < 0 or index >= Inventory.fish_inventory.size():
		return

	var fish = Inventory.fish_inventory[index]
	var rarity = fish.get("rarity", FishDB.RARITY.NORMAL)
	var rarity_data = FishDB.RARITY_DATA[rarity]
	var value = int(fish["base_value"] * rarity_data["value"])

	Inventory.remove_fish(index)
	Player.add_money(value)

	print("🐟 Verkauft: %s für %d €" % [fish["name"], value])
	refresh()


func _get_fish_icon(fish: Dictionary) -> Texture2D:
	if fish.has("icon"):
		var icon_path: String = fish["icon"]
		var texture: Texture2D = load(icon_path)
		if texture:
			return texture
	return preload("res://assets/fish/fish1.png")


func _on_sell_all_pressed() -> void:
	if Inventory.fish_inventory.is_empty():
		return

	var money := Inventory.get_total_value()
	var fish_count := Inventory.fish_inventory.size()

	Inventory.clear_inventory()
	Player.add_money(money)

	print("💰 Alle %d Fische verkauft für: %d €" % [fish_count, money])
	refresh()


func _on_close_pressed() -> void:
	toggle()
