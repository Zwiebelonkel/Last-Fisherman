extends OptionButton

# Reihenfolge muss zu deinen OptionButton-Items passen:
# "unlimited", "120", "60", "30"
var fps_options := [0, 120, 60, 30]

func _ready() -> void:
	# Gespeichertes FPS-Limit laden
	var saved = Player.frame_limit  # z. B. 0, 120, 60, 30

	# Index suchen
	var saved_index := fps_options.find(saved)
	if saved_index != -1:
		selected = saved_index


func _on_item_selected(index: int) -> void:
	var value = fps_options[index]

	# FPS anwenden
	Engine.max_fps = value  # 0 = unlimited

	# Speichern
	Player.frame_limit = value
	Player.save_settings()
