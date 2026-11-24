extends MeshInstance3D

@export var rod_tip: Node3D
@export var hook: Node3D
@export var fishing_script: Node
@export_range(24, 192, 12) var segments: int = 96
@export_range(0.001, 0.02, 0.001) var line_width: float = 0.004

const GRAVITY := Vector3(0.0, -9.81, 0.0)
const BREAK_LIFETIME: float = 1.25
const SOLVER_ITERATIONS: int = 30

var im := ImmediateMesh.new()
var _material := StandardMaterial3D.new()
var _points := PackedVector3Array()
var _previous := PackedVector3Array()
var _rest_length: float = 0.01
var _clock: float = 0.0
var _water_height: float = 0.0
var _broken: bool = false
var _break_age: float = 0.0
var _break_joint: int = 0
var _flying: bool = false
var _flight_id: int = 0
var _flight_time: float = 0.0
var _flight_duration: float = 1.0
var _flight_start := Vector3.ZERO
var _flight_target := Vector3.ZERO
var _flight_velocity := Vector3.ZERO
var _last_start := Vector3.ZERO
var _last_end := Vector3.ZERO
var _returning: bool = false
var _finishing: bool = false
var _return_time: float = 0.0
var _return_duration: float = 0.6
var _return_start := Vector3.ZERO
var _bait_geometry: Array[GeometryInstance3D] = []
var _surface: MeshInstance3D
var _bite_state: int = -1
var _minigame_state: int = -1
var _line_tension: float = 0.0
var _line_anchor: Node3D
var _pending_segments: int = 0


func _ready() -> void:
	process_priority = 30
	set_fishing_line_segments(Player.fishing_line_segments)
	if fishing_script:
		_surface = fishing_script.get("waterplane") as MeshInstance3D
		var controller := fishing_script.get_script() as Script
		if controller:
			var states: Dictionary = controller.get_script_constant_map()
			_bite_state = int(states.get("STATE_BITE", -1))
			_minigame_state = int(states.get("STATE_MINIGAME", -1))
	mesh = im
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_material.render_priority = 1
	_material.albedo_color = Color(0.82, 0.86, 0.78, 1.0)
	material_override = _material
	visible = false
	var bait := hook.get_node_or_null("Bait") if hook else null
	if bait:
		_line_anchor = bait.get_node_or_null("LineAnchor") as Node3D
		for geometry in bait.find_children("*", "GeometryInstance3D", true, false):
			_bait_geometry.append(geometry as GeometryInstance3D)
	if fishing_script and fishing_script.has_signal("line_visible"):
		fishing_script.connect("line_visible", set_line_visible)
	if fishing_script and fishing_script.has_signal("line_broken"):
		fishing_script.connect("line_broken", break_line)


func set_fishing_line_segments(count: int) -> void:
	count = clampi(count, 24, 192)
	if _broken:
		# Keep both torn ends intact until the recoil has finished.
		_pending_segments = count
		return
	if count == segments:
		return
	var old_count := segments
	if _points.size() == old_count + 1:
		var points := PackedVector3Array()
		var previous := PackedVector3Array()
		points.resize(count + 1)
		previous.resize(count + 1)
		for i in range(count + 1):
			var along := float(i) * old_count / count
			var edge := mini(int(along), old_count - 1)
			var weight := along - edge
			points[i] = _points[edge].lerp(_points[edge + 1], weight)
			previous[i] = _previous[edge].lerp(_previous[edge + 1], weight)
		# Preserve pinned endpoints exactly, including large world coordinates.
		points[0] = _points[0]
		points[count] = _points[-1]
		previous[0] = _previous[0]
		previous[count] = _previous[-1]
		_points = points
		_previous = previous
		_rest_length *= float(old_count) / count
	segments = count


func set_line_visible(state: bool) -> void:
	if not state:
		cancel_cast()
		# The two loose ends outlive the normal fishing reset.
		if not _broken:
			_hide_line()
		return
	if not is_instance_valid(rod_tip) or not is_instance_valid(hook):
		return
	_broken = false
	_break_age = 0.0
	_line_tension = 0.0
	_water_height = hook.global_position.y
	_material.albedo_color.a = 1.0
	visible = true
	_set_bait_fade(0.0)
	_seed_points()


