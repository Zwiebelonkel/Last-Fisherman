extends Camera3D

@export var sway_amount: float = 0.02
@export var sway_speed: float = 1.5

var base_position: Vector3

func _ready() -> void:
	base_position = position

func _process(delta: float) -> void:
	var t := Time.get_ticks_msec() / 1000.0
	position.x = base_position.x + sin(t * sway_speed) * sway_amount
	position.y = base_position.y + cos(t * sway_speed * 0.8) * sway_amount
