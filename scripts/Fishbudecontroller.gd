extends Node3D
class_name FishBudeController

# Referenzen
@onready var station_fryer: StationFryer = $StationFryer
@onready var station_sushi: StationSushi = $StationSushi
@onready var station_drinks: StationDrinks = $StationDrinks
@onready var tray: Tray = $Tray
@onready var ui: CanvasLayer = $UI2
@onready var customers_root: Node3D = $Customers
@onready var customer_spawn_point: Node3D = $CustomerSpawnPoint
@onready var money_popup_layer: Control = $UI2/MoneyPopup
@export var max_queue_size := 3
@export var queue_spacing := 1.4

@onready var dayNightAni: AnimationPlayer = $DirectionalLight3D2/AnimationPlayer


@onready var entry_point: Node3D = $CustomerEntry
@onready var exit_point: Node3D = $CustomerExit

@onready var station_security: StationSecurity = $StationSecurity
@onready var main_camera: Camera3D = $PlayerCamera
@onready var security_camera: Camera3D = $SecurityCamera
@onready var security_ui: SecurityUI = $SecurityUI

var security_view_active := false



# Inventar-Referenz (wird von außen gesetzt oder gesucht)
var inventory_manager: Node = null

# State
var customers: Array = []
var current_customer: Customer = null
var money: int = 0
var customer_spawn_timer: float = 0.0
var customer_spawn_interval: float = 15.0

func _ready() -> void:
	dayNightAni.play("circle")
	setup_inventory()
	setup_ui()
	setup_tray_visual()
	connect_stations()
	connect_ui_signals()
	security_ui.set_controller(self)
	
	# Ersten Kunden nach 3 Sekunden spawnen
	await get_tree().create_timer(3.0).timeout
	spawn_customer()

func setup_tray_visual() -> void:
	"""Erstellt das 3D Tablett in der Hand des Spielers"""
	var camera = get_viewport().get_camera_3d()
	if not camera:
		print("Keine Kamera gefunden!")
		return
	
	# Erstelle Tablett-Mesh als Child der Kamera (in der Hand)
	var tray_visual = MeshInstance3D.new()
	camera.add_child(tray_visual)
	
	# Position: rechts unten im Sichtfeld
	tray_visual.position = Vector3(0.3, -0.25, -0.5)
	tray_visual.rotation_degrees = Vector3(0, 0, 0)
	
	# Tablett = flache Box
	var tray_mesh_obj = BoxMesh.new()
	tray_mesh_obj.size = Vector3(0.4, 0.02, 0.3)
	tray_visual.mesh = tray_mesh_obj
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.6, 0.4, 0.2)  # Holzfarbe
	material.roughness = 0.8
	material.no_depth_test
	tray_visual.set_surface_override_material(0, material)
	
	# Verbinde Tablett mit Tray-System
	tray.set_tray_mesh(tray_visual)

func setup_inventory() -> void:
	# Nutze das Inventory Autoload
	inventory_manager = Inventory
	
	if not inventory_manager:
		push_error("Inventory Autoload nicht gefunden!")
	else:
		print("Inventory gefunden - Fische verfuegbar:", inventory_manager.fish_inventory.size())

func setup_ui() -> void:
	ui.get_node("OrderPanel").visible = false

func connect_stations() -> void:
	# Hole Fish Selection UI
	var fish_ui = ui.get_node_or_null("FishSelectionUI")
	
	# Verbinde Stationen mit Tablett und Controller
	station_fryer.set_tray(tray)
	station_fryer.set_controller(self)
	if fish_ui:
		station_fryer.set_fish_selection_ui(fish_ui)
	
	station_sushi.set_tray(tray)
	station_sushi.set_controller(self)
	if fish_ui:
		station_sushi.set_fish_selection_ui(fish_ui)
	
	station_drinks.set_tray(tray)
	station_drinks.set_controller(self)
	station_security.set_controller(self)


func connect_ui_signals() -> void:
	# Servieren-Button
	var serve_button = ui.get_node("TrayPanel/VBoxContainer/ServeButton")
	if serve_button:
		serve_button.pressed.connect(serve_customer)
	
	# Tablett-Updates
	tray.item_added.connect(_on_tray_item_added)
	tray.item_removed.connect(_on_tray_item_removed)
	tray.tray_cleared.connect(_on_tray_cleared)
	Player.money_gained.connect(_on_money_gained)

func _process(delta: float) -> void:
	handle_customer_spawning(delta)
	update_customer_patience(delta)
	update_station_hover()

func update_station_hover() -> void:
	"""Prüft welche Station die Maus gerade hovert"""
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return
	
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	
	# Alle Stationen auf "nicht hovering" setzen
	station_fryer.set_hover(false)
	station_sushi.set_hover(false)
	station_drinks.set_hover(false)
	station_security.set_hover(false)

	
	if result and result.collider:
		var collider = result.collider
		
		# Prüfe ob es eine Station ist
		if collider == station_fryer:
			station_fryer.set_hover(true)
		elif collider == station_sushi:
			station_sushi.set_hover(true)
		elif collider == station_drinks:
			station_drinks.set_hover(true)
		elif collider == station_security:
			station_security.set_hover(true)

