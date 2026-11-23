extends OptionButton

const LANGUAGE_CODES: PackedStringArray = ["de", "en", "ru", "tr", "es", "fr", "pl"]
const LANGUAGE_NAMES: PackedStringArray = ["Deutsch", "English", "Русский", "Türkçe", "Español", "Français", "Polski"]

func _ready() -> void:
	# Show each language in its native spelling, independent of the active locale.
	auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	clear()
	for language_name in LANGUAGE_NAMES:
		add_item(language_name)
	var saved_index := LANGUAGE_CODES.find(Player.current_language)
	select(saved_index if saved_index >= 0 else 0)

func _on_item_selected(index: int) -> void:
	if index < 0 or index >= LANGUAGE_CODES.size():
		return
	Player.current_language = LANGUAGE_CODES[index]
	TranslationServer.set_locale(Player.current_language)
	Player.save_settings()
	Engine.time_scale = 1
	get_tree().reload_current_scene()
