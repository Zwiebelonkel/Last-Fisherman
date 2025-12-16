# language_control.gd
extends OptionButton

func _ready() -> void:
	# Lade gespeicherte Sprache aus Player
	match Player.current_language:
		"de":
			select(0)  # Deutsch
		"en":
			select(1)  # English
		_:
			select(0)  # Default: Deutsch

func _on_item_selected(index: int) -> void:
	match index:
		0:  # Deutsch
			Player.current_language = "de"
			TranslationServer.set_locale("de")
		1:  # English
			Player.current_language = "en"
			TranslationServer.set_locale("en")
	
	# Speichern
	Player.save_settings()
	
	# UI neu laden für sofortige Übersetzung
	Engine.time_scale = 1
	get_tree().reload_current_scene()
