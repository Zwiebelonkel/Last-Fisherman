extends Camera3D

@export var sway_amount: float = 0.02
@export var sway_speed: float = 1.5
@export var rotation_smoothing: float = 6.0
@export var mouse_tilt_amount: float = 0.03
@export var mouse_tilt_smoothing: float = 4.0
@export var flashlight: Node3D
@export var flashlight_follow_speed: float = 5.0
@export var fishing_rod: Node3D
@export var rod_follow_speed := 8.0

var base_position: Vector3
var target_rotation_y: float = 0.0
var current_rotation_y: float = 0.0

# Maus-Tilt
var target_tilt: Vector2 = Vector2.ZERO
var current_tilt: Vector2 = Vector2.ZERO

# Screen shake
var shake_intensity := 0.0
var shake_duration := 0.0
var shake_time := 0.0

func _ready() -> void:
	base_position = position
	target_rotation_y = rotation.y
	current_rotation_y = rotation.y

func _process(delta: float) -> void:
	var t := Time.get_ticks_msec() / 1000.0

	var sway_offset = Vector3(
		sin(t * sway_speed) * sway_amount,
		cos(t * sway_speed * 0.8) * sway_amount,
		0.0
	)

	var shake_offset = Vector3.ZERO
	if shake_time < shake_duration:
		shake_time += delta
		var fade := 1.0 - (shake_time / shake_duration)
		shake_offset = Vector3(
			(randf() * 2 - 1) * shake_intensity * fade,
			(randf() * 2 - 1) * shake_intensity * fade,
			(randf() * 2 - 1) * shake_intensity * fade
		)

	# Maus-Tilt
	var viewport_size := get_viewport().get_visible_rect().size
	var mouse_pos := get_viewport().get_mouse_position()
	var normalized := Vector2(
		(mouse_pos.x / viewport_size.x) * 2.0 - 1.0,
		(mouse_pos.y / viewport_size.y) * 2.0 - 1.0
	)
	target_tilt = normalized * mouse_tilt_amount
	current_tilt = current_tilt.lerp(target_tilt, delta * mouse_tilt_smoothing)

	position = base_position + sway_offset + shake_offset

	current_rotation_y = lerp_angle(current_rotation_y, target_rotation_y, delta * rotation_smoothing)

	rotation = Vector3(
		- current_tilt.y,
		current_rotation_y - current_tilt.x,
		0.0
	)
	
	if flashlight:
		# Position smooth folgen
		flashlight.global_position = flashlight.global_position.lerp(
			global_position,
			delta * flashlight_follow_speed
		)

	# Rotation smooth folgen
		var current_basis = flashlight.global_transform.basis
		var target_basis = global_transform.basis

		flashlight.global_transform.basis = current_basis.slerp(
			target_basis,
			delta * flashlight_follow_speed
		)
	if fishing_rod:
		var target_transform = global_transform

		fishing_rod.global_position = fishing_rod.global_position.lerp(
			target_transform.origin,
			delta * rod_follow_speed
		)

		fishing_rod.global_transform.basis = fishing_rod.global_transform.basis.slerp(
			target_transform.basis,
			delta * rod_follow_speed
		)

func start_screenshake(intensity: float, duration: float) -> void:
	shake_intensity = intensity
	shake_duration = duration
	shake_time = 0.0
