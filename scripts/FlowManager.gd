extends Node
# ========================================
# FLOWMANAGER - EVENT → NOTE → DIALOG → MAP
# ========================================

const DIALOG_SCENE   = "res://scenes/dialog1.tscn"

# -------------------------
# State
# -------------------------
var pending_note: Dictionary = {}
var pending_dialog: Dictionary = {}

# -------------------------
# Dialog Data
# -------------------------
const DIALOG_DATA = {
	"mid": {
		"speaker": {
			"de": "Fremder",
			"en": "Stranger"
		},
		"sprite": "res://assets/characters/stranger.png",  # 🔧 Pfad anpassen
		"lines": {
			"de": [
				"Es gefällt mir nicht, dass du so tust als wäre nichts gewesen...",
				"Es ist noch nicht zuende.",
				"Ich beobachte dich."
			],
			"en": [
				"Two pieces... you're getting closer.",
				"But the journey isn't over yet."
			]
		}
	},
	"final": {
		"speaker": {
			"de": "Fremder",
			"en": "Stranger"
		},
		"sprite": "res://assets/characters/stranger.png",  # 🔧 Pfad anpassen
		"lines": {
			"de": [
				"Du hast es vollbracht.",
				"Ignoranter Narr. Was ist aus der Menschheit geworden?!"
			],
			"en": [
				"All pieces... unbelievable.",
				"You did it. The food truck can now open!"
			]
		}
	}
}

# -------------------------
# Localization Helper
# -------------------------
func _get_lang() -> String:
	if Player:
		return Player.current_language
	return "de"

func _t(key: String) -> String:
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
		"go_to_dialog_mid": {
			"de": "💬 FlowManager: → Dialog (Mitte)",
			"en": "💬 FlowManager: → Dialog (Mid)"
		},
		"go_to_dialog_final": {
			"de": "💬 FlowManager: → Dialog (Final)",
			"en": "💬 FlowManager: → Dialog (Final)"
		},
		"go_to_map": {
			"de": "🗺️ FlowManager: → Map",
			"en": "🗺️ FlowManager: → Map"
		},
		"dialog_closed": {
			"de": "💬 FlowManager: Dialog geschlossen",
			"en": "💬 FlowManager: Dialog closed"
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
# Fragment Check
# -------------------------
func _get_fragment_count() -> int:
	if Player:
		return LoreManager.get_note_count() 
	return 0

func _should_show_mid_dialog() -> bool:
	return _get_fragment_count() == 2

func _should_show_final_dialog() -> bool:
	return _get_fragment_count() >= 4

# -------------------------
# Event Flow
# -------------------------
func end_event() -> void:
	print(_t("event_ended"))
	await get_tree().create_timer(0.5).timeout

	if not pending_note.is_empty():
		show_note_view()
	else:
		_continue_after_note()

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
	_continue_after_note()

# -------------------------
# Routing after NoteView
# -------------------------
func _continue_after_note() -> void:
	print("🔍 Fragment Count: ", _get_fragment_count())  # ← Welche Zahl siehst du?
	print("🔍 used_story_items: ", Player.used_story_items)
	
	if _should_show_final_dialog():
		print(_t("go_to_dialog_final"))
		pending_dialog = DIALOG_DATA["final"]
		Transition.change_scene(DIALOG_SCENE, 0.5)
	elif _should_show_mid_dialog():
		print(_t("go_to_dialog_mid"))
		pending_dialog = DIALOG_DATA["mid"]
		Transition.change_scene(DIALOG_SCENE, 0.5)
	else:
		go_to_map()

# -------------------------
# Dialog Finished
# Called from story_dialog.gd when player finishes dialog
# -------------------------
func dialog_closed() -> void:
	print(_t("dialog_closed"))
	pending_dialog = {}
	await get_tree().create_timer(0.3).timeout
	go_to_map()

# -------------------------
# Map
# -------------------------
func go_to_map() -> void:
	print(_t("go_to_map"))
	Transition.change_scene("res://scenes/MapScene.tscn", 0.5)
