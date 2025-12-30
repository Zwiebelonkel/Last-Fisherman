extends Node3D
class_name Customer

signal order_completed(customer: Customer, payment: int, tip: int)

@onready var mesh: Node3D = $MeshInstance3D
@onready var patience_bar_3d: SubViewportContainer = $PatienceBar3D

# ===============================
#  DATA
# ===============================
var order: Order
var patience := 100.0
var patience_decay_rate := 5.0
var is_waiting := true
var is_active := false

# ===============================
#  MOVEMENT
# ===============================
var target_position: Vector3
var has_target := false
var move_speed := 2.5
var leaving := false

# ===============================
#  READY
# ===============================
func _ready() -> void:
	rotation.y = deg_to_rad(90) # Standard: Schlange
	setup_patience_bar()

# ===============================
#  PROCESS
# ===============================
func _process(delta: float) -> void:
	_handle_movement(delta)
	_handle_patience(delta)

# ===============================
#  MOVEMENT LOGIC
# ===============================
func _handle_movement(delta: float) -> void:
	if not has_target:
		return

	global_position = global_position.move_toward(
		target_position,
		move_speed * delta
	)

	if global_position.distance_to(target_position) < 0.05:
		has_target = false
		if leaving:
			queue_free()

func move_to(pos: Vector3) -> void:
	target_position = pos
	has_target = true
	leaving = false
	set_active(false)

func leave_to(pos: Vector3) -> void:
	target_position = pos
	has_target = true
	leaving = true
	is_waiting = false
	set_active(false)

# ===============================
#  ACTIVE / ROTATION
# ===============================
func set_active(active: bool) -> void:
	is_active = active
	is_waiting = active

	var target_rot := 0.0 if active else deg_to_rad(90)

	var tween := create_tween()
	tween.tween_property(
		self,
		"rotation:y",
		target_rot,
		0.25
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

# ===============================
#  PATIENCE
# ===============================
func setup_patience_bar() -> void:
	update_patience_bar()

func _handle_patience(delta: float) -> void:
	if not is_waiting:
		return

	patience -= patience_decay_rate * delta
	patience = clamp(patience, 0.0, 100.0)
	update_patience_bar()

func update_patience_bar() -> void:
	if not patience_bar_3d:
		return

	var viewport := patience_bar_3d.get_node_or_null("SubViewport")
	if not viewport:
		return

	var bar := viewport.get_node_or_null("PatienceBar")
	if not bar:
		return

	bar.value = patience

	if patience > 60:
		bar.modulate = Color.GREEN
	elif patience > 30:
		bar.modulate = Color.YELLOW
	else:
		bar.modulate = Color.RED

# ===============================
#  ORDER GENERATION
# ===============================
func generate_order_from_inventory(available_fish: Array) -> void:
	if available_fish.is_empty():
		push_error("❌ Keine Fische verfügbar für Bestellung!")
		return

	order = Order.new()
	order.fish_type = available_fish.pick_random()
	order.preparation_type = ["Backfisch", "Sushi"].pick_random()
	order.wants_drink = randf() > 0.6

	_calculate_order_price()

func _calculate_order_price() -> void:
	var base_price := 15.0

	match order.preparation_type:
		"Backfisch":
			order.base_payment = base_price * 1.6
		"Sushi":
			order.base_payment = base_price * 2.2
		_:
			order.base_payment = base_price * 1.6

	if order.wants_drink:
		order.base_payment += 5.0

# ===============================
#  ORDER COMPLETE
# ===============================
func complete_order(correct: bool) -> void:
	is_waiting = false
	set_active(false)

	if not correct:
		show_complaint_animation()
		order_completed.emit(self, 0, 0)
		return

	var payment := int(order.base_payment)
	var tip := calculate_tip()

	show_happy_animation()
	order_completed.emit(self, payment, tip)

func complete_order_with_payment(payment: int) -> void:
	is_waiting = false
	set_active(false)

	var tip := calculate_tip()
	show_happy_animation()
	order_completed.emit(self, payment, tip)

func calculate_tip() -> int:
	var max_tip := order.base_payment * 0.5
	return int(max_tip * (patience / 100.0))

# ===============================
#  ANIMATIONS
# ===============================
func show_happy_animation() -> void:
	if not mesh:
		return

	var tween := create_tween()
	var y := position.y

	tween.tween_property(self, "position:y", y + 0.5, 0.3)
	tween.tween_property(self, "position:y", y, 0.3)

func show_complaint_animation() -> void:
	if not mesh:
		return

	var tween := create_tween()
	var rot := rotation.z

	tween.tween_property(self, "rotation:z", rot - 0.2, 0.1)
	tween.tween_property(self, "rotation:z", rot + 0.2, 0.1)
	tween.tween_property(self, "rotation:z", rot, 0.1)

# ===============================
#  KOMPATIBILITÄT
# ===============================
func update_patience(delta: float) -> void:
	_handle_patience(delta)
