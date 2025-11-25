extends Control

func _on_menu_pressed() -> void:
	get_tree().paused = false
	Engine.time_scale = 1
	Player.save_game()
	get_tree().change_scene_to_file("res://scenes/mainMenu.tscn")
