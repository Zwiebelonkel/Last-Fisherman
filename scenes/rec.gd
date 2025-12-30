extends Label
class_name RECLabel

@export var blink_interval := 0.5
@export var start_visible := true

var _timer := 0.0

func _ready() -> void:
	visible = start_visible

func _process(delta: float) -> void:
	_timer += delta

	if _timer >= blink_interval:
		_timer = 0.0
		visible = not visible
