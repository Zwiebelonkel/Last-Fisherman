extends Node3D

var note_ui: NoteUI

func _ready() -> void:
	print("🏠 HUB MANAGER START")
	
	await get_tree().process_frame
	
	# Finde NoteUI
	var ui_nodes = get_tree().get_nodes_in_group("note_ui")
	print("Suche NoteUI: ", ui_nodes.size(), " gefunden")
	
	if ui_nodes.size() > 0:
		note_ui = ui_nodes[0]
		print("✅ NoteUI: ", note_ui.name)
	else:
		push_error("❌ KEINE NoteUI gefunden!")
		return
	
	# Registriere Notes
	var notes = get_tree().get_nodes_in_group("notes")
	print("Suche Notes: ", notes.size(), " gefunden")
	
	var registered = 0
	for note in notes:
		if note.has_signal("note_opened") and note.has_signal("note_closed"):
			note.note_opened.connect(_on_note_opened)
			note.note_closed.connect(_on_note_closed)
			registered += 1
			print("✅ Registriert: ", note.name)
		else:
			push_error("❌ Note fehlen Signals: ", note.name)
	
	print("SETUP ABGESCHLOSSEN - ", registered, " Notes registriert")

func _on_note_opened(title: String, text: String) -> void:
	print("\n🔔 MANAGER: Note öffnen")
	if note_ui:
		note_ui.show_note(title, text)
	else:
		push_error("❌ NoteUI ist NULL!")

func _on_note_closed() -> void:
	print("🔔 MANAGER: Note schließen\n")
	if note_ui:
		note_ui.hide_note()
	else:
		push_error("❌ NoteUI ist NULL!")
