extends OptionButton

func _ready() -> void:
	# Setze gespeicherte Auflösung
	var options = [1.0, 0.75, 0.5, 0.25]
	var saved_index = options.find(Player.resolution_scale)
	if saved_index != -1:
		selected = saved_index

func _on_item_selected(index: int) -> void:
	var options = [1.0, 0.75, 0.5, 0.25]
	var value = options[index]
	get_tree().root.scaling_3d_scale = value
	
	Player.resolution_scale = value
	Player.save_settings()
