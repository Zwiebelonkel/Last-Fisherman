extends RefCounted
## Local presentation for one cast. The fishing controller owns the anchor and outcome.

const RodFlex := preload("res://scripts/RodFlex.gd")
const BITE_DURATION := 0.38
const ESCAPE_DURATION := 0.82
const HALF_TURN_DURATION := 0.20

var _water: MeshInstance3D
var _shaft: RodFlex
var _progress: Range
var _material: ShaderMaterial
var _side := Vector3.RIGHT
var _toward_rod := Vector3.BACK
var _last_progress := 0.0
var _turn := 0.0
var _target_turn := 0.0
var _bite_time := BITE_DURATION
var _fight_time := 0.0
var fighting := false
var escaping := false
var _size := 0.7
var _mouth := Vector3.ZERO
var _heading := Vector3.RIGHT
var _previous_bait := Vector3.ZERO
var _wake := Vector3.ZERO
var _wake_axis := Vector3.RIGHT
var _wake_alpha := 0.0
var _bend := Vector3.ZERO
var _release_bend := Vector3.ZERO
var _escape_axis := Vector3.ZERO
var _escape_time := 0.0


func setup(water: MeshInstance3D, shaft: RodFlex, progress: Range) -> void:
	_water = water
	_shaft = shaft
	_progress = progress


func bite(camera: Camera3D) -> void:
	_side = camera.global_basis.x.slide(Vector3.UP).normalized()
	_toward_rod = camera.global_basis.z.slide(Vector3.UP).normalized()
	# Alternate banks of the cast according to the water clock, without a gameplay RNG roll.
	if sin(_water.surface_time * 2.3) < 0.0:
		_side = -_side
	_bite_time = 0.0


func start(weight: float, bait: Vector3) -> void:
	fighting = true
	_fight_time = 0.0
	var cast_axis := (_shaft.global_position - bait).slide(Vector3.UP)
	if not cast_axis.is_zero_approx():
		_toward_rod = cast_axis.normalized()
	_last_progress = _progress.value
	_turn = 0.0
	_target_turn = 0.0
	_size = clampf(0.54 + 0.19 * log(1.0 + maxf(weight, 0.0)), 0.54, 1.35)
	_previous_bait = bait
	_wake_axis = _side
	_wake = bait
	_mouth = bait
	_heading = _toward_rod


func update(delta: float, anchor: Vector3) -> Vector3:
	if not fighting and _bite_time >= BITE_DURATION:
		return Vector3.ZERO
	_bite_time = minf(_bite_time + delta, BITE_DURATION)
	var bite_pull := smoothstep(0.0, 0.085, _bite_time) * (1.0 - smoothstep(0.11, BITE_DURATION, _bite_time))
	var offset := (_side * 0.36 + Vector3.DOWN * 0.09) * bite_pull
	if not fighting:
		return offset
	_fight_time += delta
	# Flat progress keeps the last direction. A reversal mid-turn retraces the same arc.
	if _progress.value > _last_progress:
		_target_turn = 0.0
	elif _progress.value < _last_progress:
		_target_turn = PI
	_last_progress = _progress.value
	_turn = move_toward(_turn, _target_turn, PI * delta / HALF_TURN_DURATION)
	_heading = _toward_rod.rotated(Vector3.UP, _turn)
	var angle := _fight_time * 1.85 + 0.30 * sin(_fight_time * 2.6)
	var tug_direction := (_heading + _side * 0.32 * cos(angle)).normalized()
	# A brief strike, a slower release, then slack before the next surge.
	var phase := fposmod(angle, PI)
	var pull := smoothstep(0.28, 0.64, phase) * (1.0 - smoothstep(0.70, 1.67, phase))
	offset += tug_direction * pull * (0.34 + _size * 0.19)
	var bait := anchor + offset
	_mouth = bait
	var motion := (bait - _previous_bait).slide(Vector3.UP)
	if motion.length_squared() > 0.000001 and pull > 0.08:
		_wake_axis = motion.normalized()
	_previous_bait = bait
	_wake = bait
	_wake_alpha = move_toward(_wake_alpha, pull, delta * 5.5)
	var rebound := 0.14 * sin(PI * smoothstep(1.37, 2.20, phase))
	_bend = (tug_direction + Vector3.DOWN * 0.50) * (0.23 * (pull - rebound))
	_shaft.set_pull(_bend)
	_publish(smoothstep(0.0, 0.25, _fight_time), 0.0)
	return offset


func escape() -> void:
	if not fighting:
		return
	fighting = false
	escaping = true
	_escape_time = 0.0
	var outward := -_toward_rod
	_escape_axis = _wake_axis if _wake_axis.dot(outward) > 0.35 else outward
	_release_bend = _bend if _bend.length() > 0.065 else (outward + Vector3.DOWN * 0.5) * 0.09
	_wake_alpha = maxf(_wake_alpha, 0.48)


func update_escape(delta: float) -> void:
	_escape_time += delta
	if _escape_time >= ESCAPE_DURATION:
		reset()
		return
	var t := _escape_time / ESCAPE_DURATION
	var fish_turn := _heading.signed_angle_to(_escape_axis, Vector3.UP)
	_heading = _heading.rotated(Vector3.UP, fish_turn * (1.0 - exp(-12.0 * delta)))
	_mouth += _heading * (2.4 + _size) * delta
	_wake += _wake_axis * (1.0 - t) * 1.35 * delta
	# Let the crest carry its old velocity into the turn the fish takes to dive.
	var turn := _wake_axis.signed_angle_to(_escape_axis, Vector3.UP)
	_wake_axis = _wake_axis.rotated(Vector3.UP, turn * (1.0 - exp(-6.0 * delta)))
	_wake_alpha = move_toward(_wake_alpha, 0.0, delta * 1.35)
	_shaft.set_pull(_release_bend * exp(-8.5 * _escape_time) * cos(23.0 * _escape_time))
	_publish(1.0 - smoothstep(0.05, 1.0, t), t * t * 0.85)


func _publish(opacity: float, depth: float) -> void:
	var active := _water.get_active_material(0) as ShaderMaterial
	if active != _material:
		_clear_material()
		_material = active
	if _material == null:
		return
	_material.set_shader_parameter("fight_shadow", Vector4(_mouth.x, _mouth.z, _size, opacity))
	_material.set_shader_parameter("fight_depth", depth)
	_material.set_shader_parameter("fight_wake", Vector4(_wake.x, _wake.z, 0.75 + _size * 0.28, _wake_alpha))
	_material.set_shader_parameter("fight_axes", Vector4(_heading.x, _heading.z, _wake_axis.x, _wake_axis.z))


func _clear_material() -> void:
	if _material:
		_material.set_shader_parameter("fight_shadow", Vector4.ZERO)
		_material.set_shader_parameter("fight_wake", Vector4.ZERO)
		_material = null


func reset() -> void:
	_bite_time = BITE_DURATION
	fighting = false
	escaping = false
	_wake_alpha = 0.0
	_bend = Vector3.ZERO
	if is_instance_valid(_shaft):
		_shaft.set_pull(Vector3.ZERO)
	_clear_material()
