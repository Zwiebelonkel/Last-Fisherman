extends StaticBody3D
class_name StationSecurity


var controller: Node = null
var is_hovering := false


func set_controller(c: Node) -> void:
	controller = c

func set_hover(hover: bool) -> void:
	is_hovering = hover

func interact() -> void:
	if controller:
		controller.enter_security_view()
		
