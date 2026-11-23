extends MeshInstance3D
## A short free end that follows the moving rod tip through gravity and inertia.

@export_range(0.15, 1.2, 0.05) var loose_length: float = 0.6
@export_range(0.1, 0.6, 0.01) var idle_length: float = 0.24
@export_range(0.001, 0.012, 0.001) var line_width: float = 0.004

const SAMPLES: int = 24
const RELEASE_TIME: float = 0.18
const GRAVITY := Vector3(0.0, -9.81, 0.0)

var _mesh := ImmediateMesh.new()
var _amount: float = 0.0
var _release_time: float = 0.0
var _released: bool = false
var _points := PackedVector3Array()
var _previous := PackedVector3Array()
var _last_tip := Vector3.ZERO
var _hook: Node3D
var _owns_hook: bool = false
var _idle_state: int = -1
var _rotating_state: int = -1
var _hanging_idle: bool = false
@onready var _controller: Node3D = get_parent().get_parent()
@onready var _tip: Node3D = get_parent().get_node("RodTip")
@onready var _animation: AnimationPlayer = get_parent().get_parent().get_node("AnimationPlayer")


func _ready() -> void:
	var controller_script := _controller.get_script() as Script
	if controller_script:
		_idle_state = int(controller_script.get_script_constant_map().get("STATE_IDLE", -1))
		_rotating_state = int(controller_script.get_script_constant_map().get("STATE_ROTATING", -1))
	mesh = _mesh
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_color = Color(0.82, 0.86, 0.78, 1.0)
	material_override = material
	process_priority = 11
	visible = false


func _process(delta: float) -> void:
	var rod_visible: bool = get_parent().is_visible_in_tree()
	var winding: bool = rod_visible and _animation.is_playing() and _animation.current_animation == "power"
	var idle: bool = rod_visible and _is_idle()
	_hanging_idle = idle and not winding
	if winding or idle:
		var starting: bool = not visible or _released or _points.size() < 2
		_released = false
		_release_time = 0.0
		var target_amount: float = 1.0 if winding else minf(idle_length / loose_length, 1.0)
		_amount = move_toward(_amount, target_amount, delta * 7.0)
		if starting:
			_seed_points(idle)
	elif rod_visible and _animation.current_animation == "cast" and _amount > 0.0 and not _released:
		# The forward flick straightens the same free end before releasing the bait.
		_release_time = minf(_release_time + delta, RELEASE_TIME)
	else:
		_amount = 0.0
		visible = false
		_mesh.clear_surfaces()
		if _owns_hook and is_instance_valid(_hook):
			_hook.hide()
		_owns_hook = false
	if _amount > 0.0 and not _released:
		visible = true
		_simulate(delta)
		if _release_time > 0.0:
			_straighten_line(smoothstep(0.0, RELEASE_TIME, _release_time))
		_update_bait()
		_draw_line()


func _is_idle() -> bool:
	if _idle_state < 0:
		return _animation.is_playing() and _animation.current_animation == "idle"
	var state: Variant = _controller.get("state")
	if state != _idle_state and state != _rotating_state:
		return false
	# The cast/recovery line retains the bait until its animation is complete.
	var fishing_line := _controller.get("fishing_line") as Node3D
	return not fishing_line or (not fishing_line.visible and not fishing_line.is_finishing())


func _update_bait() -> void:
	if not is_instance_valid(_hook):
		_hook = _controller.get("hook") as Node3D
	if not _hook or _points.size() < 2:
		return
	var bait := _hook.get_node_or_null("Bait") as Node3D
	var anchor := _hook.get_node_or_null("Bait/LineAnchor") as Node3D
	if not bait or not anchor:
		return
	if not _owns_hook:
		var ripple := _hook.get_node_or_null("Ripple") as Node3D
		if ripple:
			ripple.hide()
		var ripple_animation := _hook.get_node_or_null("AnimationPlayer") as AnimationPlayer
		if ripple_animation:
			ripple_animation.stop()
		for geometry in bait.find_children("*", "GeometryInstance3D", true, false):
			geometry.transparency = 0.0
	_owns_hook = true
	_hook.show()
	if bait.has_method("sync_equipped_bait"):
		bait.sync_equipped_bait()
	# Hang the black stem toward the line instead of rotating a separate preview.
	var toward_line: Vector3 = (_points[-2] - _points[-1]).normalized()
	if toward_line.length_squared() > 0.1:
		var size: Vector3 = bait.global_basis.get_scale()
		bait.global_basis = Basis(Quaternion(Vector3.UP, toward_line)).scaled(size)
	_hook.global_position += _points[-1] - anchor.global_position


