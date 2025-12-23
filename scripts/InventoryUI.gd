extends Control

@onready var fish_grid: GridContainer = $PanelContainer/VBoxContainer/ScrollContainer/MarginContainer/FishGrid
@onready var sell_button: Button = $PanelContainer/VBoxContainer/Button
@onready var title_label: Label = $PanelContainer/VBoxContainer/Label
@onready var total_value_label: Label = $PanelContainer/VBoxContainer/TotalValue

@onready var bait_grid: GridContainer = $PanelContainer2/VBoxContainer/ScrollContainer/MarginContainer/BaitGrid

var item_scene := preload("res://scenes/FishingItem.tscn")
var is_open := false

# 🌍 Localized Texts
var localized_texts := {
	"inventory_title": {
		"de": "Inventar (%d Fische)",
		"en": "Inventory (%d Fish)"
	},
	"total_value": {
		"de": "Gesamtwert: %d €",
		"en": "Total Value: %d €"
	},
	"sell_all": {
		"de": "Alle verkaufen (%d €)",
		"en": "Sell All (%d €)"
	},
	"no_fish": {
		"de": "Keine Fische zum Verkaufen",
		"en": "No Fish to Sell"
	},
	"unknown_fish": {
		"de": "Unbekannter Fisch",
		"en": "Unknown Fish"
	},
	"bait_suffix": {
		"de": "-Köder",
		"en": " Bait"
	},
	"activate": {
		"de": "Aktivieren",
		"en": "Activate"
	},
	"active": {
		"de": "Aktiv ✔",
		"en": "Active ✔"
	}
}

func _ready() -> void:
	visible = false
	sell_button.pressed.connect(_on_sell_all_pressed)
	visibility_changed.connect(_on_visibility_changed)

	if fish_grid:
		fish_grid.columns = 3

	refresh()


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

		# Icon
		var icon: TextureRect = item.get_node("VBoxContainer/IconContainer/MarginContainer/FishIcon")
		icon.texture = _get_fish_icon(f)

		# Name (🌍 Mit Fallback)
		item.get_node("VBoxContainer/InfoContainer/MarginContainer/Name").text = str(f.get("name", get_text("unknown_fish")))

		# Rarity (🌍 Übersetzt)
		var rarity_label: Label = item.get_node("VBoxContainer/InfoContainer/MarginContainer2/Rarity")
		var rarity_name = rarity_data["name"]
		var rarity_key = _get_rarity_key(rarity_name)
		rarity_label.text = tr(rarity_key)
		rarity_label.modulate = rarity_color

		# Gewicht
		var weight_label: Label = item.get_node("VBoxContainer/InfoContainer/StatsContainer/MarginContainer3/Weight")
		if f.has("weight"):
			weight_label.text = "⚖️ %.2f kg" % f["weight"]
		else:
			weight_label.text = "⚖️ ??? kg"

		# Wert
		var value := int(f["base_value"] * rarity_data["value"])
		item.get_node("VBoxContainer/InfoContainer/StatsContainer/MarginContainer4/Value").text = "💰 %d €" % value
		total_value += value

		# Rechtsklick verkaufen
		item.gui_input.connect(_on_item_clicked.bind(i))

		fish_grid.add_child(item)

		# Fade-in
		item.modulate.a = 0
		create_tween().tween_property(item, "modulate:a", 1.0, 0.3).set_delay(i * 0.05)


	# ----------------------------
	# 🎣 KÖDER LADEN
	# ----------------------------
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
		style_bait.border_color = bait_colors.get(rarity, Color.WHITE)
		style_bait.corner_radius_top_left = 6
		style_bait.corner_radius_top_right = 6
		style_bait.corner_radius_bottom_left = 6
		style_bait.corner_radius_bottom_right = 6
		bait_item.add_theme_stylebox_override("panel", style_bait)

		var vbox := VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.custom_minimum_size = Vector2(180, 110)

		# 🌍 Köder-Titel übersetzt
		var bait_title := Label.new()
		var rarity_translated = tr(rarity.to_upper())
		bait_title.text = rarity_translated + get_text("bait_suffix")
		bait_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

		var amount_label := Label.new()
		amount_label.text = "x%d" % amount
		amount_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

		# 🌍 Aktivieren-Button übersetzt
		var activate_button := Button.new()
		activate_button.text = get_text("activate")
		activate_button.custom_minimum_size = Vector2(0, 35)

		activate_button.pressed.connect(func():
			_on_activate_bait_pressed(rarity)
		)

		if Player.active_bait == rarity:
			activate_button.text = get_text("active")
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
	# 📊 UI UPDATE (🌍 Übersetzt)
	# ----------------------------
	title_label.text = get_text("inventory_title") % fish_count
	total_value_label.text = get_text("total_value") % total_value

	if fish_count > 0:
		sell_button.text = get_text("sell_all") % total_value
		sell_button.disabled = false
	else:
		sell_button.text = get_text("no_fish")
		sell_button.disabled = true


# 🌍 Rarity Name → Translation Key
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
	if  Player.get_total_fish_caught() > 0:
		SteamAchievements.on_first_sale()

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
	if  Player.get_total_fish_caught() > 0:
		SteamAchievements.on_first_sale()
	Inventory.clear_inventory()
	Player.add_money(money)

	print("💰 Alle %d Fische verkauft für: %d €" % [fish_count, money])
	refresh()

func _on_activate_bait_pressed(rarity: String) -> void:
	if Player.activate_bait(rarity):
		print("🎣 Köder aktiviert:", rarity)
	else:
		print("❌ Kein Köder verfügbar:", rarity)

	refresh()


func _on_close_pressed() -> void:
	toggle()
