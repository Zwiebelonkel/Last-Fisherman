extends Control
class_name SushiMinigame

signal minigame_finished(time_bonus: float)
signal minigame_cancelled()

const MAX_BONUS: float = 4.0
const CLICKS_FOR_MAX: int = 20
const CLICK_WINDOW: float = 3.0
const FISH_PIECES_MAX: int = 8

var click_count: int = 0
var elapsed: float = 0.0
var active: bool = false
var current_fish_texture: Texture2D = null

@onready var progress_bar: ProgressBar = $Panel/VBox/ProgressBar
@onready var click_button: Button = $Panel/VBox/ClickButton
@onready var timer_label: Label = $Panel/VBox/TimerLabel
@onready var hint_label: Label = $Panel/VBox/HintLabel
@onready var fish_display: HBoxContainer = $Panel/VBox/FishDisplay
@onready var knife_label: Label = $Panel/VBox/KnifeRow/KnifeLabel

func _ready() -> void:
	visible = false
	if click_button:
		click_button.pressed.connect(_on_click)

func set_fish(fish_id: String) -> void:
	var fish_dict = FishDB.get_fish_by_id(fish_id)
	print("set_fish called: ", fish_id)
	print("fish_dict: ", fish_dict)
	var icon_path = fish_dict.get("icon", "")
	print("icon_path: ", icon_path)
	if icon_path != "":
		current_fish_texture = load(icon_path)
		print("texture loaded: ", current_fish_texture)
	else:
		current_fish_texture = null

func start() -> void:
	click_count = 0
	elapsed = 0.0
	active = true
	visible = true
	progress_bar.value = 0
	hint_label.text = tr("SUSHI_MINI_HINT")
	click_button.text = tr("SUSHI_MINI_BUTTON")
	_update_fish_display()

func _process(delta: float) -> void:
	if not active:
		return

	elapsed += delta
	timer_label.text = "%.1f" % max(0.0, CLICK_WINDOW - elapsed)

	if click_count > 0:
		progress_bar.value = max(0.0, progress_bar.value - delta * 8.0)

	if elapsed >= CLICK_WINDOW:
		_finish()

func _on_click() -> void:
	if not active:
		return

	click_count += 1
	progress_bar.value = min(100.0, progress_bar.value + (100.0 / CLICKS_FOR_MAX) * 1.5)

	_update_fish_display()
	_animate_knife()

	click_button.scale = Vector2(0.92, 0.92)
	await get_tree().create_timer(0.07).timeout
	if is_instance_valid(click_button):
		click_button.scale = Vector2(1.0, 1.0)

	if click_count >= CLICKS_FOR_MAX:
		_finish()

func _update_fish_display() -> void:
	if not fish_display:
		return

	for child in fish_display.get_children():
		child.queue_free()

	if not current_fish_texture:
		# Fallback: einfaches Label
		var lbl = Label.new()
		lbl.text = "🐟"
		lbl.add_theme_font_size_override("font_size", 48)
		fish_display.add_child(lbl)
		return

	var ratio = clamp(float(click_count) / CLICKS_FOR_MAX, 0.0, 1.0)
	var pieces = max(1, int(lerp(1.0, float(FISH_PIECES_MAX), ratio)))
	var gap_size = int(ratio * 10)

	var img_w = current_fish_texture.get_width()
	var img_h = current_fish_texture.get_height()
	var slice_w = img_w / pieces
	var display_h = 64
	var piece_w = max(8, int(64.0 / pieces))

	for i in range(pieces):
		var atlas = AtlasTexture.new()
		atlas.atlas = current_fish_texture
		atlas.region = Rect2(i * slice_w, 0, slice_w, img_h)

		var tex = TextureRect.new()
		tex.texture = atlas
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex.custom_minimum_size = Vector2(piece_w, display_h)
		tex.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		fish_display.add_child(tex)

		# Lücke zwischen Stücken (wächst mit mehr Klicks)
		if i < pieces - 1 and gap_size > 0:
			var gap = ColorRect.new()
			gap.custom_minimum_size = Vector2(gap_size, display_h)
			gap.color = Color(0.05, 0.05, 0.05, 1.0)
			fish_display.add_child(gap)

func _animate_knife() -> void:
	if not knife_label:
		return
	knife_label.position.y = 10.0
	await get_tree().create_timer(0.06).timeout
	if is_instance_valid(knife_label):
		knife_label.position.y = 0.0

func _finish() -> void:
	active = false
	visible = false
	var ratio = clamp(float(click_count) / CLICKS_FOR_MAX, 0.0, 1.0)
	minigame_finished.emit(ratio * MAX_BONUS)

func is_active() -> bool:
	return active

func external_click() -> void:
	if active:
		_on_click()

func cancel() -> void:
	if active:
		active = false
		visible = false
		minigame_cancelled.emit()
