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
		"name_ru": "Фрагмент I",
		"name_tr": "Parça I",
		"name_es": "Fragmento I",
		"name_fr": "Fragment I",
		"name_pl": "Fragment I",
		"text_de": "Wir sind nicht geflohen. Das Meer hat uns nicht genommen. Wir haben aufgehört, gesehen zu werden.",
		"text_en": "We did not flee. The sea did not take us. We stopped being seen.",
		"text_ru": "Мы не бежали. Море не забрало нас. Нас просто перестали видеть.",
		"text_tr": "Kaçmadık. Deniz bizi almadı. Görülmez olduk.",
		"text_es": "No huimos. El mar no nos llevó. Dejaron de vernos.",
		"text_fr": "Nous n'avons pas fui. La mer ne nous a pas emportés. On a cessé de nous voir.",
		"text_pl": "Nie uciekliśmy. Morze nas nie zabrało. Przestano nas widzieć."
	},
	"fragment_02": {
		"digit": 9,
		"name_de": "Fragment II",
		"name_en": "Fragment II",
		"name_ru": "Фрагмент II",
		"name_tr": "Parça II",
		"name_es": "Fragmento II",
		"name_fr": "Fragment II",
		"name_pl": "Fragment II",
		"text_de": "Die Fische kamen erst, als niemand mehr hinsah. Sie waren immer da. Wir waren das Problem.",
		"text_en": "The fish only came when no one was looking anymore. They were always there. We were the problem.",
		"text_ru": "Рыбы пришли, лишь когда никто больше не смотрел. Они всегда были здесь. Проблема была в нас.",
		"text_tr": "Balıklar ancak kimse bakmaz olunca geldi. Hep oradaydılar. Sorun bizdik.",
		"text_es": "Los peces solo llegaron cuando ya nadie miraba. Siempre estuvieron allí. Nosotros éramos el problema.",
		"text_fr": "Les poissons ne sont venus que lorsque plus personne ne regardait. Ils avaient toujours été là. Le problème, c'était nous.",
		"text_pl": "Ryby przypłynęły dopiero, gdy nikt już nie patrzył. Zawsze tu były. To my byliśmy problemem."
	},
	"fragment_03": {
		"digit": 0,
		"name_de": "Fragment III",
		"name_en": "Fragment III",
		"name_ru": "Фрагмент III",
		"name_tr": "Parça III",
		"name_es": "Fragmento III",
		"name_fr": "Fragment III",
		"name_pl": "Fragment III",
		"text_de": "Wir nannten es Forschung. Archivierung. Kontrolle. Aber das Wasser merkt sich alles.",
		"text_en": "We called it research. Archival. Control. But the water remembers everything.",
		"text_ru": "Мы называли это исследованием. Архивацией. Контролем. Но вода помнит всё.",
		"text_tr": "Buna araştırma dedik. Arşivleme. Kontrol. Ama su her şeyi hatırlar.",
		"text_es": "Lo llamamos investigación. Archivo. Control. Pero el agua lo recuerda todo.",
		"text_fr": "Nous appelions cela recherche. Archivage. Contrôle. Mais l'eau se souvient de tout.",
		"text_pl": "Nazywaliśmy to badaniami. Archiwizacją. Kontrolą. Ale woda pamięta wszystko."
	},
	"fragment_04": {
		"digit": 6,
		"name_de": "Fragment IV",
		"name_en": "Fragment IV",
		"name_ru": "Фрагмент IV",
		"name_tr": "Parça IV",
		"name_es": "Fragmento IV",
		"name_fr": "Fragment IV",
		"name_pl": "Fragment IV",
		"text_de": "Einer muss bleiben. Nicht um zu retten. Sondern um zu erinnern. Wenn du das liest, bist du es jetzt.",
		"text_en": "Someone must remain. Not to save. But to remember. If you're reading this, it's you now.",
		"text_ru": "Кто-то должен остаться. Не чтобы спасти. Чтобы помнить. Если ты это читаешь — теперь это ты.",
		"text_tr": "Biri kalmalı. Kurtarmak için değil. Hatırlamak için. Bunu okuyorsan, artık o kişi sensin.",
		"text_es": "Alguien debe quedarse. No para salvar. Para recordar. Si estás leyendo esto, ahora eres tú.",
		"text_fr": "Quelqu'un doit rester. Pas pour sauver. Pour se souvenir. Si tu lis ceci, c'est désormais toi.",
		"text_pl": "Ktoś musi zostać. Nie po to, by ratować. Lecz by pamiętać. Jeśli to czytasz, teraz to ty."
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
			"en": "📚 LoreManager: %d notes loaded",
			"ru": "📚 LoreManager: загружено записок: %d",
			"tr": "📚 LoreManager: %d not yüklendi",
			"es": "📚 LoreManager: %d notas cargadas",
			"fr": "📚 LoreManager : %d notes chargées",
			"pl": "📚 LoreManager: wczytano %d notatek"
		},
		"note_already_collected": {
			"de": "⚠️ LoreManager: Note bereits gesammelt - %s",
			"en": "⚠️ LoreManager: Note already collected - %s",
			"ru": "⚠️ LoreManager: записка уже собрана — %s",
			"tr": "⚠️ LoreManager: Not zaten toplandı - %s",
			"es": "⚠️ LoreManager: nota ya recogida - %s",
			"fr": "⚠️ LoreManager : note déjà collectée - %s",
			"pl": "⚠️ LoreManager: notatka już zebrana - %s"
		},
		"note_added": {
			"de": "✅ LoreManager: Note hinzugefügt - %s (Ziffer: %d)",
			"en": "✅ LoreManager: Note added - %s (Digit: %d)",
			"ru": "✅ LoreManager: записка добавлена — %s (цифра: %d)",
			"tr": "✅ LoreManager: Not eklendi - %s (Rakam: %d)",
			"es": "✅ LoreManager: nota añadida - %s (dígito: %d)",
			"fr": "✅ LoreManager : note ajoutée - %s (chiffre : %d)",
			"pl": "✅ LoreManager: dodano notatkę - %s (cyfra: %d)"
		},
		"all_notes_collected": {
			"de": "🎉 LoreManager: Alle Zettel gesammelt! Code: %s",
			"en": "🎉 LoreManager: All notes collected! Code: %s",
			"ru": "🎉 LoreManager: все записки собраны! Код: %s",
			"tr": "🎉 LoreManager: Tüm notlar toplandı! Kod: %s",
			"es": "🎉 LoreManager: ¡Todas las notas recogidas! Código: %s",
			"fr": "🎉 LoreManager : toutes les notes collectées ! Code : %s",
			"pl": "🎉 LoreManager: zebrano wszystkie notatki! Kod: %s"
		},
		"lore_reset": {
			"de": "🔄 LoreManager: Reset",
			"en": "🔄 LoreManager: Reset",
			"ru": "🔄 LoreManager: сброс",
			"tr": "🔄 LoreManager: Sıfırla",
			"es": "🔄 LoreManager: reinicio",
			"fr": "🔄 LoreManager : réinitialisation",
			"pl": "🔄 LoreManager: reset"
		},
		"fragment": {
			"de": "Fragment",
			"en": "Fragment",
			"ru": "Фрагмент",
			"tr": "Parça",
			"es": "Fragmento",
			"fr": "Fragment",
			"pl": "Fragment"
		},
		"mysterious_note": {
			"de": "Ein mysteriöser Zettel",
			"en": "A mysterious note",
			"ru": "Таинственная записка",
			"tr": "Gizemli bir not",
			"es": "Una nota misteriosa",
			"fr": "Une note mystérieuse",
			"pl": "Tajemnicza notatka"
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
