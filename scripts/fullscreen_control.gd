extends CheckButton

func _ready() -> void:
	# Setze gespeicherten Fullscreen-Status
	button_pressed = Player.fullscreen

func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	Player.fullscreen = toggled_on
	Player.save_settings()
