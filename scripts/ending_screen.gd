extends Control

@onready var background: ColorRect = $Background
@onready var ending_image: TextureRect = $EndingImage
@onready var scroll_container: ScrollContainer = $CanvasLayer/ScrollContainer
@onready var ending_text: RichTextLabel = $CanvasLayer/ScrollContainer/EndingText
@onready var ending_music: AudioStreamPlayer = $EndingMusic
@onready var bye: AudioStreamPlayer = $bye


@export var ending_texture: Texture2D
@export var ending_music_stream: AudioStream

# 🔧 Bildsteuerung
@export var image_scale := 0.5
@export var image_top_margin := 65.0

# Story & Credits (❗ KEIN [center] MEHR!)
@export_multiline var ending_story := """
The water reflects not the sky,
but your own fading existence.

There is no shore.
There never was.

Only you, the rod,
and the infinite deep.

This is how it ends.
This is how it always ended.
"""

@export_multiline var credits_text := """

CREDITS

A game about solitude and the sea

CREATED BY
Luca Müller

ART & DESIGN
Luca Müller, Julia <3, Daniel, Phillip

MUSIC & SOUND
Luca Müller

Thank you for playing.

Press ESC to return to menu

LAST FISHERMAN
"""

# Wackel-Effekt
@export var shake_intensity := 3.0
@export var shake_speed := 1.5
@export var scroll_speed := 25.0

var _base_image_pos := Vector2.ZERO
var _shake_time := 0.0
var _scroll := 0.0
var _scrolling := false
var _wait_for_input := false

func _ready() -> void:
	bye.play()
	background.color = Color.BLACK

	# 🔥 KRITISCH: Anchors zurücksetzen
	ending_image.anchor_left = 0.0
	ending_image.anchor_top = 0.0
	ending_image.anchor_right = 0.0
	ending_image.anchor_bottom = 0.0
	ending_image.grow_horizontal = Control.GROW_DIRECTION_END
	ending_image.grow_vertical = Control.GROW_DIRECTION_END

	if ending_texture:
		ending_image.texture = ending_texture

	# 📐 Bildgröße
	var tex_size := ending_image.texture.get_size()
	var scaled := tex_size * image_scale
	ending_image.size = scaled
	ending_image.custom_minimum_size = scaled

	var vp := get_viewport().get_visible_rect().size
	_base_image_pos = Vector2(
		(vp.x - scaled.x) * 0.5,
		image_top_margin
	)
	ending_image.position = _base_image_pos

	# 📝 Text links
	ending_text.bbcode_enabled = true
	ending_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	ending_text.text = ""

	await get_tree().process_frame
	_start_sequence()

func _start_sequence() -> void:
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 2.0)

	if ending_music_stream:
		ending_music.stream = ending_music_stream
		ending_music.play()

	await get_tree().create_timer(1.5).timeout
	await _typewriter(ending_story, 0.035)

	await get_tree().create_timer(2.0).timeout
	ending_text.text += credits_text

	_scrolling = true
	set_process(true)
	_wait_for_input = true

func _typewriter(text: String, delay: float) -> void:
	ending_text.text = text
	ending_text.visible_characters = 0

	for i in text.length():
		ending_text.visible_characters = i + 1
		await get_tree().create_timer(delay).timeout

	ending_text.visible_characters = -1

func _process(delta: float) -> void:
	_shake_time += delta * shake_speed
	var offset := Vector2(
		sin(_shake_time) * shake_intensity,
		cos(_shake_time * 0.8) * shake_intensity * 0.5
	)
	ending_image.position = _base_image_pos + offset

	if _scrolling:
		var max_scroll := scroll_container.get_v_scroll_bar().max_value
		_scroll = min(_scroll + scroll_speed * delta, max_scroll)
		scroll_container.scroll_vertical = int(_scroll)

func _input(event: InputEvent) -> void:
	if not _wait_for_input:
		return

	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause"):
		_exit()

func _exit() -> void:
	_wait_for_input = false
	var t := create_tween()
	t.tween_property(self, "modulate:a", 0.0, 1.5)
	await t.finished
	get_tree().change_scene_to_file("res://scenes/mainMenu.tscn")
