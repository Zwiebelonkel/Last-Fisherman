extends Control
# ========================================
# STORY DIALOG SCENE
# Verwendet von: StoryDialog.tscn
# FlowManager befüllt die Szene mit Daten
# ========================================

@onready var speaker_label: Label = $Panel/MarginContainer/VBoxContainer/Label
@onready var text_label: RichTextLabel = $Panel/MarginContainer/VBoxContainer/RichTextLabel
@onready var character_sprite: TextureRect = $CharacterSprite
@onready var panel: Panel = $Panel

# Typewriter
var _full_text: String = ""
var _char_index: int = 0
var _typing_timer: Timer
var _is_typing: bool = false
const TYPING_SPEED: float = 0.03

# Dialog lines
var _lines: Array = []
var _current_line: int = 0

# Bob Animation
var _bob_tween: Tween
const BOB_AMOUNT: float = 8.0
const BOB_SPEED: float  = 1.2

# -------------------------
# Fallback Data
# -------------------------
const FALLBACK_DATA = {
	"speaker": {
		"de": "Fremder",
		"en": "Stranger"
	},
	"sprite": "",
	"lines": {
		"de": ["Ein Fremder beobachtet dich aus der Ferne..."],
		"en": ["A stranger watches you from afar..."]
	}
}

# -------------------------
# Localization
# -------------------------
func _get_lang() -> String:
	if Player:
		return Player.current_language
	return "de"

# -------------------------
# Ready
# -------------------------
func _ready() -> void:
	_typing_timer = Timer.new()
	_typing_timer.wait_time = TYPING_SPEED
	_typing_timer.timeout.connect(_on_typing_tick)
	add_child(_typing_timer)

	_start_bob()
	_load_dialog_data()

# -------------------------
# Bob Animation
# -------------------------
func _start_bob() -> void:
	var base_y = character_sprite.position.y

	_bob_tween = create_tween()
	_bob_tween.set_loops()
	_bob_tween.set_ease(Tween.EASE_IN_OUT)
	_bob_tween.set_trans(Tween.TRANS_SINE)
	_bob_tween.tween_property(character_sprite, "position:y", base_y - BOB_AMOUNT, BOB_SPEED / 2.0)
	_bob_tween.tween_property(character_sprite, "position:y", base_y + BOB_AMOUNT, BOB_SPEED / 2.0)

# -------------------------
# Load Data from FlowManager (with Fallback)
# -------------------------
func _load_dialog_data() -> void:
	var data: Dictionary = FlowManager.pending_dialog
	var lang = _get_lang()

	# 🔧 Fallback wenn keine Daten vorhanden
	if data.is_empty():
		push_warning("⚠️ StoryDialog: Keine Dialog-Daten – verwende Fallback")
		data = FALLBACK_DATA

	# Charakter-Sprite
	if data.has("sprite") and data["sprite"] != "":
		var tex = load(data["sprite"])
		if tex:
			character_sprite.texture = tex

	# Sprecher-Name (lokalisiert)
	if data.has("speaker"):
		var speaker = data["speaker"]
		if speaker is Dictionary:
			speaker_label.text = speaker.get(lang, speaker.get("en", "???")) + ":"
		else:
			speaker_label.text = str(speaker) + ":"

	# Zeilen (lokalisiert)
	if data.has("lines"):
		var lines = data["lines"]
		if lines is Dictionary:
			_lines = lines.get(lang, lines.get("en", []))
		elif lines is Array:
			_lines = lines

	# 🔧 Fallback falls lines immer noch leer
	if _lines.is_empty():
		var fallback_lines = FALLBACK_DATA["lines"]
		_lines = fallback_lines.get(lang, fallback_lines.get("en", ["..."]))

	_show_line(0)

# -------------------------
# Typewriter
# -------------------------
func _show_line(index: int) -> void:
	_current_line = index
	_full_text = _lines[index]
	_char_index = 0
	text_label.text = ""
	_is_typing = true
	_typing_timer.start()

func _on_typing_tick() -> void:
	if _char_index < _full_text.length():
		text_label.text += _full_text[_char_index]
		_char_index += 1
	else:
		_typing_timer.stop()
		_is_typing = false

# -------------------------
# Input
# -------------------------
func _on_Panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if _is_typing:
			# Sofort ganzen Text zeigen
			_typing_timer.stop()
			text_label.text = _full_text
			_is_typing = false
		else:
			# Nächste Zeile oder beenden
			if _current_line + 1 < _lines.size():
				_show_line(_current_line + 1)
			else:
				_finish_dialog()

# -------------------------
# Finish
# -------------------------
func _finish_dialog() -> void:
	if _bob_tween:
		_bob_tween.kill()
	FlowManager.pending_dialog = {}
	FlowManager.dialog_closed()
