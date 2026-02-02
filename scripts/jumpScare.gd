extends Control
signal finished

@export var duration := 0.4

# 🔥 Shake Settings
@export var shake_intensity := 25.0
@export var shake_speed := 80.0
@export var zoom_scale := 1.25

@onready var image: TextureRect = $ScareImage
@onready var sound: AudioStreamPlayer = $Screech

var _base_pos := Vector2.ZERO
var _time := 0.0
var _shaking := false

func _ready() -> void:
	visible = false
	modulate.a = 0.0
	
	# 🔒 Anchors fixieren (wichtig!)
	image.anchor_left = 0.5
	image.anchor_top = 0.5
	image.anchor_right = 0.5
	image.anchor_bottom = 0.5
	
	image.pivot_offset = image.size * 0.5
	_base_pos = image.position
	
	set_process(false)

func play() -> void:
	print("🎬 Jumpscare.play() gestartet")
	visible = true
	modulate.a = 0.0
	
	image.scale = Vector2.ONE
	image.position = _base_pos
	
	if sound:
		sound.play()
		print("🔊 Jumpscare Sound spielt")
	
	_shaking = true
	_time = 0.0
	set_process(true)

	var tween := create_tween()
	tween.set_parallel(true)

	# 🔥 HARD FADE IN
	tween.tween_property(self, "modulate:a", 1.0, 0.05)

	# 🔥 SNAP ZOOM
	tween.tween_property(image, "scale", Vector2(zoom_scale, zoom_scale), 0.08)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)

	# ⏱️ HALTEN
	tween.tween_interval(duration)

	# FADE OUT
	tween.tween_property(self, "modulate:a", 0.0, 0.15)

	await tween.finished
	
	_shaking = false
	set_process(false)
	
	image.position = _base_pos
	image.scale = Vector2.ONE
	
	visible = false
	emit_signal("finished")
	print("🎬 Jumpscare finished Signal emitted")

func _process(delta: float) -> void:
	if not _shaking:
		return
	
	_time += delta * shake_speed
	
	var offset := Vector2(
		randf_range(-1.0, 1.0),
		randf_range(-1.0, 1.0)
	) * shake_intensity
	
	image.position = _base_pos + offset