func cast_to(target: Vector3, power: float) -> bool:
	cancel_cast()
	var bait := hook.get_node_or_null("Bait")
	if bait and bait.has_method("sync_equipped_bait"):
		bait.sync_equipped_bait()
	target = get_water_position(target)
	var flight_id: int = _flight_id
	_flight_start = rod_tip.global_position
	var tip_loop := rod_tip.get_parent().get_node_or_null("TipLineLoop")
	if tip_loop and tip_loop.has_method("finish_windup"):
		_flight_start = tip_loop.finish_windup()
	_flight_target = target
	var horizontal := target - _flight_start
	horizontal.y = 0.0
	# Constant horizontal speed and gravity give the bait a true ballistic arc.
	_flight_duration = clampf(horizontal.length() / lerpf(11.0, 15.0, power), 0.42, 1.05)
	_flight_velocity = (target - _flight_start) / _flight_duration - GRAVITY * _flight_duration * 0.5
	_flight_time = 0.0
	hook.global_position = _flight_start
	hook.visible = true
	var ripple := hook.get_node_or_null("Ripple") as Node3D
	if ripple:
		ripple.visible = false
	set_line_visible(true)
	_water_height = target.y
	_flying = true
	while _flying and flight_id == _flight_id:
		await get_tree().physics_frame
	return flight_id == _flight_id


func cancel_cast() -> void:
	_flight_id += 1
	_flying = false
	_returning = false
	_finishing = false


func is_finishing() -> bool:
	return _finishing or _broken or _returning


func _get_line_end() -> Vector3:
	return _line_anchor.global_position if is_instance_valid(_line_anchor) else hook.global_position


func _place_hook_line_end(point: Vector3) -> void:
	hook.global_position += point - _get_line_end()


func get_water_position(point: Vector3) -> Vector3:
	if is_instance_valid(_surface) and _surface.has_method("get_surface_position"):
		var offset: Variant = hook.get("surface_offset")
		return _surface.get_surface_position(point) + Vector3.UP * (float(offset) if offset != null else 0.0)
	return point


func finish_line(return_bait: bool = true) -> void:
	if not is_finishing():
		if return_bait:
			hook.finish_fight(true)
		cancel_cast()
		if not visible:
			_take_windup_line()
		if not visible:
			return
		_hide_ripple()
		if return_bait:
			_return_start = hook.global_position
			_return_duration = clampf(_return_start.distance_to(rod_tip.global_position) / 10.0, 0.4, 0.9)
			_return_time = 0.0
			_returning = true
			hook.visible = true
			_set_bait_fade(0.0)
		else:
			break_line()
	var finish_id: int = _flight_id
	_finishing = true
	while (_broken or _returning) and finish_id == _flight_id:
		await get_tree().physics_frame
	if finish_id == _flight_id:
		_finishing = false


func _take_windup_line() -> void:
	var tip_loop := rod_tip.get_parent().get_node_or_null("TipLineLoop")
	if not tip_loop or not tip_loop.has_method("take_for_recovery"):
		return
	var curve: PackedVector3Array = tip_loop.take_for_recovery()
	if curve.size() < 2:
		return
	# Preserve the visible free end when handing it to the main line.
	var lengths := PackedFloat32Array([0.0])
	for i in range(1, curve.size()):
		lengths.append(lengths[-1] + curve[i - 1].distance_to(curve[i]))
	var total: float = lengths[-1]
	_points.resize(segments + 1)
	_previous.resize(segments + 1)
	var edge: int = 1
	for i in range(segments + 1):
		var along: float = total * float(i) / float(segments)
		while edge < curve.size() - 1 and lengths[edge] < along:
			edge += 1
		var span: float = maxf(lengths[edge] - lengths[edge - 1], 0.00001)
		_points[i] = curve[edge - 1].lerp(curve[edge], clampf((along - lengths[edge - 1]) / span, 0.0, 1.0))
		_previous[i] = _points[i]
	_rest_length = maxf(total / float(segments), 0.002)
	_place_hook_line_end(_points[-1])
	_last_start = rod_tip.global_position
	_last_end = _get_line_end()
	var water := fishing_script.get("waterplane") as Node3D if fishing_script else null
	if water:
		_water_height = water.global_position.y
	_material.albedo_color.a = 1.0
	visible = true
	_broken = false


func _hide_ripple() -> void:
	var ripple := hook.get_node_or_null("Ripple") as Node3D
	if ripple:
		ripple.hide()
	var ripple_animation := hook.get_node_or_null("AnimationPlayer") as AnimationPlayer
	if ripple_animation:
		ripple_animation.stop()


func _set_bait_fade(amount: float) -> void:
	for geometry in _bait_geometry:
		geometry.transparency = amount


