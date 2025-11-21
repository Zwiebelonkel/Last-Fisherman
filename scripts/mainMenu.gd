extends Node3D


func _on_button_pressed() -> void:
	Player.update_last_scene("res://scenes/MainScene_City.tscn")
	get_tree().change_scene_to_file("res://scenes/MainScene.tscn")


func _on_reset_button_pressed() -> void:
	Player.reset()
	Player.save_game()
	print("Spiel wurde zurückgesetzt!")
	# Optional: Szene neu laden
	get_tree().reload_current_scene()
