extends Node3D
@onready var mesh: MeshInstance3D = $MeshInstance3D
@export var rotation_speed: float = 30.0  # Grad pro Sekunde

func _ready():
	$Camera3D.position = Vector3(0.0, 0.3, 3.0)
	$Camera3D.look_at(Vector3.ZERO)
	
	$DirectionalLight3D.position = Vector3(2, 3, 2)
	$DirectionalLight3D.look_at(Vector3.ZERO)
	
	mesh.mesh = create_extrude_mesh(0.02)
	
	var mat := ShaderMaterial.new()
	mat.shader = load("res://shader/extrusion.gdshader")
	
	mat.set_shader_parameter("extruded_alpha_cull", 0.5)
	mat.set_shader_parameter("image_alpha_cull", 0.5)
	mat.set_shader_parameter("keep_image", true)
	mat.set_shader_parameter("opaque_extrude", true)
	mat.set_shader_parameter("mix_strength", 0.0)
	mat.set_shader_parameter("color_mix", Color(0.0, 0.0, 0.0, 1.0))
	mat.set_shader_parameter("extrude_scale", 0.08)
	mat.set_shader_parameter("ray_bias", 2.0)            # ← weicherer Übergang
	mat.set_shader_parameter("texture_calls", 100)
	mat.set_shader_parameter("infinite_holes", false)
	mat.set_shader_parameter("offset", Vector2(0, 0))
	mat.set_shader_parameter("Hframes", 1)
	mat.set_shader_parameter("Vframes", 1)
	mat.set_shader_parameter("frame", 0)
	mat.set_shader_parameter("hide_sides", true)
	
	mesh.material_override = mat

func create_extrude_mesh(depth: float = 0.002) -> ArrayMesh:
	var arr_mesh := ArrayMesh.new()
	var verts := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	var d := depth / 2.0
	var i := 0
	var w := 1.0 / 3.0
	var h := 1.0 / 2.0

	# ---------------- FRONT (+Z)  (0,0)
	verts.append_array([
		Vector3(-1, 1, d), Vector3( 1, 1, d),
		Vector3( 1,-1, d), Vector3(-1,-1, d)
	])
	uvs.append_array([
		Vector2(0.0, 0.0),
		Vector2(w,   0.0),
		Vector2(w,   h),
		Vector2(0.0, h)
	])
	indices.append_array([i,i+1,i+2, i,i+2,i+3]); i += 4

	# ---------------- BACK (-Z) (2,0)
	verts.append_array([
		Vector3( 1, 1,-d), Vector3(-1, 1,-d),
		Vector3(-1,-1,-d), Vector3( 1,-1,-d)
	])
	uvs.append_array([
		Vector2(w*2.0, 0.0),
		Vector2(1.0,   0.0),
		Vector2(1.0,   h),
		Vector2(w*2.0, h)
	])
	indices.append_array([i,i+1,i+2, i,i+2,i+3]); i += 4

	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX]  = indices
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return arr_mesh

func _process(delta):
	mesh.rotation_degrees.y += rotation_speed * delta