func handle_customer_spawning(delta: float) -> void:
	customer_spawn_timer += delta

	if customer_spawn_timer >= customer_spawn_interval:
		customer_spawn_timer = 0.0
		spawn_customer()

func toggle_security_camera() -> void:
	security_view_active = not security_view_active

	if security_view_active:
		main_camera.current = false
		security_camera.current = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		security_camera.current = false
		main_camera.current = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func spawn_customer() -> void:
	if customers.size() >= max_queue_size:
		return

	if not inventory_manager or inventory_manager.fish_inventory.is_empty():
		return

	var available_fish_types := get_available_fish_types()
	if available_fish_types.is_empty():
		return

	var customer_scene := preload("res://scenes/Customer.tscn")
	var customer := customer_scene.instantiate()
	customers_root.add_child(customer)


	# Start links (Entry)
	customer.global_position = entry_point.global_position

	customer.generate_order_from_inventory(available_fish_types)
	customer.order_completed.connect(_on_customer_order_completed)

	customers.append(customer)
	_reorder_queue()

func _reorder_queue() -> void:
	for i in range(customers.size()):
		customers[i].move_to(get_queue_position(i))
		customers[i].set_active(false)

	if customers.size() > 0:
		current_customer = customers[0]
		current_customer.set_active(true)
		show_order_ui(current_customer.order)
	else:
		current_customer = null
		show_order_ui(null)


func get_available_fish_types() -> Array:
	"""Gibt alle unterschiedlichen Fischarten zurück die im Inventar sind"""
	var fish_types = []
	
	if not inventory_manager:
		return fish_types
	
	for fish_data in inventory_manager.fish_inventory:
		var fish_name = fish_data.get("name", "")
		if fish_name != "" and not fish_types.has(fish_name):
			fish_types.append(fish_name)
	
	return fish_types

func has_fish_in_inventory(fish_name: String) -> bool:
	"""Prüft ob ein bestimmter Fisch im Inventar ist"""
	if not inventory_manager:
		return false
	
	for fish_data in inventory_manager.fish_inventory:
		if fish_data.get("name", "") == fish_name:
			return true
	
	return false

func remove_fish_from_inventory(fish_name: String) -> bool:
	"""Entfernt einen Fisch aus dem Inventar"""
	if not inventory_manager:
		return false
	
	for i in range(inventory_manager.fish_inventory.size()):
		var fish_data = inventory_manager.fish_inventory[i]
		if fish_data.get("name", "") == fish_name:
			inventory_manager.remove_fish(i)
			print("Fisch aus Inventar entfernt: %s" % fish_name)
			return true
	
	return false

func get_fish_data(fish_name: String) -> Dictionary:
	"""Holt die Daten eines Fisches aus dem Inventar"""
	if not inventory_manager:
		return {}
	
	for fish_data in inventory_manager.fish_inventory:
		if fish_data.get("name", "") == fish_name:
			return fish_data
	
	return {}

func show_order_ui(order: Order) -> void:
	var order_panel := ui.get_node("OrderPanel") as Control

	# ✅ Wenn keine Order: Panel ausblenden und raus
	if order == null:
		order_panel.visible = false
		return

	order_panel.visible = true

	# 🐟 FISCHNAME
	var fish_label := order_panel.get_node("VBoxContainer/Fish/FishLabel") as Label
	fish_label.text = "Fisch: %s" % order.fish_type

	# 🍳 ZUBEREITUNG
	var prep_label := order_panel.get_node("VBoxContainer/Prep/PrepLabel") as Label
	prep_label.text = "Art: %s" % order.preparation_type

	# 🥤 GETRÄNK
	var drink_label := order_panel.get_node("VBoxContainer/Drink/DrinkLabel") as Label
	drink_label.text = "Getränk: Ja" if order.wants_drink else "Getränk: Nein"




func update_customer_patience(delta: float) -> void:
	if current_customer:
		current_customer.update_patience(delta)

func serve_customer() -> void:
	if not current_customer:
		print("Kein Kunde zum Bedienen!")
		return

	if not tray.has_items():
		print("Tablett ist leer!")
		return

	# 🔒 Order einmal sichern
	var order: Order = current_customer.order
	if order == null:
		push_warning("⚠️ Kunde hat keine Order mehr!")
		return

	var correct := tray.matches_order(order)

	# 🔒 UI sofort schließen – danach KEIN Zugriff mehr auf order!
	ui.get_node("OrderPanel").visible = false

	if correct:
		print("Bestellung korrekt!")

		var payment := calculate_fish_payment(order)
		var fish_name := order.fish_type  # 🔒 sichern!

		remove_fish_from_inventory(fish_name)

		# ❗ LETZTER Zugriff auf current_customer
		current_customer.complete_order_with_payment(payment)
	else:
		print("Falsche Bestellung!")
		current_customer.complete_order(false)


func _on_customer_order_completed(customer: Customer, payment: int, tip: int) -> void:
	Player.add_money(payment + tip)

	customers.erase(customer)
	customer.leave_to(exit_point.global_position)

	tray.clear_all()
	current_customer = null
	_reorder_queue()


