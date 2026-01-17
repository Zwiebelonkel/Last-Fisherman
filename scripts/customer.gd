extends Node3D
class_name Customer

signal order_completed(customer: Customer, payment: int, tip: int)

@onready var patience_bar_container: SubViewportContainer = $PatienceBar3D
@onready var patience_bar: ProgressBar = $PatienceBar3D/SubViewport/PatienceBar
@onready var mesh_instance: Node3D = $MeshInstance3D

# ✅ Dialog wird dynamisch auf separatem Layer erstellt
var shop_dialog: Control = null
var dialog_scene: PackedScene = preload("res://scenes/customer_dialog.tscn")

var order: Order = null
var patience: float = 100.0
var patience_drain_rate: float = 5.0
var is_active: bool = false
var move_speed: float = 2.0

var target_position: Vector3 = Vector3.ZERO
var is_moving: bool = false

func _ready() -> void:
	patience_bar.value = patience
	
	if patience_bar_container:
		patience_bar_container.hide()
	
	# ✅ Dialog auf separatem Layer erstellen (ÜBER dem Shader!)
	create_dialog()

func create_dialog() -> void:
	# ✅ FIXED: Korrekter Pfad zum CustomerDialogLayer
	# Der Layer ist ein direktes Kind der Szene Root
	var scene_root = get_tree().current_scene
	
	if not scene_root:
		push_error("Keine aktive Szene gefunden!")
		return
	
	var dialog_layer = scene_root.get_node_or_null("CustomerDialogLayer")
	
	if not dialog_layer:
		push_error("CustomerDialogLayer nicht gefunden! Scene Root: " + scene_root.name)
		print("Verfügbare Kinder: ", scene_root.get_children().map(func(n): return n.name))
		return
	
	# Erstelle Dialog-Instanz und füge zu Layer hinzu
	shop_dialog = dialog_scene.instantiate()
	dialog_layer.add_child(shop_dialog)
	shop_dialog.hide()
	
	print("✅ Dialog erstellt auf Layer: ", dialog_layer.layer)

func _exit_tree() -> void:
	# ✅ WICHTIG: Dialog aufräumen wenn Customer gelöscht wird
	if shop_dialog and is_instance_valid(shop_dialog):
		shop_dialog.queue_free()
		shop_dialog = null

func generate_order_from_inventory(available_fish_types: Array) -> void:
	if available_fish_types.is_empty():
		push_error("Keine verfügbaren Fischarten für Bestellung!")
		return
	
	order = Order.new()
	order.fish_type = available_fish_types[randi() % available_fish_types.size()]
	
	var prep_types = ["Backfisch", "Sushi"]
	order.preparation_type = prep_types[randi() % prep_types.size()]
	order.wants_drink = randf() < 0.5
	
	print("Kunde bestellt: ", order.fish_type, " als ", order.preparation_type, 
		  ", Getränk: ", "Ja" if order.wants_drink else "Nein")

func set_active(active: bool) -> void:
	is_active = active

	if shop_dialog and is_instance_valid(shop_dialog):
		if active:
			shop_dialog.show()
			# Aktiver Kunde schaut nach 0 Grad
			set_rotationCustomer(0)
		else:
			shop_dialog.hide()
			# Inaktive Kunden schauen nach 90 Grad
			set_rotationCustomer(90)

	if patience_bar_container:
		if active:
			patience_bar_container.show()
		else:
			patience_bar_container.hide()

	print("Kunde ist ", "aktiv" if active else "inaktiv")


func update_patience(delta: float) -> void:
	if not is_active:
		return
	
	patience -= patience_drain_rate * delta
	patience = max(0, patience)
	patience_bar.value = patience
	
	if patience <= 0:
		complete_order(false)

func complete_order(success: bool) -> void:
	if success:
		print("Bestellung erfüllt!")
		var payment = 100
		var tip = int(patience)
		order_completed.emit(self, payment, tip)
	else:
		print("Kunde unzufrieden!")
		order_completed.emit(self, 0, 0)
		
func set_rotationCustomer(degrees: float) -> void:
	rotation.y = deg_to_rad(degrees)


func complete_order_with_payment(payment: int) -> void:
	var tip = int(patience)
	order_completed.emit(self, payment, tip)

func move_to(pos: Vector3) -> void:
	target_position = pos
	is_moving = true
	# Beim Bewegen: 90 Grad
	set_rotationCustomer(90)

func leave_to(exit_pos: Vector3) -> void:
	if shop_dialog and is_instance_valid(shop_dialog):
		shop_dialog.hide()
	if patience_bar_container:
		patience_bar_container.hide()
	target_position = exit_pos
	is_moving = true
	# Beim Verlassen: 90 Grad
	set_rotationCustomer(90)
	await get_tree().create_timer(2.0).timeout
	if is_instance_valid(self):
		queue_free()


func _process(delta: float) -> void:
	if is_moving:
		var direction = (target_position - global_position).normalized()
		global_position = global_position.move_toward(target_position, move_speed * delta)
		if global_position.distance_to(target_position) < 0.1:
			is_moving = false
			# Beim Ankommen: Rotation zurücksetzen (wird in set_active gemacht)
