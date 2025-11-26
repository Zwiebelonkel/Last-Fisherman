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
var hang_factor: float = 0.3
var follow_factor: float = 0.05

func _ready() -> void:
	mesh = im

	# Shader
	var shader := Shader.new()
	shader.code = """
		shader_type spatial;
		render_mode cull_front, unshaded;

		uniform vec3 color : source_color = vec3(0.05,0.05,0.05);
		uniform float thickness : hint_range(0.0, 1.0, 0.01) = 0.01;

		void vertex() {
			VERTEX += thickness * NORMAL;
		}

		void fragment() {
			ALBEDO = color;
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

func _physics_process(delta: float) -> void:
	if hook:
		var current: Vector3 = hook.global_transform.origin
		hook_velocity = (current - last_hook_pos) / delta
		last_hook_pos = current

func _process(delta: float) -> void:
	if not visible:
		return
	if rod_tip == null or hook == null:
		return

	var start: Vector3 = rod_tip.global_transform.origin
	var end: Vector3 = hook.global_transform.origin

	var distance: float = start.distance_to(end)

	# Durchhang abhängig von Abstand
	var hang: float = -clamp(distance * 0.1, 0.0, 1.0) * hang_factor

	# Kontrollpunkt (für Kurve)
	var middle: Vector3 = (start + end) * 0.5
	middle.y += hang
	middle += hook_velocity * follow_factor

	var local_start: Vector3 = to_local(start)
	var local_middle: Vector3 = to_local(middle)
	var local_end: Vector3 = to_local(end)

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