func break_line() -> void:
	if not visible or _broken or _points.size() < 3:
		return
	cancel_cast()
	_hide_ripple()
	_broken = true
	_break_age = 0.0
	_break_joint = clampi(roundi(segments * 0.64), 2, segments - 3)
	var direction := (_get_line_end() - rod_tip.global_position).normalized()
	var sideways := direction.cross(Vector3.UP).normalized()
	# Release the stored tension in opposite directions at the torn joint.
	for i in range(1, segments + 1):
		var near_cut: float
		var recoil: Vector3
		if i <= _break_joint:
			near_cut = pow(float(i) / float(_break_joint), 3.0)
			recoil = (-direction * 6.0 + Vector3.UP * 2.2 + sideways * 1.5) * near_cut
		else:
			near_cut = pow(1.0 - float(i - _break_joint - 1) / float(segments - _break_joint), 2.0)
			recoil = (direction * 3.5 + Vector3.UP * 1.2 - sideways) * near_cut
		_previous[i] = _points[i] - recoil / 120.0
	_draw_line()


func _seed_points() -> void:
	_points.resize(segments + 1)
	_previous.resize(segments + 1)
	var start := rod_tip.global_position
	var end := _get_line_end()
	_last_start = start
	_last_end = end
	var sag: float = minf(start.distance_to(end) * 0.035, 0.45)
	for i in range(segments + 1):
		var t: float = float(i) / float(segments)
		var point := start.lerp(end, t) + Vector3.DOWN * sin(t * PI) * sag
		_points[i] = point
		_previous[i] = point
	_rest_length = maxf(start.distance_to(end) * 1.015 / float(segments), 0.002)


func _physics_process(delta: float) -> void:
	if not visible or not is_instance_valid(rod_tip) or not is_instance_valid(hook):
		return
	_clock += delta
	if _returning:
		_return_time = minf(_return_time + delta, _return_duration)
		var progress: float = _return_time / _return_duration
		var eased: float = 1.0 - pow(1.0 - progress, 2.0)
		var target := rod_tip.global_position - (_get_line_end() - hook.global_position)
		var height: float = minf(_return_start.distance_to(target) * 0.2, 0.8)
		hook.global_position = _return_start.lerp(target, eased) + Vector3.UP * sin(PI * eased) * height
		if progress >= 1.0:
			hook.global_position = target
			_hide_line()
			return
	if _flying:
		_flight_time = minf(_flight_time + delta, _flight_duration)
		hook.global_position = _flight_start + _flight_velocity * _flight_time + GRAVITY * (0.5 * _flight_time * _flight_time)
		var landing := get_water_position(_flight_target)
		var arrival: float = smoothstep(0.6, 1.0, _flight_time / _flight_duration)
		hook.global_position.y += (landing.y - _flight_target.y) * arrival
		if _flight_time >= _flight_duration:
			hook.global_position = landing
			_flying = false
	elif not _broken and not _returning:
		hook.global_position = get_water_position(hook.global_position)
		_water_height = hook.global_position.y
	if _broken:
		_break_age += delta
		if _break_age >= BREAK_LIFETIME:
			_hide_line()
			return
		_material.albedo_color.a = 1.0 - smoothstep(0.85, BREAK_LIFETIME, _break_age)
		_set_bait_fade(smoothstep(0.85, BREAK_LIFETIME, _break_age))
	# Fixed small substeps keep the recoil stable at different frame rates.
	var steps: int = maxi(1, ceili(delta / (1.0 / 120.0)))
	var step: float = delta / float(steps)
	for substep in range(steps):
		_simulate(step)
	if _broken:
		_place_hook_line_end(_points[-1])


