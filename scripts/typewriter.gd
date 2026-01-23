extends RichTextLabel
class_name TypewriterRichText

signal typewriter_finished

@export var characters_per_second: float = 20.0
@export var start_delay: float = 0.3

var _full_text := ""
var _elapsed := 0.0
var _started := false

func start_typewriter(new_text: String) -> void:
	_full_text = new_text
	_started = false
	_elapsed = 0.0
	text = _full_text
	visible_characters = 0
	# sicherstellen, dass _process läuft
	set_process(true)

func _ready() -> void:
	set_process(false)

func _process(delta: float) -> void:
	if _full_text.is_empty():
		return
	
	_elapsed += delta
	
	if not _started:
		if _elapsed >= start_delay:
			_started = true
			_elapsed = 0.0
		return
	
	var cps: float = max(characters_per_second, 1.0)
	var target: int = int(_elapsed * cps)  # ✅ FIX: Expliziter Typ
	
	visible_characters = clamp(target, 0, _full_text.length())
	
	if visible_characters >= _full_text.length():
		set_process(false)
		emit_signal("typewriter_finished")  # ✅ FIX: Korrekter Signal-Name