func _on_tray_item_added(_item) -> void:
	update_tray_ui()

func _on_tray_item_removed(_item) -> void:
	update_tray_ui()

func _on_tray_cleared() -> void:
	update_tray_ui()

func update_tray_ui() -> void:
	var tray_content = ui.get_node("TrayPanel/VBoxContainer/TrayContent")
	if tray_content:
		var items = tray.get_items()
		if items.size() == 0:
			tray_content.text = "Leer (0/4)"
		else:
			var item_texts = []
			for item in items:
				item_texts.append(item.get_description())
			tray_content.text = "\n".join(item_texts) + "\n(%d/4)" % items.size()

# === DEBUG FUNKTIONEN ===
func _input(event: InputEvent) -> void:
	# Mausklick auf Stationen
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		handle_station_click()
		return
		
	if security_view_active and event.is_action_pressed("ui_cancel"):
		toggle_security_camera()
		return
	
	# Debug: Tablett leeren mit Space
	if event.is_action_pressed("ui_select"):  # Space
		tray.clear_all()
		print("Tablett geleert")
	
	# Debug: Inventar anzeigen mit I
	if event.is_action_pressed("ui_text_completion_query"):  # Tab
		print_inventory_status()

func handle_station_click() -> void:
	"""Führt Interaktion mit der Station aus, die gerade unter der Maus ist"""
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return
	
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	
	if result and result.collider:
		var collider = result.collider
		
		# Rufe interact() auf der Station auf
		if collider.has_method("interact"):
			collider.interact()
			print("Station interagiert: %s" % collider.name)

func print_inventory_status() -> void:
	if not inventory_manager:
		print("Kein InventoryManager!")
		return
	
	print("\n=== INVENTAR STATUS ===")
	print("Fische gesamt: %d" % inventory_manager.fish_inventory.size())
	var fish_counts = {}
	for fish_data in inventory_manager.fish_inventory:
		var name = fish_data.get("name", "Unknown")
		fish_counts[name] = fish_counts.get(name, 0) + 1
	
	for fish_name in fish_counts:
		print("  - %s: %dx" % [fish_name, fish_counts[fish_name]])
	print("=====================\n")
	
func get_fish_dict_from_name(fish_name: String) -> Dictionary:
	var all_lists = [
		FishDB.FISH_LAKE,
		FishDB.FISH_CITY,
		FishDB.FISH_SEWER,
		FishDB.FISH_FOREST,
		FishDB.FISH_DESERT,
		FishDB.FISH_ICELAND
	]

	for list in all_lists:
		for fish in list:
			if fish.get("name", "") == fish_name:
				return fish

	return {}
	
func get_available_fish_dicts() -> Array:
	var result: Array = []
	var used := {}

	for fish_name in get_available_fish_types():
		if used.has(fish_name):
			continue

		var fish_dict := get_fish_dict_from_name(fish_name)
		if fish_dict.is_empty():
			push_warning("⚠️ Unbekannter Fisch im Inventar: ", fish_name)
			continue

		result.append(fish_dict)
		used[fish_name] = true

	return result
	
func calculate_fish_payment(order: Order) -> int:
	var fish_dict := get_fish_dict_from_name(order.fish_type)
	if fish_dict.is_empty():
		push_error("❌ Kein FishDict für: " + order.fish_type)
		return 0

	var base_price: float = fish_dict.get("base_value", 1)
	var rarity_multiplier: float = FishDB.get_rarity_value(fish_dict)

	var prep_multiplier := 1.0
	match order.preparation_type:
		"Backfisch":
			prep_multiplier = 1.6
		"Sushi":
			prep_multiplier = 2.2

	var result := base_price * rarity_multiplier * prep_multiplier * 1.5
	return int(result)
	
	
func _on_money_gained(amount: int) -> void:
	show_money_popup(amount)

func show_money_popup(amount: int) -> void:
	var popup_scene := preload("res://scenes/MoneyPopup.tscn")
	var popup := popup_scene.instantiate() as MoneyPopup

	money_popup_layer.add_child(popup)

	# leichte Zufallsposition für Multiple-Popups
	popup.position = Vector2(
		randf_range(-30, 30),
		randf_range(-10, 10)
	)

	popup.show_amount(amount)

func get_queue_position(index: int) -> Vector3:
	return customer_spawn_point.global_position + Vector3(-queue_spacing * index, 0, 0)
	

func enter_security_view() -> void:
	if security_view_active:
		return

	security_view_active = true

	main_camera.current = false
	security_camera.current = true
	ui.hide()
	security_ui.show_ui()

	# Gameplay blockieren (optional aber empfohlen)
	set_process(false)

func exit_security_view() -> void:
	if not security_view_active:
		return

	security_view_active = false

	security_camera.current = false
	main_camera.current = true

	security_ui.hide_ui()
	ui.show()

	set_process(true)
	
func _exit_tree() -> void:
	cleanup_customers()

func cleanup_customers() -> void:
	for c in customers:
		if is_instance_valid(c):
			c.queue_free()

	customers.clear()
	current_customer = null