func _seed_points(hanging: bool = false) -> void:
	_points.resize(SAMPLES + 1)
	_previous.resize(SAMPLES + 1)
	_last_tip = _tip.global_position
	var forward: Vector3 = -get_parent().global_basis.z.normalized()
	var direction := (forward * 0.4 + Vector3.DOWN * 0.9).normalized()
	if hanging:
		direction = Vector3.DOWN
	for i in range(SAMPLES + 1):
		var t: float = float(i) / float(SAMPLES)
		_points[i] = _last_tip + direction * loose_length * _amount * t
		_previous[i] = _points[i]


func _simulate(delta: float) -> void:
	var tip_position := _tip.global_position
	var motion := tip_position - _last_tip
	_last_tip = tip_position
	if motion.length() > 1.0:
		_seed_points()
	# Let the free end lag behind real rod movement; it has no imposed orbit.
	for i in range(1, SAMPLES + 1):
		var shift: Vector3 = motion * (1.0 - float(i) / float(SAMPLES)) * 0.15
		_points[i] += shift
		_previous[i] += shift
	var steps: int = maxi(1, ceili(minf(delta, 0.1) * 120.0))
	var step: float = minf(delta, 0.1) / float(steps)
	var rest: float = maxf(loose_length * _amount / float(SAMPLES), 0.001)
	for substep in range(steps):
		for i in range(1, SAMPLES + 1):
			var current: Vector3 = _points[i]
			var velocity: Vector3 = (current - _previous[i]) * exp(-3.2 * step)
			_previous[i] = current
			_points[i] = current + velocity + GRAVITY * step * step
		for iteration in range(16):
			_points[0] = tip_position
			for offset in range(SAMPLES):
				var i: int = offset if iteration % 2 == 0 else SAMPLES - 1 - offset
				var separation: Vector3 = _points[i + 1] - _points[i]
				var length: float = separation.length()
				if length < 0.00001:
					continue
				var correction: Vector3 = separation * ((length - rest) / length)
				if i == 0:
					_points[i + 1] -= correction
				else:
					_points[i] += correction * 0.5
					_points[i + 1] -= correction * 0.5
	_points[0] = tip_position
	_previous[0] = tip_position


func _straighten_line(amount: float) -> void:
	var forward: Vector3 = -get_parent().global_basis.z.normalized()
	for i in range(SAMPLES + 1):
		var t: float = float(i) / float(SAMPLES)
		var target: Vector3 = _tip.global_position + forward * loose_length * t
		_points[i] = _points[i].lerp(target, amount)
		_previous[i] = _previous[i].lerp(target, amount)


func finish_windup() -> Vector3:
	# Called by the main line exactly when the bait is released.
	var cast_start := _tip.global_position
	if _amount > 0.0 and not _released:
		_release_time = RELEASE_TIME
		_straighten_line(1.0)
		_update_bait()
		cast_start = _points[-1]
		if _owns_hook:
			cast_start = _hook.global_position
	_owns_hook = false
	_released = true
	_amount = 0.0
	visible = false
	_mesh.clear_surfaces()
	return cast_start


func take_for_recovery() -> PackedVector3Array:
	# Looking around with a parked bait keeps this strand hanging from the tip.
	if _hanging_idle:
		return PackedVector3Array()
	# Transfer the visible curve intact to the loose-line simulation.
	var result := PackedVector3Array()
	if visible and _amount > 0.0:
		_update_bait()
		result = _points.duplicate()
	_owns_hook = false
	_released = true
	_amount = 0.0
	visible = false
	_mesh.clear_surfaces()
	return result


func _draw_line() -> void:
	_mesh.clear_surfaces()
	var camera := get_viewport().get_camera_3d()
	_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	for i in range(_points.size()):
		var point: Vector3 = _points[i]
		var before: Vector3 = _points[maxi(0, i - 1)]
		var after: Vector3 = _points[mini(SAMPLES, i + 1)]
		var direction := (after - before).normalized()
		var view_direction := Vector3.FORWARD
		var width: float = line_width
		if camera:
			view_direction = (camera.global_position - point).normalized()
			var height: float = maxf(get_viewport().get_visible_rect().size.y, 1.0)
			var pixel_size: float = 2.0 * camera.global_position.distance_to(point) * tan(deg_to_rad(camera.fov * 0.5)) / height
			width = maxf(width, pixel_size * 2.0)
		var side := direction.cross(view_direction).normalized()
		if side.length_squared() < 0.1:
			side = get_parent().global_basis.x.normalized()
		_mesh.surface_add_vertex(to_local(point - side * width * 0.5))
		_mesh.surface_add_vertex(to_local(point + side * width * 0.5))
	_mesh.surface_end()
