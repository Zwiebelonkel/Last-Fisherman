extends Node3D
## Surface attachment applies while afloat, leaving cast and recovery arcs free.

@export var surface_offset: float = 0.012
@onready var _water: MeshInstance3D = get_parent().get_node("WaterPlane")
@onready var _rod: Node = get_parent().get_node("PlayerCamera/FishingRod")
@onready var _bait: Node3D = get_node("Bait")
@onready var _ripple: MeshInstance3D = get_node("Ripple")
var _bait_rest := Basis.IDENTITY


func _ready() -> void:
	process_priority = 20
	_bait_rest = _bait.basis


func _process(_delta: float) -> void:
	if not visible or not _water.has_method("sample_surface"):
		return
	if _rod.state != _rod.STATE_CASTED and _rod.state != _rod.STATE_BITE and _rod.state != _rod.STATE_MINIGAME:
		return
	if _bait.has_method("sync_equipped_bait"):
		_bait.sync_equipped_bait()
	var surface: Dictionary = _water.sample_surface(global_position)
	global_position = surface.position + Vector3.UP * surface_offset
	var normal: Vector3 = surface.normal
	var tilt := Quaternion(Vector3.UP, normal).slerp(Quaternion.IDENTITY, 0.55)
	_bait.basis = Basis(tilt) * _bait_rest
	if _ripple.visible:
		var right := Vector3.FORWARD.cross(normal).normalized()
		_ripple.global_basis = Basis(right, normal.cross(right).normalized(), normal)
	var splash: GPUParticles3D = _rod.get("splash") as GPUParticles3D
	if splash and splash.emitting:
		splash.global_position = surface.position
