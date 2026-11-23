extends ColorRect
## A small status line whose color follows the full catch progress range.

const LOW_COLOR := Color(1.0, 0.15, 0.12)
const MID_COLOR := Color(1.0, 0.55, 0.08)
const HIGH_COLOR := Color(0.2, 0.9, 0.3)

@onready var _progress := get_parent() as ProgressBar
@onready var _percent: Label = $Percent
var _glow: Panel
var _glow_style: StyleBoxFlat
var _glow_tween: Tween


func _ready() -> void:
	# Keep the existing progress value/signals while presenting only the slim line.
	_progress.show_percentage = false
	_progress.add_theme_stylebox_override("background", StyleBoxEmpty.new())
	_progress.add_theme_stylebox_override("fill", StyleBoxEmpty.new())
	_progress.value_changed.connect(_update_color)
	_progress.changed.connect(_update_color.bind(0.0))
	_update_color(_progress.value)
	_glow = Panel.new()
	_glow.name = "WiggleGlow"
	_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_glow_style = StyleBoxFlat.new()
	_glow_style.bg_color = Color(1.0, 1.0, 1.0, 0.55)
	_glow_style.set_corner_radius_all(1)
	_glow_style.shadow_size = 4
	_glow.add_theme_stylebox_override("panel", _glow_style)
	add_child(_glow)
	_glow.hide()
	_progress.resized.connect(_update_color.bind(0.0))
	visibility_changed.connect(_reset_glow_if_hidden)
	_sync_glow_bounds()


func _update_color(_value: float) -> void:
	var progress: float = clampf(_progress.ratio, 0.0, 1.0)
	_percent.text = "%d%%" % roundi(progress * 100.0)
	color = LOW_COLOR.lerp(MID_COLOR, progress * 2.0) if progress <= 0.5 else MID_COLOR.lerp(HIGH_COLOR, (progress - 0.5) * 2.0)
	size = Vector2(_progress.size.x * progress, 3.0)
	position = Vector2((_progress.size.x - size.x) * 0.5, _progress.size.y + 5.0)
	if is_instance_valid(_glow):
		_sync_glow_bounds()


func flash_progress() -> void:
	if not is_visible_in_tree():
		return
	if _glow_tween and _glow_tween.is_valid():
		_glow_tween.kill()
	_sync_glow_bounds()
	_glow.modulate.a = 1.0
	_glow.show()
	_glow_tween = create_tween()
	_glow_tween.tween_property(_glow, "modulate:a", 0.0, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_glow_tween.tween_callback(_glow.hide)


func _sync_glow_bounds() -> void:
	_glow.position = Vector2.ZERO
	_glow.size = size
	_glow_style.shadow_color = Color(color.r, color.g, color.b, 0.7)


func _reset_glow_if_hidden() -> void:
	if not is_visible_in_tree() and is_instance_valid(_glow):
		if _glow_tween and _glow_tween.is_valid():
			_glow_tween.kill()
		_glow.hide()
