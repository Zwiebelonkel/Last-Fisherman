extends Node3D

@export var options: Node
var optionsActive: bool = false

func _ready() -> void:
	var ani : AnimationPlayer = $DirectionalLight3D/AnimationPlayer
	ani.play("circle")

# 🆕 ESC-Handling hinzugefügt
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("pause"):  # ESC-Taste
		if optionsActive:
			hideSettings()
		# Wenn Settings nicht offen ist, passiert nichts (kein Pause-Menü im Hauptmenü)

func _on_button_pressed() -> void:
	Player.update_last_scene("res://scenes/MainScene.tscn")
	Transition.change_scene("res://scenes/MainScene.tscn", 0.8)

func _on_reset_button_pressed() -> void:
	Player.reset()
	Player.save_game()
	print("Spiel wurde zurückgesetzt!")
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_settings_pressed() -> void:
	if optionsActive:
		hideSettings()
	elif !optionsActive:
		showSettings()

func showSettings() -> void:
	options.show()
	optionsActive = true
	
func hideSettings() -> void:
	options.hide()
	optionsActive = false

func _on_credits_pressed() -> void:
	Transition.change_scene("res://scenes/credits.tscn", 0.5)
