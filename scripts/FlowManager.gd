extends Node
# ========================================
# FLOWMANAGER - EVENT → NOTE → MAP
# ========================================
# -------------------------
# State
# -------------------------
var pending_note: Dictionary = {}

# -------------------------
# Localization Helper
# -------------------------
func _get_lang() -> String:
	"""Get current language from GameManager"""
	if Player:
		return Player.current_language
	return "de"

func _t(key: String) -> String:
	"""Returns localized string based on current language"""
	const TRANSLATIONS = {
		"note_registered": {
			"de": "📝 FlowManager: Note registriert - %s (Ziffer: %d)",
			"en": "📝 FlowManager: Note registered - %s (Digit: %d)"
		},
		"event_ended": {
			"de": "🎬 FlowManager: Event beendet",
			"en": "🎬 FlowManager: Event ended"
		},
		"show_note_view": {
			"de": "📄 FlowManager: → NoteView",
			"en": "📄 FlowManager: → NoteView"
		},
		"note_view_closed": {
			"de": "📄 FlowManager: NoteView geschlossen",
			"en": "📄 FlowManager: NoteView closed"
		},
		"go_to_map": {
			"de": "🗺️ FlowManager: → Map",
			"en": "🗺️ FlowManager: → Map"
		}
	}
	
	var lang = _get_lang()
	if TRANSLATIONS.has(key) and TRANSLATIONS[key].has(lang):
		return TRANSLATIONS[key][lang]
	elif TRANSLATIONS.has(key) and TRANSLATIONS[key].has("en"):
		return TRANSLATIONS[key]["en"]
	else:
		return key

# -------------------------
# Note Registration
# -------------------------
func register_note(id: String, digit: int, text: String) -> void:
	pending_note = {
		"id": id,
		"digit": digit,
		"text": text
	}
	print(_t("note_registered") % [id, digit])

# -------------------------
# Event Flow
# -------------------------
func end_event() -> void:
	print(_t("event_ended"))
	
	await get_tree().create_timer(0.5).timeout
	
	if not pending_note.is_empty():
		show_note_view()
	else:
		go_to_map()

# -------------------------
# Note View
# -------------------------
func show_note_view() -> void:
	print(_t("show_note_view"))
	Transition.change_scene("res://scenes/NoteView.tscn", 0.5)

func note_view_closed() -> void:
	print(_t("note_view_closed"))
	pending_note = {}
	
	await get_tree().create_timer(0.3).timeout
	go_to_map()

# -------------------------
# Map
# -------------------------
func go_to_map() -> void:
	print(_t("go_to_map"))
	Transition.change_scene("res://scenes/MapScene.tscn", 0.5)
