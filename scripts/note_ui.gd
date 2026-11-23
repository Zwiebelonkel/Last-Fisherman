extends Control
class_name NoteUI

var panel: Panel
var title_label: Label
var text_label: RichTextLabel
var close_button: Button
var is_showing: bool = false
var _active_note: Note
var _closing_key: int = KEY_NONE

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
	var opened := _on_note_opened.bind(node)
	var closed := _on_note_closed.bind(node)
	if not node.note_opened.is_connected(opened):
		node.note_opened.connect(opened)
	if not node.note_closed.is_connected(closed):
		node.note_closed.connect(closed)
	print("🔗 Note verbunden: ", node.name)

func _on_note_opened(title: String, text: String, note: Note) -> void:
	if is_instance_valid(_active_note) and _active_note != note:
		_active_note.close_note()
	_active_note = note
	show_note(title, text)

func _on_note_closed(note: Note) -> void:
	if _active_note == note:
		hide_note()

func show_note(title: String, text: String) -> void:
	Player.set_story_crt_active(self, true)
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
	Player.set_story_crt_active(self, false)
	print("🎨 VERSTECKE NOTE UI")
	is_showing = false
	hide()
	set_process_input(_closing_key != KEY_NONE)
	var note := _active_note
	_active_note = null
	if is_instance_valid(note) and note.note_is_open:
		note.last_interaction_frame = Engine.get_process_frames()
		note.close_note()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key == null:
		if is_showing and event.is_action_pressed("ui_cancel"):
			get_viewport().set_input_as_handled()
			hide_note()
		return
	var code: int = key.physical_keycode if key.physical_keycode != KEY_NONE else key.keycode
	# Keep swallowing this shortcut after hiding, including repeat and key-up.
	if code == _closing_key and _closing_key != KEY_NONE:
		get_viewport().set_input_as_handled()
		if not key.pressed:
			_closing_key = KEY_NONE
			set_process_input(is_showing)
		return
	if not is_showing:
		return
	if key.pressed and not key.echo and (code == KEY_E or code == KEY_ESCAPE or event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause")):
		_closing_key = code
		get_viewport().set_input_as_handled()
		hide_note()
