extends CanvasLayer
signal finished

@export var duration := 0.35
@export var shake_strength := 18.0
@export var shake_speed := 90.0
@export var zoom_scale := 1.2

@onready var image: TextureRect = $ScareImage
@onready var sound: AudioStreamPlayer = $ScareImage/Screech

var _time := 0.0
var _active := false

func _ready() -> void:
	call_deferred("play")
	layer = 127       # immer ganz vorne
	visible = false
	image.position = Vector2.ZERO
	image.scale = Vector2.ONE
	image.modulate.a = 1.0   # immer sichtbar
	set_process(false)

func play() -> void:
	print("👻 JUMPSCARE PLAY")

	visible = true
	_active = true
	_time = 0.0

	image.scale = Vector2(zoom_scale, zoom_scale)
	image.position = Vector2.ZERO

	if sound:
		sound.play()

	set_process(true)

	await get_tree().create_timer(duration).timeout

	_stop()

func _stop() -> void:
	_active = false
	set_process(false)

	image.position = Vector2.ZERO
	image.scale = Vector2.ONE
	visible = false

	emit_signal("finished")

func _process(delta: float) -> void:
	if not _active:
		return

	_time += delta * shake_speed

	image.position = Vector2(
		randf_range(-1, 1),
		randf_range(-1, 1)
	) * shake_strength
