class_name PlayerCamera
extends Camera3D

@export var sway_amount: float = 0.02
@export var sway_speed: float = 1.5
@export var rotation_smoothing: float = 6.0

@export var mouse_tilt_amount: float = 0.03
@export var mouse_tilt_smoothing: float = 4.0

@export var flashlight: Node3D
@export var flashlight_follow_speed: float = 5.0

@export var fishing_rod: Node3D

@export var rod_follow_speed: float = 7.0
@export var rod_position_sway: float = 0.35
@export var rod_rotation_sway: float = 2.2
@export var rod_idle_sway_amount: float = 0.025

var base_position: Vector3 = Vector3.ZERO

var target_rotation_y: float = 0.0
var current_rotation_y: float = 0.0

var target_tilt: Vector2 = Vector2.ZERO
var current_tilt: Vector2 = Vector2.ZERO
var last_tilt: Vector2 = Vector2.ZERO

var shake_intensity: float = 0.0
var shake_duration: float = 0.0
var shake_time: float = 0.0

var rod_base_position: Vector3 = Vector3.ZERO
var rod_base_rotation: Vector3 = Vector3.ZERO


func _ready() -> void:
	base_position = position
	target_rotation_y = rotation.y
	current_rotation_y = rotation.y

	if fishing_rod:
		rod_base_position = fishing_rod.position
		rod_base_rotation = fishing_rod.rotation


func _process(delta: float) -> void:
	var time_seconds: float = float(Time.get_ticks_msec()) / 1000.0

	var sway_offset: Vector3 = Vector3(
		sin(time_seconds * sway_speed) * sway_amount,
		cos(time_seconds * sway_speed * 0.8) * sway_amount,
		0.0
	)

	var shake_offset: Vector3 = Vector3.ZERO

	if shake_time < shake_duration:
		shake_time += delta
		var fade: float = 1.0 - shake_time / shake_duration

		shake_offset = Vector3(
			randf_range(-1.0, 1.0) * shake_intensity * fade,
			randf_range(-1.0, 1.0) * shake_intensity * fade,
			randf_range(-1.0, 1.0) * shake_intensity * fade
		)

	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()

	var normalized_mouse: Vector2 = Vector2(
		(mouse_pos.x / viewport_size.x) * 2.0 - 1.0,
		(mouse_pos.y / viewport_size.y) * 2.0 - 1.0
	)

	target_tilt = normalized_mouse * mouse_tilt_amount

	var tilt_alpha: float = clamp(delta * mouse_tilt_smoothing, 0.0, 1.0)
	current_tilt = current_tilt.lerp(target_tilt, tilt_alpha)

	position = base_position + sway_offset + shake_offset

	var rotation_alpha: float = clamp(delta * rotation_smoothing, 0.0, 1.0)
	current_rotation_y = lerp_angle(current_rotation_y, target_rotation_y, rotation_alpha)

	rotation = Vector3(
		-current_tilt.y,
		current_rotation_y - current_tilt.x,
		0.0
	)

	_update_flashlight(delta)
	_update_fishing_rod(delta, time_seconds)


func _update_flashlight(delta: float) -> void:
	if not flashlight:
		return

	var alpha: float = clamp(delta * flashlight_follow_speed, 0.0, 1.0)

	flashlight.global_position = flashlight.global_position.lerp(global_position, alpha)

	var current_basis: Basis = flashlight.global_transform.basis
	var target_basis: Basis = global_transform.basis

	flashlight.global_transform.basis = current_basis.slerp(target_basis, alpha)


func _update_fishing_rod(delta: float, time_seconds: float) -> void:
	if not fishing_rod:
		return

	var alpha: float = clamp(delta * rod_follow_speed, 0.0, 1.0)

	# Wie weit Kamera noch hinter Zielrotation herläuft
	var rotation_lag: float = angle_difference(current_rotation_y, target_rotation_y)

	# Mausbewegung / Tilt-Veränderung
	var tilt_velocity: Vector2 = current_tilt - last_tilt
	last_tilt = current_tilt

	# Idle Bewegung der Angel
	var idle_offset: Vector3 = Vector3(
		sin(time_seconds * 1.8) * rod_idle_sway_amount,
		cos(time_seconds * 1.4) * rod_idle_sway_amount,
		0.0
	)

	# Position zieht sichtbar nach
	var target_position: Vector3 = rod_base_position + idle_offset + Vector3(
		rotation_lag * rod_position_sway - current_tilt.x * 0.7 - tilt_velocity.x * 14.0,
		current_tilt.y * 0.45 + tilt_velocity.y * 8.0,
		0.0
	)

	# Rotation zieht sichtbar nach
	var target_rotation: Vector3 = rod_base_rotation + Vector3(
		current_tilt.y * rod_rotation_sway + tilt_velocity.y * 18.0,
		rotation_lag * rod_rotation_sway + current_tilt.x * rod_rotation_sway,
		-rotation_lag * rod_rotation_sway - current_tilt.x * rod_rotation_sway * 1.4
	)

	fishing_rod.position = fishing_rod.position.lerp(target_position, alpha)
	fishing_rod.rotation = fishing_rod.rotation.lerp(target_rotation, alpha)


func start_screenshake(intensity: float, duration: float) -> void:
	shake_intensity = intensity
	shake_duration = duration
	shake_time = 0.0
