extends Node3D

@onready var mesh: MeshInstance3D = $MeshInstance3D

var target_rotation: float = 0.0
var current_rotation: float = 0.0
var max_angle: float = 50.0

func _ready():
	$Camera3D.position = Vector3(0.0, 0.3, 3.0)
	$Camera3D.look_at(Vector3.ZERO)
	
	$DirectionalLight3D.position = Vector3(2, 3, 2)
	$DirectionalLight3D.look_at(Vector3.ZERO)
	
	mesh.mesh = create_extrude_mesh(0.001)
	
	var mat := ShaderMaterial.new()
	mat.shader = load("res://shader/extrusion.gdshader")
	
	var tex := load("res://assets/fish/sardine.png")
	mat.set_shader_parameter("Texture", tex)
	mat.set_shader_parameter("extruded_alpha_cull", 0.5)
	mat.set_shader_parameter("image_alpha_cull", 0.5)
	mat.set_shader_parameter("keep_image", true)
	mat.set_shader_parameter("opaque_extrude", true)
	mat.set_shader_parameter("mix_strength", 0.3)
	mat.set_shader_parameter("color_mix", Color(0.0, 0.0, 0.0, 1.0))
	mat.set_shader_parameter("texture_calls", 100)
	mat.set_shader_parameter("infinite_holes", false)
	mat.set_shader_parameter("ray_bias", 1.0)
	mat.set_shader_parameter("offset", Vector2(0, 0))
	mat.set_shader_parameter("Hframes", 1)
	mat.set_shader_parameter("Vframes", 1)
	mat.set_shader_parameter("frame", 0)
	
	mesh.material_override = mat

func create_extrude_mesh(depth: float = 0.002) -> ArrayMesh:
	var arr_mesh := ArrayMesh.new()
	var verts := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	var d := depth / 2.0
	var i := 0

	# FRONT (+Z)
	verts.append_array([
		Vector3(-1, 1, d), Vector3( 1, 1, d),
		Vector3( 1,-1, d), Vector3(-1,-1, d)
	])
	uvs.append_array([
		Vector2(0.0,      0.0), Vector2(1.0/3.0, 0.0),
		Vector2(1.0/3.0,  0.5), Vector2(0.0,     0.5)
	])
	indices.append_array([i,i+1,i+2, i,i+2,i+3]); i += 4

	# RIGHT (+X)
	verts.append_array([
		Vector3( 1, 1, d), Vector3( 1, 1,-d),
		Vector3( 1,-1,-d), Vector3( 1,-1, d)
	])
	uvs.append_array([
		Vector2(1.0/3.0, 0.0), Vector2(2.0/3.0, 0.0),
		Vector2(2.0/3.0, 0.5), Vector2(1.0/3.0, 0.5)
	])
	indices.append_array([i,i+1,i+2, i,i+2,i+3]); i += 4

	# BACK (-Z) → gespiegelt in X
	verts.append_array([
		Vector3( 1, 1,-d), Vector3(-1, 1,-d),
		Vector3(-1,-1,-d), Vector3( 1,-1,-d)
	])
	uvs.append_array([
		Vector2(1.0/3.0, 0.0), Vector2(0.0,      0.0),
		Vector2(0.0,     0.5), Vector2(1.0/3.0,  0.5)
	])
	indices.append_array([i,i+1,i+2, i,i+2,i+3]); i += 4

	# LEFT (-X)
	verts.append_array([
		Vector3(-1, 1,-d), Vector3(-1, 1, d),
		Vector3(-1,-1, d), Vector3(-1,-1,-d)
	])
	uvs.append_array([
		Vector2(0.0,      0.0), Vector2(1.0/3.0, 0.0),
		Vector2(1.0/3.0,  0.5), Vector2(0.0,     0.5)
	])
	indices.append_array([i,i+1,i+2, i,i+2,i+3]); i += 4

	# TOP (+Y)
	verts.append_array([
		Vector3(-1, 1, d), Vector3( 1, 1, d),
		Vector3( 1, 1,-d), Vector3(-1, 1,-d)
	])
	uvs.append_array([
		Vector2(1.0/3.0, 0.5), Vector2(2.0/3.0, 0.5),
		Vector2(2.0/3.0, 1.0), Vector2(1.0/3.0, 1.0)
	])
	indices.append_array([i,i+1,i+2, i,i+2,i+3]); i += 4

	# BOTTOM (-Y)
	verts.append_array([
		Vector3(-1,-1,-d), Vector3( 1,-1,-d),
		Vector3( 1,-1, d), Vector3(-1,-1, d)
	])
	uvs.append_array([
		Vector2(2.0/3.0, 0.5), Vector2(1.0,      0.5),
		Vector2(1.0,     1.0), Vector2(2.0/3.0,  1.0)
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
	target_rotation = sin(Time.get_ticks_msec() / 1000.0 * 0.8) * 25.0
	target_rotation = clamp(target_rotation, -max_angle, max_angle)
	current_rotation = lerp(current_rotation, target_rotation, delta * 8.0)
	mesh.rotation_degrees.y = current_rotation
