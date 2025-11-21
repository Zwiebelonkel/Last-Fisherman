extends Camera3D

@export var sway_amount: float = 0.02
@export var sway_speed: float = 1.5

var base_position: Vector3

# --- Screen shake variables ---
var shake_intensity := 0.0
var shake_duration := 0.0
var shake_time := 0.0

func _ready() -> void:
	base_position = position


func _process(delta: float) -> void:
	var t := Time.get_ticks_msec() / 1000.0

	# --- Weapon sway ---
	var sway_offset = Vector3(
		sin(t * sway_speed) * sway_amount,
		cos(t * sway_speed * 0.8) * sway_amount,
		0.0
	)

	# --- Screen shake ---
	var shake_offset = Vector3.ZERO
	if shake_time < shake_duration:
		shake_time += delta
		var fade := 1.0 - (shake_time / shake_duration)   # fades from 1→0
		shake_offset = Vector3(
			(randf() * 2 - 1) * shake_intensity * fade,
			(randf() * 2 - 1) * shake_intensity * fade,
			(randf() * 2 - 1) * shake_intensity * fade
		)

	# Apply combined offset
	position = base_position + sway_offset + shake_offset


# -----------------------------------------------------
# Call this from anywhere to shake the camera:
# e.g. get_node("Camera3D").start_screenshake(0.2, 0.3)
# -----------------------------------------------------
func start_screenshake(intensity: float, duration: float) -> void:
	shake_intensity = intensity
	shake_duration = duration
	shake_time = 0.0
