extends Node3D

# NODE-REFERENCES
@export var rod_tip: Node3D
@export var hook: Node3D
@export var catch_result_ui: Node


@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var ripple_anim: AnimationPlayer = hook.get_node("AnimationPlayer")

@onready var ui_bite_indicator: TextureRect = get_node("../../UI/BiteIndicator")
@onready var catch_ui: Control = get_node("../../UI/CatchUI")
@onready var bar_background: Control = catch_ui.get_node("BarBackground")
@onready var marker: Control = bar_background.get_node("Marker")
@onready var sweet_spot: Control = bar_background.get_node("SweetSpot")
@onready var catch_progress: ProgressBar = catch_ui.get_node("CatchProgress")
@export var inventory_ui: Node
signal line_visible(visible: bool)


# STATE MACHINE
enum {
	STATE_IDLE,
	STATE_CASTED,
	STATE_BITE,
	STATE_MINIGAME
}

var state: int = STATE_IDLE

# Minigame Variables
var marker_pos: float = 0.0
var marker_speed: float = 350.0
var marker_slow_factor: float = 0.3
var input_active: bool = false


func _ready() -> void:
	anim.play("idle")
	hook.visible = false
	ui_bite_indicator.visible = false
	catch_ui.visible = false


func _unhandled_input(event: InputEvent) -> void:
	# Minigame input
	if state == STATE_MINIGAME:
		if event.is_action_pressed("cast"):
			input_active = true
		if event.is_action_released("cast"):
			input_active = false

	# Normal casting / reeling
	if event.is_action_pressed("cast"):
		match state:
			STATE_IDLE:
				cast_line()
			STATE_CASTED, STATE_BITE:
				reel_pressed()
			STATE_MINIGAME:
				pass
	if event.is_action_pressed("inventory_toggle"):
		inventory_ui.toggle()
				



# ---------------------------------------------------------
# CAST
# ---------------------------------------------------------
func cast_line() -> void:
	print("CAST")
	state = STATE_CASTED
	ui_bite_indicator.visible = false

	anim.play("cast")
	await anim.animation_finished

	var x = randf_range(-2.0, 2.0)
	var z = randf_range(4.0, 7.0)
	hook.position = Vector3(x, 0.05, z)
	hook.visible = true

	ripple_anim.play("ripple")
	anim.play("idle")

	start_bite_timer()
	emit_signal("line_visible", true)



# ---------------------------------------------------------
# REEL
# ---------------------------------------------------------
func reel_pressed() -> void:
	match state:
		STATE_CASTED:
			print("Zu früh oder zu spät!")
			reset_line()

		STATE_BITE:
			print("BISS! Minispiel starten")
			ui_bite_indicator.visible = false
			start_catch_minigame()


func reset_line() -> void:
	state = STATE_IDLE
	anim.play("reel")
	await anim.animation_finished

	hook.visible = false
	ui_bite_indicator.visible = false
	anim.play("idle")
	emit_signal("line_visible", false)



# ---------------------------------------------------------
# BITE TIMER
# ---------------------------------------------------------
func start_bite_timer() -> void:
	var wait_time := randf_range(1.5, 4.0)
	print("Bite Timer gestartet: ", wait_time, "s")
	await get_tree().create_timer(wait_time).timeout

	if state != STATE_CASTED:
		print("Bite Timer abgebrochen:, state = ", state)
		return

	print("BITE READY!")
	state = STATE_BITE
	show_bite_indicator()


func show_bite_indicator() -> void:
	ui_bite_indicator.visible = true

	while state == STATE_BITE:
		ui_bite_indicator.modulate.a = 1.0
		await get_tree().create_timer(0.2).timeout
		if state != STATE_BITE:
			break
		ui_bite_indicator.modulate.a = 0.2
		await get_tree().create_timer(0.2).timeout


# ---------------------------------------------------------
# CATCH MINIGAME
# ---------------------------------------------------------
func start_catch_minigame() -> void:
	state = STATE_MINIGAME
	catch_ui.visible = true

	catch_progress.value = 50.0
	marker_pos = 0.0
	marker.position.x = 0.0


func _process(delta: float) -> void:
	if state == STATE_MINIGAME:
		update_catch_minigame(delta)


func update_catch_minigame(delta: float) -> void:
	var current_speed = marker_speed

	if input_active:
		current_speed *= marker_slow_factor

	marker_pos += current_speed * delta

	var max_x := bar_background.size.x - marker.size.x

	if marker_pos >= max_x:
		marker_pos = max_x
		marker_speed *= -1.0
	elif marker_pos <= 0.0:
		marker_pos = 0.0
		marker_speed *= -1.0

	marker.position.x = marker_pos

	var in_spot := marker.position.x >= sweet_spot.position.x \
		and marker.position.x <= sweet_spot.position.x + sweet_spot.size.x

	if in_spot:
		catch_progress.value += 50 * delta
	else:
		catch_progress.value = max(0.0, catch_progress.value - 25.0 * delta)

	if catch_progress.value >= 100.0:
		end_catch_minigame(true)
	elif catch_progress.value <= 0.0:
		end_catch_minigame(false)


func end_catch_minigame(success: bool) -> void:
	if success:
		var fish = FishDB.get_random_from_list(FishDB.FISH_LAKE)
		Inventory.add_fish(fish)

		# zeige Popup
		if catch_result_ui:
			catch_result_ui.show_fish(fish)

		print("Gefangen: ", fish["name"])
	else:
		print("Fisch entwischt!")

	catch_ui.visible = false
	await reset_line()
