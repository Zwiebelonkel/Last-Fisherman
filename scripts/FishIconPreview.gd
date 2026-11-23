extends Node3D
## Rotating detail view of the same solid fish used in the catch flight.

const FishVisual := preload("res://scripts/FishVisual3D.gd")

@export_range(0.04, 0.5, 0.01) var depth: float = 0.22
@export var rotation_speed: float = 30.0

@onready var mesh: FishVisual = $MeshInstance3D
@onready var camera: Camera3D = $Camera3D


func _ready() -> void:
	mesh.depth = depth
	camera.position = Vector3(0.0, 0.2, 3.0)
	camera.look_at(Vector3.ZERO)
	get_viewport().size_changed.connect(_fit_camera)


func set_texture(texture: Texture2D, is_shiny: bool = false) -> void:
	mesh.set_texture(texture, is_shiny)
	mesh.rotation = Vector3(0.0, deg_to_rad(-20.0), 0.0)
	_fit_camera()


func _process(delta: float) -> void:
	var container := get_viewport().get_parent() as CanvasItem
	if container and not container.is_visible_in_tree():
		return
	if mesh.mesh:
		mesh.rotation.y = wrapf(mesh.rotation.y + deg_to_rad(rotation_speed) * delta, -PI, PI)


func _fit_camera() -> void:
	if not mesh.mesh:
		return
	var bounds: Vector3 = mesh.mesh.get_aabb().size
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var aspect: float = viewport_size.x / maxf(viewport_size.y, 1.0)
	var turn_width: float = Vector2(bounds.x, bounds.z).length()
	camera.size = maxf(bounds.y + turn_width * 0.07, turn_width / aspect) * 1.18
