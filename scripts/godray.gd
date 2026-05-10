@tool
extends MeshInstance3D

@export var light_source: DirectionalLight3D

func _process(delta: float) -> void:
	if light_source:
		set_instance_shader_parameter(
			"light_world_dir",
			-light_source.global_transform.basis.z
		)
