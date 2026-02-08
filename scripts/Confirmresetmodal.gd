extends CanvasLayer

signal confirm_reset
signal cancel_reset

@onready var animation_player = $AnimationPlayer
@onready var panel = $Panel
@onready var confirm_button = $Panel/MarginContainer/VBoxContainer/ButtonContainer/ConfirmButton
@onready var cancel_button = $Panel/MarginContainer/VBoxContainer/ButtonContainer/CancelButton

func _ready() -> void:
	# Verbinde Button Signals
	confirm_button.pressed.connect(_on_confirm_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)
	
	# Hover Effects
	confirm_button.mouse_entered.connect(_on_confirm_hover)
	confirm_button.mouse_exited.connect(_on_confirm_unhover)
	cancel_button.mouse_entered.connect(_on_cancel_hover)
	cancel_button.mouse_exited.connect(_on_cancel_unhover)
	
	# Starte Popup Animation
	animation_player.play("popup")
	
	# ESC schließt Modal
	set_process_input(true)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause"):
		_on_cancel_pressed()
		get_viewport().set_input_as_handled()

# Confirm Button wurde gedrückt
func _on_confirm_pressed() -> void:
	# Shake Animation für dramatischen Effekt
	shake_panel()
	await get_tree().create_timer(0.3).timeout
	
	confirm_reset.emit()
	close_modal()

# Cancel Button wurde gedrückt
func _on_cancel_pressed() -> void:
	cancel_reset.emit()
	close_modal()

# Modal schließen mit Animation
func close_modal() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(panel, "scale", Vector2(0.8, 0.8), 0.2)
	tween.tween_property(panel, "modulate", Color(1, 1, 1, 0), 0.2)
	tween.tween_property($Overlay, "modulate", Color(1, 1, 1, 0), 0.2)
	await tween.finished
	queue_free()

# Hover Effekt für Confirm Button (rot)
func _on_confirm_hover() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(confirm_button, "scale", Vector2(1.1, 1.1), 0.3)
	
	# Rote Pulsation
	pulse_button(confirm_button, Color(1, 0.3, 0.3, 1))

func _on_confirm_unhover() -> void:
	var tween = create_tween()
	tween.tween_property(confirm_button, "scale", Vector2(1.0, 1.0), 0.2)
	tween.parallel().tween_property(confirm_button, "modulate", Color(1, 1, 1, 1), 0.2)

# Hover Effekt für Cancel Button (blau)
func _on_cancel_hover() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(cancel_button, "scale", Vector2(1.1, 1.1), 0.3)
	
	# Blaue Pulsation
	pulse_button(cancel_button, Color(0.5, 0.8, 1, 1))

func _on_cancel_unhover() -> void:
	var tween = create_tween()
	tween.tween_property(cancel_button, "scale", Vector2(1.0, 1.0), 0.2)
	tween.parallel().tween_property(cancel_button, "modulate", Color(1, 1, 1, 1), 0.2)

# Pulsations-Effekt
func pulse_button(button: Button, color: Color) -> void:
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(button, "modulate", color, 0.5)
	tween.tween_property(button, "modulate", Color(1, 1, 1, 1), 0.5)

# Shake Effekt für Panel
func shake_panel() -> void:
	var original_pos = panel.position
	var tween = create_tween()
	tween.set_loops(4)
	tween.tween_property(panel, "position", original_pos + Vector2(5, 0), 0.05)
	tween.tween_property(panel, "position", original_pos + Vector2(-5, 0), 0.05)
	tween.tween_callback(func(): panel.position = original_pos)
