extends CheckButton

@export var touch_buttons_path: NodePath
var touchButtons: Node

func _ready():
	if touch_buttons_path:
		touchButtons = get_node(touch_buttons_path)

func _on_toggled(toggled_on: bool) -> void:
	if touchButtons:
		touchButtons.visible = !toggled_on
