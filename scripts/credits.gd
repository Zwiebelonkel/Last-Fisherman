extends Panel


func _ready() -> void:
	# Alle RichTextLabel verbinden
	for child in _get_all_rich_labels($VScrollBar/MarginContainer/VBoxContainer):
		child.meta_clicked.connect(_on_link_clicked)


func _on_link_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))


func _on_button_pressed() -> void:
	Transition.back_to_main()


func _get_all_rich_labels(node: Node) -> Array:
	var result := []
	for child in node.get_children():
		if child is RichTextLabel:
			result.append(child)
	return result
