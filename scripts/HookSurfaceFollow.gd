extends Node3D
## Surface attachment applies while afloat, leaving cast and recovery arcs free.

@export var surface_offset: float = 0.012
@onready var _water: MeshInstance3D = get_parent().get_node("WaterPlane")
@onready var _rod: Node = get_parent().get_node("PlayerCamera/FishingRod")
@onready var _bait: Node3D = get_node("Bait")
@onready var _ripple: MeshInstance3D = get_node("Ripple")
var _bait_rest := Basis.IDENTITY
var _ripple_origin := Vector3.ZERO
var fight := preload("res://scripts/FishFightVisuals.gd").new()


func _ready() -> void:
	process_priority = 20
	_bait_rest = _bait.basis
	_ripple_origin = _ripple.position
	fight.setup(_water, _rod.rod_tip.get_parent(), _rod.catch_progress)


func _process(delta: float) -> void:
	if fight.escaping:
		fight.update_escape(delta)
	if not visible or not _water.has_method("sample_surface"):
		return
	if _rod.state != _rod.STATE_CASTED and _rod.state != _rod.STATE_BITE and _rod.state != _rod.STATE_MINIGAME:
		return
	if _bait.has_method("sync_equipped_bait"):
		_bait.sync_equipped_bait()
	var offset := fight.update(0.0 if _rod.paused else delta, global_position)
	var surface: Dictionary = _water.sample_surface(global_position + offset)
	# The controller and line retain the gameplay anchor. Only the visible bait
	# dips; the ripple tracks the displaced water and the rope pins to Bait/LineAnchor.
	if offset.is_zero_approx():
		global_position = surface.position + Vector3.UP * surface_offset
		_bait.position = Vector3.ZERO
		_ripple.position = _ripple_origin
	else:
		_bait.global_position = surface.position + Vector3.UP * (surface_offset + offset.y)
		_ripple.global_position = surface.position + Vector3.UP * surface_offset + global_basis * _ripple_origin
	var normal: Vector3 = surface.normal
	var tilt := Quaternion(Vector3.UP, normal).slerp(Quaternion.IDENTITY, 0.55)
	_bait.basis = Basis(tilt) * _bait_rest
	if _ripple.visible:
		var right := Vector3.FORWARD.cross(normal).normalized()
		_ripple.global_basis = Basis(right, normal.cross(right).normalized(), normal)
	var splash: GPUParticles3D = _rod.get("splash") as GPUParticles3D
	if splash and splash.emitting:
		splash.global_position = surface.position


func finish_fight(success_or_retrieval: bool) -> void:
	# Transfer the visible position to the line before its recovery/break or catch flight.
	global_position = _bait.global_position
	_bait.position = Vector3.ZERO
	_ripple.position = _ripple_origin
	if success_or_retrieval:
		fight.reset()
	else:
		fight.escape()


func _exit_tree() -> void:
	fight.reset()
