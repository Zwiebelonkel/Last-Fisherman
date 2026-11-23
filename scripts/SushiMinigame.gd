extends Control
class_name SushiMinigame

signal minigame_finished(time_bonus: float)
signal minigame_cancelled()

const MAX_BONUS: float = 4.0
const CLICKS_FOR_MAX: int = 20
const CLICK_WINDOW: float = 3.0
const FISH_PIECES_MAX: int = 8
const FishDisplay := preload("res://scripts/SushiFishDisplay.gd")

var click_count: int = 0
var elapsed: float = 0.0
var active: bool = false
var current_fish_texture: Texture2D
var _round_id: int = 0
var _finishing: bool = false
var _button_tween: Tween
var _knife_tween: Tween

@onready var progress_bar: ProgressBar = $Panel/VBox/ProgressBar
@onready var click_button: Button = $Panel/VBox/ClickButton
@onready var timer_label: Label = $Panel/VBox/TimerLabel
@onready var hint_label: Label = $Panel/VBox/HintLabel
@onready var fish_display: FishDisplay = $Panel/VBox/FishDisplay
@onready var knife_visual: Control = $Panel/VBox/KnifeRow/Knife


func _ready() -> void:
	visible = false
	click_button.pressed.connect(_on_click)


func set_fish(fish_id: String) -> void:
	current_fish_texture = FishDB.get_fish_icon(FishDB.get_fish_by_id(fish_id))


func start() -> void:
	_round_id += 1
	_stop_tweens()
	click_count = 0
	elapsed = 0.0
	active = true
	_finishing = false
	visible = true
	click_button.disabled = false
	click_button.scale = Vector2.ONE
	progress_bar.value = 0
	timer_label.text = "%.1f" % CLICK_WINDOW
	hint_label.text = tr("SUSHI_MINI_HINT")
	click_button.text = tr("SUSHI_MINI_BUTTON")
	fish_display.set_fish(current_fish_texture)


func _process(delta: float) -> void:
	if not active:
		return
	elapsed += delta
	timer_label.text = "%.1f" % maxf(0.0, CLICK_WINDOW - elapsed)
	if click_count > 0:
		progress_bar.value = maxf(0.0, progress_bar.value - delta * 8.0)
	if elapsed >= CLICK_WINDOW:
		_finish()


func _on_click() -> void:
	if not active:
		return
	click_count += 1
	progress_bar.value = minf(100.0, progress_bar.value + (100.0 / CLICKS_FOR_MAX) * 1.5)
	_update_fish_display()
	_animate_knife()
	if _button_tween and _button_tween.is_valid():
		_button_tween.kill()
	click_button.pivot_offset = click_button.size * 0.5
	click_button.scale = Vector2(0.96, 0.96)
	_button_tween = create_tween()
	_button_tween.tween_property(click_button, "scale", Vector2.ONE, 0.09)
	if click_count >= CLICKS_FOR_MAX:
		_finish()


func _update_fish_display() -> void:
	var ratio := clampf(float(click_count) / CLICKS_FOR_MAX, 0.0, 1.0)
	fish_display.set_cut_count(floori(ratio * (FISH_PIECES_MAX - 1)))


func _animate_knife() -> void:
	if _knife_tween and _knife_tween.is_valid():
		_knife_tween.kill()
	knife_visual.position.y = -3.0
	_knife_tween = create_tween()
	_knife_tween.tween_property(knife_visual, "position:y", 10.0, 0.035)
	_knife_tween.tween_property(knife_visual, "position:y", 0.0, 0.065)


func _finish() -> void:
	if not active:
		return
	active = false
	_finishing = true
	click_button.disabled = true
	var round_id := _round_id
	var ratio := clampf(float(click_count) / CLICKS_FOR_MAX, 0.0, 1.0)
	# Keep the finished slices visible briefly so the last cut can settle.
	await get_tree().create_timer(0.35, false).timeout
	if round_id != _round_id:
		return
	_finishing = false
	visible = false
	minigame_finished.emit(ratio * MAX_BONUS)


func is_active() -> bool:
	# Keep station interactions locked during the short final presentation.
	return active or _finishing


func external_click() -> void:
	_on_click()


func cancel() -> void:
	if not active and not _finishing:
		return
	_round_id += 1
	active = false
	_finishing = false
	visible = false
	_stop_tweens()
	minigame_cancelled.emit()


func _stop_tweens() -> void:
	for tween in [_button_tween, _knife_tween]:
		if tween and tween.is_valid():
			tween.kill()
