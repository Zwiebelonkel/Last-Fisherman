extends RichTextLabel

@export var shake_strength: float = 2.0
@export var shake_speed: float = 8.0
@export var noise_amount: float = 0.5

var _time := 0.0
var _base_position := Vector2.ZERO

func _ready():
	_base_position = position

func _process(delta):
	_time += delta * shake_speed

	var offset_x = sin(_time * 1.3) * shake_strength
	var offset_y = cos(_time * 1.7) * shake_strength

	# kleines random jitter für "Unruhe"
	offset_x += randf_range(-noise_amount, noise_amount)
	offset_y += randf_range(-noise_amount, noise_amount)

	position = _base_position + Vector2(offset_x, offset_y)
