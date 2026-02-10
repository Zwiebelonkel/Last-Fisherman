extends Node

# ========================================
# FLOWMANAGER - EVENT → NOTE → MAP
# ========================================

# -------------------------
# State
# -------------------------
var pending_note: Dictionary = {}

# -------------------------
# Note Registration
# -------------------------
func register_note(id: String, digit: int, text: String) -> void:
	pending_note = {
		"id": id,
		"digit": digit,
		"text": text
	}
	print("📝 FlowManager: Note registriert - %s (Ziffer: %d)" % [id, digit])

# -------------------------
# Event Flow
# -------------------------
func end_event() -> void:
	print("🎬 FlowManager: Event beendet")
	
	await get_tree().create_timer(0.5).timeout
	
	if not pending_note.is_empty():
		show_note_view()
	else:
		go_to_map()

# -------------------------
# Note View
# -------------------------
func show_note_view() -> void:
	print("📄 FlowManager: → NoteView")
	Transition.change_scene("res://scenes/NoteView.tscn", 0.5)

func note_view_closed() -> void:
	print("📄 FlowManager: NoteView geschlossen")
	pending_note = {}
	
	await get_tree().create_timer(0.3).timeout
	go_to_map()

# -------------------------
# Map
# -------------------------
func go_to_map() -> void:
	print("🗺️ FlowManager: → Map")
	Transition.change_scene("res://scenes/MapScene.tscn", 0.5)
