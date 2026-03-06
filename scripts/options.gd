extends Control

@onready var click: AudioStreamPlayer = $Audio/click

func _on_menu_pressed() -> void:
	get_tree().paused = false
	click.play()
	Engine.time_scale = 1
	Player.save_game()
	Transition.back_to_main()
	
func _on_stats_pressed() -> void:
	var stats = $StatsUI
	stats.show()
	click.play()
