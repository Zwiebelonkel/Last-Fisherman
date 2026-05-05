extends Control
class_name NoteUI

var panel: Panel
var title_label: Label
var text_label: RichTextLabel
var close_button: Button
var is_showing: bool = false

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	print("🎨 NOTE UI READY")
	
	panel = find_child("Panel", true, false)
	if panel:
		var vbox = panel.find_child("VBoxContainer", true, false)
		if vbox:
			title_label = vbox.find_child("Title", true, false)
			close_button = vbox.find_child("CloseButton", true, false)
			var scroll = vbox.find_child("ScrollContainer", true, false)
			if scroll:
				text_label = scroll.find_child("Text", true, false)
	
	print("  Panel: ", panel != null)
	print("  Title: ", title_label != null)
	print("  Text: ", text_label != null)
	print("  Button: ", close_button != null)
	
	if not panel or not title_label or not text_label:
		push_error("❌ NOTE UI: Kritische Nodes fehlen!")
		return
	
	if close_button:
		close_button.pressed.connect(hide_note)
	
	hide()
	set_process_input(false)
	
	# Notes die bereits im Baum sind verbinden
	await get_tree().process_frame
	for note in get_tree().get_nodes_in_group("notes"):
		_connect_note(note)
	
	# Zukünftige Notes verbinden
	get_tree().node_added.connect(_on_node_added)

func _on_node_added(node: Node) -> void:
	if node.is_in_group("notes"):
		_connect_note(node)

func _connect_note(node: Node) -> void:
	if not node.note_opened.is_connected(show_note):
		node.note_opened.connect(show_note)
	if not node.note_closed.is_connected(hide_note):
		node.note_closed.connect(hide_note)
	print("🔗 Note verbunden: ", node.name)

func show_note(title: String, text: String) -> void:
	print("🎨 ZEIGE NOTE UI: ", title)
	if title_label:
		title_label.text = title
	if text_label:
		text_label.text = text
	is_showing = true
	show()
	set_process_input(true)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func hide_note() -> void:
	print("🎨 VERSTECKE NOTE UI")
	is_showing = false
	hide()
	set_process_input(false)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if not is_showing:
		return
	if event.is_action_pressed("ui_cancel"):
		print("ESC → Note schließen")
		hide_note()