func _simulate(delta: float) -> void:
	var start := rod_tip.global_position
	var end := _get_line_end()
	if not _broken:
		# Pay out from the reel, but let rod movement tug the line into a swing.
		var tip_motion: Vector3 = start - _last_start
		var bait_motion: Vector3 = end - _last_end
		for i in range(1, segments):
			var t: float = float(i) / float(segments)
			var tip_follow: float = 0.8 if _flying else 0.25
			var payout: Vector3 = tip_motion * (1.0 - t) * tip_follow + bait_motion * t
			_points[i] += payout
			_previous[i] += payout
	_last_start = start
	_last_end = end
	var distance: float = start.distance_to(end)
	var target_tension: float = 0.0
	if fishing_script and not _flying and not _returning and not _broken:
		var state: Variant = fishing_script.get("state")
		if _bite_state >= 0 and state == _bite_state:
			target_tension = 0.65
		elif _minigame_state >= 0 and state == _minigame_state:
			target_tension = 0.8
		if fishing_script.get("input_active") == true:
			target_tension = 1.0
	_line_tension = lerpf(_line_tension, target_tension, 1.0 - exp(-12.0 * delta))
	if not _broken:
		# The reel pays out during flight; pulling removes most of the slack.
		var slack: float = 0.045 if _flying else lerpf(0.018, 0.003, _line_tension)
		if _returning:
			slack = 0.005
		_rest_length = maxf((distance * (1.0 + slack) + 0.025) / float(segments), 0.002)
	var damping: float = exp(-3.5 * delta)
	for i in range(1, segments + 1):
		if not _broken and i == segments:
			continue
		var current: Vector3 = _points[i]
		var velocity: Vector3 = (current - _previous[i]) * damping
		_previous[i] = current
		var wind := Vector3(sin(_clock * 1.7 + float(i) / segments * 4.68) * 0.22, 0.0, cos(_clock * 1.2) * 0.12)
		_points[i] = current + velocity + (GRAVITY + wind) * delta * delta
		if not _broken:
			# A light guide keeps a newly paid-out line from bunching at the tip.
			var t: float = float(i) / float(segments)
			var guide := start.lerp(end, t)
			guide.y -= sin(t * PI) * minf(distance * 0.045, 0.5) * lerpf(1.0, 0.25, _line_tension)
			_points[i] += (guide - _points[i]) * minf(28.0 * delta * delta, 1.0)
		elif _points[i].y < _water_height:
			# Water damps the loose end as it sinks below the surface.
			_points[i] = current + velocity * exp(-12.0 * delta) + GRAVITY * 0.12 * delta * delta
	for iteration in range(maxi(SOLVER_ITERATIONS, ceili(segments / 3.0))):
		_pin_ends(start, end)
		# Alternate directions so neither the tip nor bait dominates the solver.
		for offset in range(segments):
			var i: int = offset if iteration % 2 == 0 else segments - 1 - offset
			if _broken and i == _break_joint:
				continue
			var separation: Vector3 = _points[i + 1] - _points[i]
			var length: float = separation.length()
			if length < 0.00001:
				continue
			var rest: float = _rest_length
			if _broken and i < _break_joint:
				rest *= lerpf(1.0, 0.62, smoothstep(0.15, 1.1, _break_age))
			# A rope resists stretching, not compression. Forcing slack links
			# apart makes long casts buckle into a zigzag on the water surface.
			if not _broken and length <= rest:
				continue
			var correction: Vector3 = separation * ((length - rest) / length)
			if i == 0:
				_points[i + 1] -= correction
			elif not _broken and i + 1 == segments:
				_points[i] += correction
			else:
				_points[i] += correction * 0.5
				_points[i + 1] -= correction * 0.5
		if not _broken and not _flying and not _returning:
			for i in range(1, segments):
				_points[i].y = maxf(_points[i].y, _water_height + 0.005)
	_pin_ends(start, end)


func _pin_ends(start: Vector3, end: Vector3) -> void:
	_points[0] = start
	_previous[0] = start
	if not _broken:
		_points[segments] = end
		_previous[segments] = end


func _process(_delta: float) -> void:
	if visible and _points.size() > 1:
		_draw_line()


func _draw_line() -> void:
	im.clear_surfaces()
	if _broken:
		_draw_strand(0, _break_joint)
		_draw_strand(_break_joint + 1, segments)
	else:
		_draw_strand(0, segments)


func _draw_strand(first: int, last: int) -> void:
	var camera := get_viewport().get_camera_3d()
	im.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	for i in range(first, last + 1):
		var point: Vector3 = _points[i]
		# Attach to the rendered rod pose as its animation moves between physics ticks.
		if i == 0:
			point = rod_tip.global_position
		elif i == segments and not _broken:
			point = _get_line_end()
		var before: Vector3 = _points[maxi(first, i - 1)]
		var after: Vector3 = _points[mini(last, i + 1)]
		var tangent := (after - before).normalized()
		var view_direction := Vector3.FORWARD
		var width: float = line_width
		if camera:
			view_direction = (camera.global_position - point).normalized()
			var viewport_height: float = maxf(get_viewport().get_visible_rect().size.y, 1.0)
			var pixel_size: float = 2.0 * camera.global_position.distance_to(point) * tan(deg_to_rad(camera.fov * 0.5)) / viewport_height
			width = maxf(width, pixel_size * 1.6)
		var side := tangent.cross(view_direction).normalized()
		if side.length_squared() < 0.1:
			side = Vector3.RIGHT
		im.surface_add_vertex(to_local(point - side * width * 0.5))
		im.surface_add_vertex(to_local(point + side * width * 0.5))
	im.surface_end()


func _hide_line() -> void:
	visible = false
	_broken = false
	_returning = false
	if is_instance_valid(hook):
		hook.visible = false
	im.clear_surfaces()
	_points.clear()
	_previous.clear()
	if _pending_segments > 0:
		set_fishing_line_segments(_pending_segments)
		_pending_segments = 0
