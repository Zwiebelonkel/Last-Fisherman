extends RefCounted

const NumberFormat = preload("res://scripts/NumberFormat.gd")

const WIGGLE_PROGRESS: float = 1.0
const WIGGLE_COOLDOWN: float = 0.16
const POPUP_POSITION := Vector2(0.0, -30.0)

var _previous_mouse: Vector2 = Vector2.ZERO
var _stroke_direction: Vector2 = Vector2.ZERO
var _stroke_distance: Vector2 = Vector2.ZERO
var _reversed_stroke: Array[bool] = [false, false]
var _was_in_spot: bool = false
var _wiggle_cooldown: float = 0.0
var _wiggle_total: int = 0
var _wiggle_popup: Label
var _popup_tween: Tween


func reset(bar: Control) -> void:
	_wiggle_cooldown = 0.0
	_wiggle_total = 0
	clear_motion(bar.get_local_mouse_position())
	if _popup_tween != null and _popup_tween.is_valid():
		_popup_tween.kill()
	if not is_instance_valid(_wiggle_popup):
		_wiggle_popup = Label.new()
		_wiggle_popup.name = "WigglePopup"
		_wiggle_popup.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_wiggle_popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_wiggle_popup.add_theme_font_size_override("font_size", 20)
		_wiggle_popup.add_theme_color_override("font_shadow_color", Color.BLACK)
		_wiggle_popup.add_theme_constant_override("shadow_offset_x", 1)
		_wiggle_popup.add_theme_constant_override("shadow_offset_y", 1)
		bar.add_child(_wiggle_popup)
	_wiggle_popup.position = POPUP_POSITION
	_wiggle_popup.size = Vector2(bar.size.x, 26.0)
	_wiggle_popup.text = ""
	_wiggle_popup.hide()


func clear_motion(mouse_position: Vector2) -> void:
	_previous_mouse = mouse_position
	_stroke_direction = Vector2.ZERO
	_stroke_distance = Vector2.ZERO
	_reversed_stroke = [false, false]
	_was_in_spot = false


func get_wiggle_progress(mouse_position: Vector2, bar_width: float,
		in_spot: bool, delta: float) -> float:
	_wiggle_cooldown = maxf(_wiggle_cooldown - delta, 0.0)
	if not in_spot or not _was_in_spot or delta <= 0.0:
		clear_motion(mouse_position)
		_was_in_spot = in_spot
		return 0.0

	var motion: Vector2 = mouse_position - _previous_mouse
	_previous_mouse = mouse_position
	var minimum_stroke: float = maxf(bar_width * 0.015, 6.0)
	var boost: float = 0.0
	for axis in range(2):
		var direction: float = signf(motion[axis])
		if direction == 0.0:
			continue
		if direction != _stroke_direction[axis]:
			_reversed_stroke[axis] = _stroke_distance[axis] >= minimum_stroke
			_stroke_distance[axis] = 0.0
			_stroke_direction[axis] = direction
		_stroke_distance[axis] += absf(motion[axis])
		if _reversed_stroke[axis] and _stroke_distance[axis] >= minimum_stroke:
			_reversed_stroke[axis] = false
			if _wiggle_cooldown <= 0.0:
				boost = WIGGLE_PROGRESS
				_wiggle_cooldown = WIGGLE_COOLDOWN
	if boost > 0.0:
		_wiggle_total += roundi(boost)
		_show_wiggle_popup()
	return boost


func _show_wiggle_popup() -> void:
	if not is_instance_valid(_wiggle_popup):
		return
	if _popup_tween != null and _popup_tween.is_valid():
		_popup_tween.kill()
	_wiggle_popup.text = "+%s" % NumberFormat.compact(_wiggle_total)
	_wiggle_popup.position = POPUP_POSITION
	_wiggle_popup.modulate = Color(1.0, 0.9, 0.4)
	_wiggle_popup.show()
	_popup_tween = _wiggle_popup.create_tween()
	_popup_tween.tween_property(_wiggle_popup, "position", POPUP_POSITION + Vector2(-4.0, -1.0), 0.025)
	_popup_tween.tween_property(_wiggle_popup, "position", POPUP_POSITION + Vector2(4.0, 1.0), 0.03)
	_popup_tween.tween_property(_wiggle_popup, "position", POPUP_POSITION + Vector2(-2.0, 0.0), 0.025)
	_popup_tween.tween_property(_wiggle_popup, "position", POPUP_POSITION, 0.035)
	_popup_tween.tween_interval(0.6)
	_popup_tween.tween_property(_wiggle_popup, "modulate:a", 0.0, 0.2)
	_popup_tween.tween_callback(_wiggle_popup.hide)
