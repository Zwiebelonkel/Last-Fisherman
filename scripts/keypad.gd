extends Node3D
class_name Keypad

const KEYPAD_UI_SCENE := preload("res://scenes/KeypadUI.tscn")
const KeypadUIController := preload("res://scripts/KeypadUI.gd")

# -------------------------
# Signals
# -------------------------
signal code_correct()
signal code_incorrect()

# -------------------------
# Configuration
# -------------------------
@export var correct_code: String = "1906"  # Ändere den Code hier
@export var secret_code: String = "1234"  # Ändere den Code hier
@export var interaction_distance: float = 3.0
@export var event_echo_scene: PackedScene = preload("res://scenes/event_echo.tscn")
@export var ending_scene: PackedScene = preload("res://scenes/ending.tscn")
@export var secret_scene: PackedScene = preload("res://scenes/rave.tscn")

# -------------------------
# State
# -------------------------
var current_input: String = ""
var is_active: bool = false
var player: CharacterBody3D = null
var event_echo: EventEcho = null
var is_processing: bool = false
var keypad_ui: KeypadUIController
var _session: int = 0
var _accepted := false

# -------------------------
# Node References
# -------------------------
@onready var display_label: Label3D = $Display
@onready var audio_beep: AudioStreamPlayer3D = $AudioBeep
@onready var audio_success: AudioStreamPlayer3D = $AudioSuccess
@onready var audio_error: AudioStreamPlayer3D = $AudioError
@onready var interaction_area: Area3D = $InteractionArea
@onready var prompt_label: Label3D = $Prompt


# -------------------------
# Ready
# -------------------------
func _ready() -> void:
	keypad_ui = KEYPAD_UI_SCENE.instantiate() as KeypadUIController
	add_child(keypad_ui)
	keypad_ui.digit_pressed.connect(add_digit)
	keypad_ui.erase_pressed.connect(remove_last_digit)
	keypad_ui.clear_pressed.connect(clear_input)
	keypad_ui.submitted.connect(check_code)
	keypad_ui.close_requested.connect(deactivate)
	player = get_tree().get_first_node_in_group("player") as CharacterBody3D
	prompt_label.text = KeypadUIController.text_for("prompt")
	prompt_label.hide()
	
	# Verbinde Area3D Signale
	if interaction_area:
		interaction_area.body_entered.connect(_on_body_entered)
		interaction_area.body_exited.connect(_on_body_exited)
	
	# Initiales Display
	update_display()

# -------------------------
# Process
# -------------------------
func _process(_delta: float) -> void:
	if is_active and not can_interact():
		deactivate()

func can_interact() -> bool:
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as CharacterBody3D
	return is_instance_valid(player) and not _accepted and global_position.distance_to(player.global_position) <= interaction_distance

func get_interaction_prompt() -> String:
	return KeypadUIController.text_for("prompt")

# -------------------------
# Digit Management
# -------------------------
func add_digit(digit: String) -> void:
	if not is_active or is_processing or digit.length() != 1 or not digit.is_valid_int():
		return
	if current_input.length() >= correct_code.length():
		return
	
	current_input += digit
	update_display()
	keypad_ui.set_feedback("ready")
	play_beep()
	
func clear_input() -> void:
	if not is_active or is_processing:
		return
	current_input = ""
	update_display()
	keypad_ui.set_feedback("ready")
	play_beep()

func remove_last_digit() -> void:
	if not is_active or is_processing or current_input.is_empty():
		return
	
	current_input = current_input.substr(0, current_input.length() - 1)
	update_display()
	keypad_ui.set_feedback("ready")
	play_beep()

# -------------------------
# Code Validation
# -------------------------
func check_code() -> void:
	if not is_active or is_processing:
		return
	if current_input.length() != correct_code.length():
		keypad_ui.set_feedback("incomplete")
		return
	
	if current_input == secret_code:
		on_secret_code()
	elif current_input == correct_code:
		on_correct_code()
	else:
		on_incorrect_code()

func on_secret_code() -> void:
	if is_processing:
		return
	
	is_processing = true
	_accepted = true
	keypad_ui.set_busy(true)
	keypad_ui.set_feedback("secret")
	print("🎉 SECRET CODE!")
	
	play_success()
	display_label.modulate = Color.MAGENTA
	
	is_active = false
	
	await get_tree().create_timer(1.0).timeout
	
	keypad_ui.close_ui()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Transition.change_scene("res://scenes/rave.tscn", 1.0)

