extends Node3D

@export var warble_strength: float = 0.01
@export var warble_speed: float = 2.0
@export var wind_strength: float = 0.02
@export var wind_speed: float = 1.0

var meshes: Array[MeshInstance3D] = []

const WARBLE_SHADER = """
shader_type spatial;
render_mode vertex_lighting, cull_disabled;

uniform sampler2D texture_albedo : source_color;
uniform bool has_texture = false;
uniform float warble_strength;
uniform float warble_speed;
uniform float wind_strength;
uniform float wind_speed;
uniform float time_offset;

void vertex() {
	vec3 world_pos = NODE_POSITION_WORLD;
	float height_factor = clamp(world_pos.y / 2.0, 0.0, 1.0);
	float t = TIME * warble_speed + time_offset;
	VERTEX.x += sin(t + world_pos.y * 2.0) * warble_strength;
	VERTEX.z += cos(t + world_pos.x * 2.0) * warble_strength;
	float wind_t = TIME * wind_speed + time_offset;
	VERTEX.x += sin(wind_t + world_pos.y) * wind_strength * height_factor;
	VERTEX.z += cos(wind_t * 0.7) * wind_strength * 0.5 * height_factor;
}

void fragment() {
	vec4 tex = texture(texture_albedo, UV);
	if (has_texture) {
		ALBEDO = tex.rgb;
		ALPHA = tex.a;
		ALPHA_SCISSOR_THRESHOLD = 0.5;
	} else {
		ALBEDO = vec3(0.2, 0.8, 0.3);
	}
}
"""

func _ready() -> void:
	print("TREE SCRIPT STARTED")
	_collect_meshes(self)
	print("Meshes gefunden:", meshes.size())
	_apply_shader()

func _collect_meshes(node: Node) -> void:
	for child in node.get_children():
		if child is MeshInstance3D:
			meshes.append(child)
		_collect_meshes(child)

func _apply_shader() -> void:
	var shader = Shader.new()
	shader.code = WARBLE_SHADER

	for mesh_instance in meshes:
		if mesh_instance.mesh == null:
			continue

		var surface_count = mesh_instance.mesh.get_surface_count()

		for surface in range(surface_count):
			var original = mesh_instance.get_active_material(surface)

			var mat = ShaderMaterial.new()
			mat.shader = shader

			if original and original is BaseMaterial3D:
				if original.albedo_texture:
					mat.set_shader_parameter("texture_albedo", original.albedo_texture)
					mat.set_shader_parameter("has_texture", true)
				else:
					mat.set_shader_parameter("has_texture", false)
			else:
				mat.set_shader_parameter("has_texture", false)

			mat.set_shader_parameter("warble_strength", warble_strength)
			mat.set_shader_parameter("warble_speed", warble_speed)
			mat.set_shader_parameter("wind_strength", wind_strength)
			mat.set_shader_parameter("wind_speed", wind_speed)
			mat.set_shader_parameter("time_offset", randf() * 10.0)

			mesh_instance.set_surface_override_material(surface, mat)
