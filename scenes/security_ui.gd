extends CanvasLayer
class_name SecurityUI

@onready var back_button: Button = $BackButton

var controller: Node = null

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	visible = false

func set_controller(c: Node) -> void:
	controller = c

func show_ui() -> void:
	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func hide_ui() -> void:
	visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_back_pressed() -> void:
	if controller:
		controller.exit_security_view()