func on_correct_code() -> void:
	if is_processing:
		return
	
	is_processing = true
	_accepted = true
	keypad_ui.set_busy(true)
	keypad_ui.set_feedback("correct")
	
	print("✅ CORRECT CODE!")
	
	play_success()
	display_label.modulate = Color.GREEN
	
	emit_signal("code_correct")
	
	is_active = false
	
	await get_tree().create_timer(1.0).timeout
	keypad_ui.close_ui()
	show_event_echo()

func on_incorrect_code() -> void:
	is_processing = true
	var session := _session
	play_error()
	display_label.modulate = Color.RED
	keypad_ui.set_feedback("incorrect")
	keypad_ui.set_busy(true)
	emit_signal("code_incorrect")
	await get_tree().create_timer(0.8).timeout
	if session != _session or not is_active:
		return
	display_label.modulate = Color.WHITE
	current_input = ""
	is_processing = false
	update_display()
	keypad_ui.set_busy(false)

# -------------------------
# Event Echo & Scene Transition
# -------------------------
func show_event_echo() -> void:
	if not event_echo_scene:
		push_error("❌ EventEcho Scene nicht gesetzt!")
		go_to_ending()
		return
	
	# Erstelle Event Echo
	event_echo = event_echo_scene.instantiate()
	get_tree().root.add_child(event_echo)
	AudioServer.set_bus_mute(
		AudioServer.get_bus_index("Music"),
		true
	)
	AudioServer.set_bus_mute(
		AudioServer.get_bus_index("SFX"),
		true
	)
	
	# Setze Event-Text (anpassen nach Bedarf)
	event_echo.set_event(
		EventEcho.EventType.OCEAN,  # Wähle passenden Typ
		tr("EVENT_OCEAN")
	)
	
	# Warte auf Typewriter + etwas Extra-Zeit
	await get_tree().create_timer(8.0).timeout
	
	# Entferne Event Echo und gehe zum Ending
	if event_echo:
		event_echo.queue_free()
	AudioServer.set_bus_mute(
	AudioServer.get_bus_index("Music"),
		false
	)
	AudioServer.set_bus_mute(
	AudioServer.get_bus_index("SFX"),
		false
	)
	go_to_ending()

func go_to_ending() -> void:
	print("🎬 Wechsle zu Ending Scene")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if ending_scene:
		Transition.change_scene("res://scenes/ending.tscn", 1.0)
	else:
		push_error("❌ Ending Scene PackedScene fehlt!")


# -------------------------
# Display
# -------------------------
func update_display() -> void:
	if is_instance_valid(keypad_ui):
		keypad_ui.set_code(current_input)
	if not display_label:
		return
	
	if current_input.is_empty():
		display_label.text = "----"
	else:
		# Zeige Sternchen für eingegebene Ziffern
		var masked = ""
		for i in current_input.length():
			masked += "*"
		
		# Fülle Rest mit Strichen auf
		while masked.length() < correct_code.length():
			masked += "-"
		
		display_label.text = masked

# -------------------------
# Audio
# -------------------------
func play_beep() -> void:
	if audio_beep:
		audio_beep.play()

func play_success() -> void:
	if audio_success:
		audio_success.play()

func play_error() -> void:
	if audio_error:
		audio_error.play()

# -------------------------
# Interaction
# -------------------------
func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player = body as CharacterBody3D

func _on_body_exited(body: Node3D) -> void:
	if body == player and is_active and not can_interact():
		deactivate()

func interact() -> void:
	activate()

func activate() -> void:
	if is_active or is_processing or not can_interact() or Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	if Transition.is_transitioning:
		return
	_session += 1
	is_active = true
	current_input = ""
	keypad_ui.open_ui(correct_code.length())
	update_display()
	display_label.modulate = Color(0.5, 1.0, 0.5)

func deactivate() -> void:
	_session += 1
	is_active = false
	if not _accepted:
		is_processing = false
		current_input = ""
		update_display()
		display_label.modulate = Color.WHITE
	keypad_ui.close_ui()
