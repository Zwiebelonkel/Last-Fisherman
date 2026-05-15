extends SpotLight3D

# =========================
# DISCO / STROBE LIGHT
# Godot 4.x
# =========================

@export_category("Strobe Settings")

@export var enabled_strobe: bool = true
@export var strobe_speed: float = 0.05
@export var energy_min: float = 0.0
@export var energy_max: float = 14.0

@export_category("Color Settings")

@export var enabled_color_cycle: bool = true
@export var smooth_color_change: bool = true
@export var color_change_speed: float = 6.0

@export var disco_colors: Array[Color] = [
	Color(1, 0, 0),       # Rot
	Color(0, 1, 0),       # Grün
	Color(0, 0, 1),       # Blau
	Color(1, 0, 1),       # Magenta
	Color(0, 1, 1),       # Cyan
	Color(1, 1, 0),       # Gelb
	Color(1, 0.5, 0),     # Orange
	Color(1, 1, 1)        # Weiß
]

@export_category("Rotation")

@export var rotate_light: bool = true
@export var rotation_speed: float = 40.0

@export_category("Pulse")

@export var pulse_energy: bool = true
@export var pulse_speed: float = 2.0
@export var pulse_strength: float = 2.0

# =========================

var strobe_timer := 0.0
var target_color : Color

func _ready():
	if disco_colors.size() > 0:
		target_color = disco_colors.pick_random()

func _process(delta):

	# ====================================
	# ROTATION
	# ====================================

	if rotate_light:
		rotation_degrees.y += rotation_speed * delta

	# ====================================
	# STROBE
	# ====================================

	if enabled_strobe:
		strobe_timer += delta

		if strobe_timer >= strobe_speed:
			strobe_timer = 0.0
			light_energy = randf_range(energy_min, energy_max)

			if enabled_color_cycle and disco_colors.size() > 0:
				target_color = disco_colors.pick_random()

	# ====================================
	# SMOOTH COLOR CHANGE
	# ====================================

	if enabled_color_cycle:

		if smooth_color_change:
			light_color = light_color.lerp(
				target_color,
				color_change_speed * delta
			)
		else:
			light_color = target_color

	# ====================================
	# ENERGY PULSE
	# ====================================

	if pulse_energy:
		light_energy += sin(Time.get_ticks_msec() / 1000.0 * pulse_speed) * pulse_strength
