extends Node

# ========================================
# LOREMANAGER - Persistente Zettel
# ========================================

signal note_added(note_id: String, digit: int)
signal all_notes_collected()

# -------------------------
# Data
# -------------------------
var collected_notes: Dictionary = {}
# Format: { "fragment_01": { "digit": 1, "text": "..." } }

# -------------------------
# Zettel-Definitionen
# -------------------------
const NOTES: Dictionary = {
	"fragment_01": {
		"digit": 1,
		"name": "Fragment I",
		"text": "Wir sind nicht geflohen. Das Meer hat uns nicht genommen. Wir haben aufgehört, gesehen zu werden."
	},
	"fragment_02": {
		"digit": 9,
		"name": "Fragment II",
		"text": "Die Fische kamen erst, als niemand mehr hinsah. Sie waren immer da. Wir waren das Problem."
	},
	"fragment_03": {
		"digit": 0,
		"name": "Fragment III",
		"text": "Wir nannten es Forschung. Archivierung. Kontrolle. Aber das Wasser merkt sich alles."
	},
	"fragment_04": {
		"digit": 6,
		"name": "Fragment IV",
		"text": "Einer muss bleiben. Nicht um zu retten. Sondern um zu erinnern. Wenn du das liest, bist du es jetzt."
	}
}

# -------------------------
# Ready
# -------------------------
func _ready() -> void:
	load_data()
	print("📚 LoreManager: %d Zettel geladen" % collected_notes.size())

# -------------------------
# Add Note
# -------------------------
func add_note(note_id: String, digit: int = -1, text: String = "") -> void:
	if collected_notes.has(note_id):
		print("⚠️ LoreManager: Note bereits gesammelt - %s" % note_id)
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
	print("✅ LoreManager: Note hinzugefügt - %s (Ziffer: %d)" % [note_id, note_data.digit])
	
	emit_signal("note_added", note_id, note_data.digit)
	
	if collected_notes.size() == NOTES.size():
		emit_signal("all_notes_collected")
		print("🎉 LoreManager: Alle Zettel gesammelt! Code: %s" % get_code())
	
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
			"description": "Ein mysteriöser Zettel",
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
