extends Control

@onready var fish_grid: GridContainer = $PanelContainer/VBoxContainer/ScrollContainer/MarginContainer/FishGrid
@onready var sell_button: Button = $PanelContainer/VBoxContainer/Button
@onready var title: Label = $PanelContainer/VBoxContainer/Label
@onready var total_value_label: Label = $PanelContainer/VBoxContainer/TotalValue

var item_scene := preload("res://scenes/FishingItem.tscn")
var is_open := false

func _ready() -> void:
	print("FishGrid =", fish_grid)
	visible = false
	sell_button.pressed.connect(_on_sell_all_pressed)
	
	# Signal verbinden
	visibility_changed.connect(_on_visibility_changed)
	
	# Grid-Einstellungen für besseres Layout
	if fish_grid:
		fish_grid.columns = 4  # 4 Karten pro Reihe
	
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
	# Kinder im Grid löschen
	for child in fish_grid.get_children():
		child.queue_free()
	
	var total_value = 0
	var fish_count = Inventory.fish_inventory.size()
	
	for i in range(fish_count):
		var f = Inventory.fish_inventory[i]
		var item = item_scene.instantiate()
		
		# 🎨 Rahmenfarbe basierend auf Seltenheit
		var rarity = f.get("rarity", FishDB.RARITY.NORMAL)
		var rarity_data = FishDB.RARITY_DATA[rarity]
		var rarity_color = rarity_data["color"]
		
		# StyleBox mit Seltenheits-Farbe
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.15, 0.15, 0.15, 0.9)
		style.border_width_left = 3
		style.border_width_top = 3
		style.border_width_right = 3
		style.border_width_bottom = 3
		style.border_color = rarity_color
		style.corner_radius_top_left = 8
		style.corner_radius_top_right = 8
		style.corner_radius_bottom_right = 8
		style.corner_radius_bottom_left = 8
		style.shadow_size = 4
		style.shadow_color = Color(0, 0, 0, 0.5)
		
		item.add_theme_stylebox_override("panel", style)
		
		# 🐟 Icon
		var icon: TextureRect = item.get_node("VBoxContainer/IconContainer/MarginContainer/FishIcon")
		icon.texture = _get_fish_icon(f)
		
		# 📝 Name
		var name_label: Label = item.get_node("VBoxContainer/InfoContainer/MarginContainer/Name")
		name_label.text = str(f.get("name", "Unbekannter Fisch"))
		
		# 🎨 Rarität
		var rarity_label: Label = item.get_node("VBoxContainer/InfoContainer/MarginContainer2/Rarity")
		rarity_label.text = rarity_data["name"]
		rarity_label.modulate = rarity_color
		
		# ⚖️ Gewicht
		var weight_label: Label = item.get_node("VBoxContainer/InfoContainer/StatsContainer/MarginContainer3/Weight")
		if f.has("weight"):
			weight_label.text = "⚖️ %.2f kg" % f["weight"]
		else:
			weight_label.text = "⚖️ ??? kg"
		
		# 💰 Wert
		var value = int(f["base_value"] * rarity_data["value"])
		var value_label: Label = item.get_node("VBoxContainer/InfoContainer/StatsContainer/MarginContainer4/Value")
		value_label.text = "💰 %d €" % value
		
		total_value += value
		
		# 🎭 Hover-Effekt hinzufügen
		#item.mouse_entered.connect(_on_item_hover.bind(item, true))
		#item.mouse_exited.connect(_on_item_hover.bind(item, false))
		
		# 🗑️ Rechtsklick zum Verkaufen
		item.gui_input.connect(_on_item_clicked.bind(i))
		
		fish_grid.add_child(item)
		
		# ✨ Fade-in Animation
		item.modulate.a = 0
		var tween = create_tween()
		tween.tween_property(item, "modulate:a", 1.0, 0.3).set_delay(i * 0.05)
	
	# 📊 Titel & Gesamtwert aktualisieren
	title.text = "Inventar (%d Fische)" % fish_count
	
	if total_value_label:
		total_value_label.text = "Gesamtwert: %d €" % total_value
	
	# 🔘 Button Text anpassen
	if fish_count > 0:
		sell_button.text = "Alle verkaufen (%d €)" % total_value
		sell_button.disabled = false
	else:
		sell_button.text = "Keine Fische zum Verkaufen"
		sell_button.disabled = true

#func _on_item_hover(item: PanelContainer, is_hovering: bool) -> void:
	## Hover-Effekt: Karte hebt sich leicht an
	#var tween = create_tween()
	#if is_hovering:
		#tween.tween_property(item, "", Vector2(1.05, 1.05), 0.15)
		#item.z_index = 10
	#else:
		#tween.tween_property(item, "scale", Vector2(1.0, 1.0), 0.15)
		#item.z_index = 0

func _on_item_clicked(event: InputEvent, index: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			# Rechtsklick: Einzelnen Fisch verkaufen
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
		var icon_path = fish["icon"]
		var texture = load(icon_path)
		if texture:
			return texture
	return preload("res://assets/fish/fish1.png")

func _on_sell_all_pressed() -> void:
	if Inventory.fish_inventory.is_empty():
		return
	
	var money = Inventory.get_total_value()
	var fish_count = Inventory.fish_inventory.size()
	
	Inventory.clear_inventory()
	Player.add_money(money)
	
	print("💰 Alle %d Fische verkauft für: %d €" % [fish_count, money])
	
	refresh()


func _on_close_pressed() -> void:
	toggle()
