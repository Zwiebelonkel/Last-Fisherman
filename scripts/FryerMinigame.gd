extends Control
class_name FryerMinigame

signal minigame_finished(quality: String)  # "perfect", "good", "burned"
signal minigame_cancelled()

# Marker bewegt sich hin und her
const MARKER_SPEED: float = 1.8  # Geschwindigkeit (Zyklen/s)

var marker_pos: float = 0.0  # 0.0 - 1.0
var marker_dir: float = 1.0
var active: bool = false

var current_fish_texture: Texture2D = null

# Zonen (in 0-1 Raum)
const PERFECT_MIN: float = 0.42
const PERFECT_MAX: float = 0.58
const GOOD_MIN: float = 0.25
const GOOD_MAX: float = 0.75

@onready var slider_bar: Control = $Panel/VBox/SliderBar
@onready var marker: Control = $Panel/VBox/SliderBar/Marker
@onready var confirm_button: Button = $Panel/VBox/ConfirmButton
@onready var hint_label: Label = $Panel/VBox/HintLabel
@onready var result_label: Label = $Panel/VBox/ResultLabel
@onready var fish_display: TextureRect = $Panel/VBox/FishDisplay

func _ready() -> void:
	visible = false
	confirm_button.pressed.connect(_on_confirm)


func start() -> void:
	marker_pos = 0.0
	marker_dir = 1.0
	active = true
	visible = true
	result_label.text = ""
	hint_label.text = tr("FRYER_MINI_HINT")
	confirm_button.text = tr("FRYER_MINI_BUTTON")
	_update_fish_display()
	
func set_fish(fish_id: String) -> void:
	var fish_dict = FishDB.get_fish_by_id(fish_id)
	current_fish_texture = FishDB.get_fish_icon(fish_dict)
	
func _update_fish_display() -> void:
	if not fish_display:
		return
	if current_fish_texture:
		fish_display.texture = current_fish_texture
		fish_display.visible = true
		# Normales Aussehen zu Beginn
		fish_display.modulate = Color(1, 1, 1, 1)
	else:
		fish_display.visible = false

func _process(delta: float) -> void:
	if not active:
		return

	marker_pos += marker_dir * MARKER_SPEED * delta
	if marker_pos >= 1.0:
		marker_pos = 1.0
		marker_dir = -1.0
	elif marker_pos <= 0.0:
		marker_pos = 0.0
		marker_dir = 1.0

	if slider_bar and marker:
		var bar_width = slider_bar.size.x - marker.size.x
		marker.position.x = marker_pos * bar_width

	# Fisch-Farbe je nach Marker-Zone
	if fish_display and fish_display.visible:
		if marker_pos >= PERFECT_MIN and marker_pos <= PERFECT_MAX:
			fish_display.modulate = Color(0.6, 1.0, 0.3, 1)   # grünlich = perfekt
		elif marker_pos >= GOOD_MIN and marker_pos <= GOOD_MAX:
			fish_display.modulate = Color(1.0, 0.85, 0.2, 1)  # goldgelb = gut
		else:
			fish_display.modulate = Color(1.0, 0.3, 0.1, 1)   # rot = verbrannt
func _on_confirm() -> void:
	if not active:
		return
	active = false
	
	var quality: String
	if marker_pos >= PERFECT_MIN and marker_pos <= PERFECT_MAX:
		quality = "perfect"
		result_label.text = tr("FRYER_MINI_PERFECT")
		result_label.add_theme_color_override("font_color", Color.GREEN)
	elif marker_pos >= GOOD_MIN and marker_pos <= GOOD_MAX:
		quality = "good"
		result_label.text = tr("FRYER_MINI_GOOD")
		result_label.add_theme_color_override("font_color", Color.YELLOW)
	else:
		quality = "burned"
		result_label.text = tr("FRYER_MINI_BURNED")
		result_label.add_theme_color_override("font_color", Color.RED)
	
	await get_tree().create_timer(0.8).timeout
	if is_instance_valid(self):
		visible = false
		minigame_finished.emit(quality)
		
func is_active() -> bool:
	return active

func external_confirm() -> void:
	if active:
		_on_confirm()

func cancel() -> void:
	if active:
		active = false
		visible = false
		minigame_cancelled.emit()
