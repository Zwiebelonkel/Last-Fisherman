extends Node
# ========================================
# LOREMANAGER - Persistent Notes
# ========================================
signal note_added(note_id: String, digit: int)
signal all_notes_collected()
# -------------------------
# Data
# -------------------------
var collected_notes: Dictionary = {}
# Format: { "fragment_01": { "digit": 1, "text": "..." } }
# -------------------------
# Note Definitions
# -------------------------
const NOTES: Dictionary = {
	"fragment_01": {
		"digit": 1,
		"name": "Fragment I",
		"text": "We did not flee. The sea did not take us. We stopped being seen."
	},
	"fragment_02": {
		"digit": 9,
		"name": "Fragment II",
		"text": "The fish only came when no one was looking anymore. They were always there. We were the problem."
	},
	"fragment_03": {
		"digit": 0,
		"name": "Fragment III",
		"text": "We called it research. Archival. Control. But the water remembers everything."
	},
	"fragment_04": {
		"digit": 6,
		"name": "Fragment IV",
		"text": "Someone must remain. Not to save. But to remember. If you're reading this, it's you now."
	}
}
# -------------------------
# Ready
# -------------------------
func _ready() -> void:
	load_data()
	print("📚 LoreManager: %d notes loaded" % collected_notes.size())
# -------------------------
# Add Note
# -------------------------
func add_note(note_id: String, digit: int = -1, text: String = "") -> void:
	if collected_notes.has(note_id):
		print("⚠️ LoreManager: Note already collected - %s" % note_id)
		return
	
	var note_data: Dictionary
	
	if NOTES.has(note_id):
		note_data = NOTES[note_id].duplicate()
	else:
		note_data = {
			"digit": digit,
			"name": "Fragment",
			"text": text
		}
	
	collected_notes[note_id] = note_data
	print("✅ LoreManager: Note added - %s (Digit: %d)" % [note_id, note_data.digit])
	
	emit_signal("note_added", note_id, note_data.digit)
	
	if collected_notes.size() == NOTES.size():
		emit_signal("all_notes_collected")
		print("🎉 LoreManager: All notes collected! Code: %s" % get_code())
	
	save_data()
# -------------------------
# Get Functions
# -------------------------
func has_note(note_id: String) -> bool:
	return collected_notes.has(note_id)
func get_note_count() -> int:
	return collected_notes.size()
func get_code() -> String:
	var code = ""
	var sorted_ids = collected_notes.keys()
	sorted_ids.sort()
	
	for note_id in sorted_ids:
		code += str(collected_notes[note_id].digit)
	
	return code
func is_code_complete() -> bool:
	return collected_notes.size() == NOTES.size()
# -------------------------
# Inventory Integration
# -------------------------
func get_inventory_notes() -> Array:
	var notes = []
	
	for note_id in collected_notes:
		var note = collected_notes[note_id]
		notes.append({
			"id": note_id,
			"name": note.get("name", "Fragment"),
			"category": "???",
			"description": "A mysterious note",
			"digit": note.get("digit", 0)
		})
	
	return notes
# -------------------------
# Save/Load
# -------------------------
func save_data() -> void:
	var save_data = { "collected_notes": collected_notes }
	var file = FileAccess.open("user://lore.dat", FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()
func load_data() -> void:
	if not FileAccess.file_exists("user://lore.dat"):
		return
	
	var file = FileAccess.open("user://lore.dat", FileAccess.READ)
	if file:
		var save_data = file.get_var()
		file.close()
		collected_notes = save_data.get("collected_notes", {})
func reset() -> void:
	collected_notes.clear()
	save_data()
	print("🔄 LoreManager: Reset")
