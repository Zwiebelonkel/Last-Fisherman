extends MeshInstance3D

@export var rod_tip: Node3D
@export var hook: Node3D
@export var fishing_script: Node  # link to FishingRod

var im := ImmediateMesh.new()
var shader_material := ShaderMaterial.new()

func _ready() -> void:
	mesh = im

	# Shader laden und Material setzen
	var shader := Shader.new()
	shader.code = """
		shader_type spatial;
		render_mode cull_front, unshaded;

		uniform vec3 color : source_color = vec3(0,0,0);
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

	# Schnur anfangs unsichtbar
	visible = false

	if fishing_script:
		fishing_script.connect("line_visible", Callable(self, "set_line_visible"))

func set_line_visible(visible_state: bool) -> void:
	visible = visible_state

func _process(delta: float) -> void:
	if not visible:
		return
	if rod_tip == null or hook == null:
		return

	var start = rod_tip.global_transform.origin
	var end = hook.global_transform.origin

	var local_start = to_local(start)
	var local_end = to_local(end)

	im.clear_surfaces()
	im.surface_begin(Mesh.PRIMITIVE_LINES)
	im.surface_add_vertex(local_start)
	im.surface_add_vertex(local_end)
	im.surface_end()
