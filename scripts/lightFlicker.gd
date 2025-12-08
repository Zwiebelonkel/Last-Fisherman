extends Node
## Lässt Lichter realistisch flackern
## Funktioniert mit: Light3D, OmniLight3D, SpotLight3D, DirectionalLight3D

# ========================================
# FLICKER SETTINGS
# ========================================
@export_group("Flicker Settings")
@export var enabled := true
@export_enum("Smooth", "Random", "Candle", "Fluorescent", "Lightning") var flicker_type: String = "Smooth"

# Flicker Intensität
@export_range(0.0, 1.0) var min_energy := 0.3
@export_range(0.0, 2.0) var max_energy := 1.0

# Geschwindigkeit
@export_range(0.1, 10.0) var flicker_speed := 2.0

# Optional: Farb-Flicker
@export var flicker_color := false
@export var min_color := Color(1.0, 0.9, 0.7)  # Warm
@export var max_color := Color(1.0, 1.0, 1.0)  # Weiß

# ========================================
# ADVANCED SETTINGS
# ========================================
@export_group("Advanced")
@export var random_offset := true  # Startet mit zufälligem Offset
@export_range(0.0, 1.0) var flicker_chance := 1.0  # 1.0 = immer, 0.0 = nie

# ========================================
# INTERNAL VARIABLES
# ========================================
var light: Light3D
var original_energy: float
var original_color: Color
var time_passed: float = 0.0
var noise := FastNoiseLite.new()

func _ready():
	# Node, an dem das Script hängt
	var node = self

	if node is Light3D:
		light = node
	else:
		push_error("LightFlicker: Script muss auf einem Light3D hängen!")
		return

	original_energy = light.light_energy
	original_color = light.light_color

	noise.seed = randi()
	noise.frequency = 0.5

	if random_offset:
		time_passed = randf_range(0.0, 100.0)

	print("💡 Light Flicker aktiviert:", flicker_type)



func _process(delta):
	if not enabled or not light:
		return
	
	# Flicker Chance prüfen
	if randf() > flicker_chance:
		return
	
	time_passed += delta * flicker_speed
	
	# Wähle Flicker-Typ
	match flicker_type:
		"Smooth":
			smooth_flicker(delta)
		"Random":
			random_flicker(delta)
		"Candle":
			candle_flicker(delta)
		"Fluorescent":
			fluorescent_flicker(delta)
		"Lightning":
			lightning_flicker(delta)

# ========================================
# FLICKER TYPES
# ========================================

# Sanftes, kontinuierliches Flackern (z.B. alte Glühbirne)
func smooth_flicker(delta):
	var flicker = noise.get_noise_1d(time_passed)
	flicker = (flicker + 1.0) / 2.0  # Normalize 0-1
	
	light.light_energy = lerp(min_energy, max_energy, flicker)
	
	if flicker_color:
		light.light_color = min_color.lerp(max_color, flicker)

# Zufälliges, unvorhersehbares Flackern
func random_flicker(delta):
	if randf() < 0.1:  # 10% Chance pro Frame
		light.light_energy = randf_range(min_energy, max_energy)
		
		if flicker_color:
			light.light_color = min_color.lerp(max_color, randf())

# Kerzen-ähnliches Flackern
func candle_flicker(delta):
	var flicker1 = noise.get_noise_1d(time_passed)
	var flicker2 = noise.get_noise_1d(time_passed * 2.3)
	var flicker3 = noise.get_noise_1d(time_passed * 0.7)
	
	var combined = (flicker1 + flicker2 * 0.5 + flicker3 * 0.3) / 1.8
	combined = (combined + 1.0) / 2.0  # Normalize
	
	light.light_energy = lerp(min_energy, max_energy, combined)
	
	if flicker_color:
		# Kerzen haben mehr Orange/Gelb
		var warm_color = Color(1.0, 0.7 + combined * 0.3, 0.3)
		light.light_color = warm_color

# Defekte Neonröhre (schnelles An/Aus)
func fluorescent_flicker(delta):
	var flicker = sin(time_passed * 20.0) + cos(time_passed * 17.3)
	
	if flicker > 0.5:
		light.light_energy = max_energy
	elif flicker < -0.5:
		light.light_energy = min_energy
	else:
		light.light_energy = lerp(min_energy, max_energy, 0.5)
	
	# Manchmal komplettes Ausschalten
	if randf() < 0.01:
		light.light_energy = 0.0

# Blitz-Effekt (selten, kurz, hell)
func lightning_flicker(delta):
	if randf() < 0.005:  # 0.5% Chance
		# Haupt-Blitz
		light.light_energy = max_energy * 2.0
		await get_tree().create_timer(0.05).timeout
		light.light_energy = 0.0
		await get_tree().create_timer(0.1).timeout
		
		# Nach-Blitz
		if randf() < 0.5:
			light.light_energy = max_energy * 1.5
			await get_tree().create_timer(0.03).timeout
			light.light_energy = 0.0
	else:
		# Normal dunkel
		light.light_energy = min_energy * 0.1

# ========================================
# PUBLIC FUNCTIONS
# ========================================

# Flicker ein/ausschalten
func set_enabled(value: bool):
	enabled = value
	if not enabled and light:
		light.light_energy = original_energy
		light.light_color = original_color

# Flicker-Typ zur Laufzeit ändern
func set_flicker_type(type: String):
	flicker_type = type

# Temporäres intensives Flackern auslösen
func trigger_intense_flicker(duration: float = 1.0):
	var old_speed = flicker_speed
	var old_min = min_energy
	
	flicker_speed = 10.0
	min_energy = 0.0
	
	await get_tree().create_timer(duration).timeout
	
	flicker_speed = old_speed
	min_energy = old_min
