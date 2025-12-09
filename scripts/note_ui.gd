extends Control
class_name NoteUI

var panel: Panel
var title_label: Label
var text_label: RichTextLabel
var close_button: Button
var is_showing: bool = false

func _ready() -> void:
	print("🎨 NOTE UI READY")
	
	# Finde Nodes
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

func show_note(title: String, text: String) -> void:
	print("🎨 ZEIGE NOTE UI")
	print("  Title: ", title)
	
	if title_label:
		title_label.text = title
	if text_label:
		text_label.text = text
	
	is_showing = true
	visible = true
	show()
	set_process_input(true)
	
	print("  ✅ UI sichtbar: ", visible)

func hide_note() -> void:
	print("🎨 VERSTECKE NOTE UI")
	is_showing = false
	hide()
	set_process_input(false)

func _input(event: InputEvent) -> void:
	if not is_showing:
		return
	
	# ESC schließt
	if event.is_action_pressed("ui_cancel"):
		print("ESC → Note schließen")
		hide_note()
