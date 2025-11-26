extends MeshInstance3D

@export var rod_tip: Node3D
@export var hook: Node3D
@export var fishing_script: Node  # Link zum Hauptscript

var im: ImmediateMesh = ImmediateMesh.new()
var shader_material: ShaderMaterial = ShaderMaterial.new()

# Physik / Realismus
var hook_velocity: Vector3 = Vector3.ZERO
var last_hook_pos: Vector3 = Vector3.ZERO
var segments: int = 24
var hang_factor: float = 0.7
var follow_factor: float = 0.05

# Smoothing / Anti-Flicker
var smoothed_middle: Vector3 = Vector3.ZERO
var smooth_speed: float = 15.0
var is_first_frame: bool = true

# 🆕 Line Extension Animation
var line_extension: float = 0.0  # 0.0 = am Rod, 1.0 = voll ausgerollt
var is_casting: bool = false
var cast_speed: float = 3.0  # Wie schnell die Leine sich ausrollt


func _ready() -> void:
	mesh = im
	
	# Shader
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
render_mode cull_front, unshaded;

uniform vec3 color : source_color = vec3(1.0, 1.0, 1.0);
uniform float thickness : hint_range(0.0, 1.0, 0.01) = 0.01;

uniform vec3 glow_color : source_color = vec3(1.0, 0.5, 0.0);
uniform float glow_strength : hint_range(0.0, 10.0, 0.1) = 20.0;

void vertex() {
	VERTEX += thickness * NORMAL;
}

void fragment() {
	ALBEDO = color;
	EMISSION = glow_color * glow_strength; // 🔥 hier entsteht das Glühen
}

	"""
	
	shader_material.shader = shader
	material_override = shader_material
	visible = false
	
	# Signal verbinden
	if fishing_script:
		fishing_script.connect("line_visible", Callable(self, "set_line_visible"))


func set_line_visible(state: bool) -> void:
	visible = state
	
	if state:
		# Leine startet am Rod-Tip
		is_first_frame = true
		is_casting = true
		line_extension = 0.0
		hook_velocity = Vector3.ZERO
		if hook:
			last_hook_pos = hook.global_transform.origin
			smoothed_middle = rod_tip.global_transform.origin
	else:
		# Reset beim Einholen
		is_casting = false
		line_extension = 0.0


func _physics_process(delta: float) -> void:
	if not visible or not hook:
		return
	
	var current: Vector3 = hook.global_transform.origin
	
	if not is_first_frame:
		hook_velocity = (current - last_hook_pos) / delta
	else:
		hook_velocity = Vector3.ZERO
	
	last_hook_pos = current


func _process(delta: float) -> void:
	if not visible:
		return
	
	if rod_tip == null or hook == null:
		return
	
	# 🆕 Line Extension Animation
	if is_casting and line_extension < 1.0:
		line_extension += cast_speed * delta
		if line_extension >= 1.0:
			line_extension = 1.0
			is_casting = false
	
	var start: Vector3 = rod_tip.global_transform.origin
	var end: Vector3 = hook.global_transform.origin
	
	# 🆕 Interpoliere zwischen Rod-Tip und Hook basierend auf Extension
	var current_end: Vector3 = start.lerp(end, line_extension)
	
	var distance: float = start.distance_to(current_end)
	
	# Durchhang abhängig von Abstand und Extension (weniger Durchhang am Anfang)
	var hang: float = -clamp(distance * 0.1, 0.0, 1.0) * hang_factor * line_extension
	
	# Ziel-Kontrollpunkt berechnen
	var target_middle: Vector3 = (start + current_end) * 0.5
	target_middle.y += hang
	target_middle += hook_velocity * follow_factor * line_extension
	
	# Smooth Interpolation
	if is_first_frame:
		smoothed_middle = target_middle
		is_first_frame = false
	else:
		smoothed_middle = smoothed_middle.lerp(target_middle, smooth_speed * delta)
	
	# Zu lokalen Koordinaten konvertieren
	var local_start: Vector3 = to_local(start)
	var local_middle: Vector3 = to_local(smoothed_middle)
	var local_end: Vector3 = to_local(current_end)
	
	# Schnur zeichnen
	im.clear_surfaces()
	im.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
	
	for i in range(segments + 1):
		var t: float = float(i) / float(segments)
		var p: Vector3 = cubic_bezier(local_start, local_middle, local_middle, local_end, t)
		im.surface_add_vertex(p)
	
	im.surface_end()


func cubic_bezier(p0: Vector3, p1: Vector3, p2: Vector3, p3: Vector3, t: float) -> Vector3:
	var u := 1.0 - t
	return u*u*u * p0 \
		+ 3.0*u*u*t * p1 \
		+ 3.0*u*t*t * p2 \
		+ t*t*t * p3
