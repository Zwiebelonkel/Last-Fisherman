extends Control

@onready var fish_grid: GridContainer = $PanelContainer/VBoxContainer/ScrollContainer/FishGrid
@onready var sell_button: Button = $PanelContainer/VBoxContainer/Button
@onready var title: Label = $PanelContainer/VBoxContainer/Label

var item_scene := preload("res://scenes/FishingItem.tscn")
var is_open := false

func _ready() -> void:
	print("FishGrid =", fish_grid)
	visible = false
	sell_button.pressed.connect(_on_sell_all_pressed)
	
	# ✅ Signal verbinden: Automatisches Refresh bei Sichtbarkeitsänderung
	visibility_changed.connect(_on_visibility_changed)
	
	refresh()

# ✅ Automatisches Refresh wenn sichtbar wird
func _on_visibility_changed() -> void:
	if visible:
		is_open = true
		refresh()
	else:
		is_open = false

func toggle() -> void:
	is_open = !is_open
	visible = is_open
	# refresh() wird automatisch durch visibility_changed aufgerufen

func refresh() -> void:
	# Kinder im Grid löschen
	for child in fish_grid.get_children():
		child.queue_free()
	
	for f in Inventory.fish_inventory:
		var item = item_scene.instantiate()
		
		# Icon
		item.get_node("FishIcon").texture = _get_fish_icon(f)
		
		# Name
		var name_label: Label = item.get_node("VBoxContainer/Name")
		name_label.text = str(f.get("name", "Unbekannter Fisch"))
		
		# Rarität
		var rarity = f.get("rarity", FishDB.RARITY.NORMAL)
		var rarity_data = FishDB.RARITY_DATA[rarity]
		var rarity_label: Label = item.get_node("VBoxContainer/Rarity")
		rarity_label.text = rarity_data["name"]
		rarity_label.modulate = rarity_data["color"]
		
		# Wert
		var value = int(f["base_value"] * rarity_data["value"])
		var value_label: Label = item.get_node("Value")
		value_label.text = str(value) + " €"
		
		fish_grid.add_child(item)
	
	title.text = "Inventar (" + str(Inventory.fish_inventory.size()) + " Fische)"

func _get_fish_icon(fish: Dictionary) -> Texture2D:
	# Icon aus dem Fish-Dictionary laden
	if fish.has("icon"):
		var icon_path = fish["icon"]
		var texture = load(icon_path)
		if texture:
			return texture
	# Fallback, falls kein Icon vorhanden
	return preload("res://assets/fish/fish1.png")

func _on_sell_all_pressed() -> void:
	var money = Inventory.get_total_value()
	Inventory.clear_inventory()
	Player.add_money(money)
	refresh()
	print("Verkauft für:", money)
