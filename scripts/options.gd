extends Control

@onready var click: AudioStreamPlayer = $Audio/click

func _ready() -> void:
	$Panel/VBoxContainer/CRTControl.button_pressed = Player.crt_enabled

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
	
func _on_crt_toggled(enabled: bool) -> void:
	Player.crt_enabled = enabled
	Player.save_settings()
	Player._set_crt_visible(get_tree().root, enabled)

func _set_crt_visible(node: Node, enabled: bool) -> void:
	for child in node.get_children():
		if child.name == "CRT":
			child.visible = enabled
		_set_crt_visible(child, enabled)
