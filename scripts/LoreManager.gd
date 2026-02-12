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
		"name_de": "Fragment I",
		"name_en": "Fragment I",
		"text_de": "Wir sind nicht geflohen. Das Meer hat uns nicht genommen. Wir haben aufgehört, gesehen zu werden.",
		"text_en": "We did not flee. The sea did not take us. We stopped being seen."
	},
	"fragment_02": {
		"digit": 9,
		"name_de": "Fragment II",
		"name_en": "Fragment II",
		"text_de": "Die Fische kamen erst, als niemand mehr hinsah. Sie waren immer da. Wir waren das Problem.",
		"text_en": "The fish only came when no one was looking anymore. They were always there. We were the problem."
	},
	"fragment_03": {
		"digit": 0,
		"name_de": "Fragment III",
		"name_en": "Fragment III",
		"text_de": "Wir nannten es Forschung. Archivierung. Kontrolle. Aber das Wasser merkt sich alles.",
		"text_en": "We called it research. Archival. Control. But the water remembers everything."
	},
	"fragment_04": {
		"digit": 6,
		"name_de": "Fragment IV",
		"name_en": "Fragment IV",
		"text_de": "Einer muss bleiben. Nicht um zu retten. Sondern um zu erinnern. Wenn du das liest, bist du es jetzt.",
		"text_en": "Someone must remain. Not to save. But to remember. If you're reading this, it's you now."
	}
}

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
		"notes_loaded": {
			"de": "📚 LoreManager: %d Zettel geladen",
			"en": "📚 LoreManager: %d notes loaded"
		},
		"note_already_collected": {
			"de": "⚠️ LoreManager: Note bereits gesammelt - %s",
			"en": "⚠️ LoreManager: Note already collected - %s"
		},
		"note_added": {
			"de": "✅ LoreManager: Note hinzugefügt - %s (Ziffer: %d)",
			"en": "✅ LoreManager: Note added - %s (Digit: %d)"
		},
		"all_notes_collected": {
			"de": "🎉 LoreManager: Alle Zettel gesammelt! Code: %s",
			"en": "🎉 LoreManager: All notes collected! Code: %s"
		},
		"lore_reset": {
			"de": "🔄 LoreManager: Reset",
			"en": "🔄 LoreManager: Reset"
		},
		"fragment": {
			"de": "Fragment",
			"en": "Fragment"
		},
		"mysterious_note": {
			"de": "Ein mysteriöser Zettel",
			"en": "A mysterious note"
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
# Get localized note data
# -------------------------
func _get_localized_note(note_id: String) -> Dictionary:
	"""Returns note with localized name and text"""
	if not NOTES.has(note_id):
		return {}
	
	var note = NOTES[note_id].duplicate()
	var lang = _get_lang()
	
	# Set localized name
	var name_key = "name_" + lang
	if note.has(name_key):
		note["name"] = note[name_key]
	elif note.has("name_en"):
		note["name"] = note["name_en"]
	else:
		note["name"] = _t("fragment")
	
	# Set localized text
	var text_key = "text_" + lang
	if note.has(text_key):
		note["text"] = note[text_key]
	elif note.has("text_en"):
		note["text"] = note["text_en"]
	else:
		note["text"] = ""
	
	return note

# -------------------------
# Ready
# -------------------------
func _ready() -> void:
	load_data()
	print(_t("notes_loaded") % collected_notes.size())

# -------------------------
# Add Note
# -------------------------
func add_note(note_id: String, digit: int = -1, text: String = "") -> void:
	if collected_notes.has(note_id):
		print(_t("note_already_collected") % note_id)
		return
	
	var note_data: Dictionary
	
	if NOTES.has(note_id):
		note_data = _get_localized_note(note_id)
	else:
		note_data = {
			"digit": digit,
			"name": _t("fragment"),
			"text": text
		}
	
	collected_notes[note_id] = note_data
	print(_t("note_added") % [note_id, note_data.digit])
	
	emit_signal("note_added", note_id, note_data.digit)
	
	if collected_notes.size() == NOTES.size():
		emit_signal("all_notes_collected")
		print(_t("all_notes_collected") % get_code())
	
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
			"name": note.get("name", _t("fragment")),
			"category": "???",
			"description": _t("mysterious_note"),
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
		
		# Update localization for loaded notes
		_update_note_localization()

# -------------------------
# Update localization for existing notes
# -------------------------
func _update_note_localization() -> void:
	"""Updates name and text for all collected notes based on current language"""
	for note_id in collected_notes.keys():
		if NOTES.has(note_id):
			var localized = _get_localized_note(note_id)
			collected_notes[note_id]["name"] = localized.get("name", _t("fragment"))
			collected_notes[note_id]["text"] = localized.get("text", "")

func reset() -> void:
	collected_notes.clear()
	save_data()
	print(_t("lore_reset"))
