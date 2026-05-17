extends Node3D
class_name Keypad

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

# -------------------------
# Node References
# -------------------------
@onready var display_label: Label3D = $Display
@onready var audio_beep: AudioStreamPlayer3D = $AudioBeep
@onready var audio_success: AudioStreamPlayer3D = $AudioSuccess
@onready var audio_error: AudioStreamPlayer3D = $AudioError
@onready var interaction_area: Area3D = $InteractionArea


# -------------------------
# Ready
# -------------------------
func _ready() -> void:
	print("🔢 Keypad initialisiert - Code: ", correct_code)
	
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
	if not is_active or not player:
		return
	
	# Prüfe Distanz
	var distance = global_position.distance_to(player.global_position)
	if distance > interaction_distance:
		deactivate()
		return
	
	# Tasteneingabe
	if Input.is_action_just_pressed("ui_text_backspace"):
		remove_last_digit()
	elif Input.is_action_just_pressed("ui_accept"):
		check_code()
	else:
		# Zahlen 0-9
		for i in range(10):
			if Input.is_action_just_pressed("keypad_" + str(i)):
				add_digit(str(i))
				break

# -------------------------
# Digit Management
# -------------------------
func add_digit(digit: String) -> void:
	if current_input.length() >= correct_code.length():
		return
	
	current_input += digit
	update_display()
	play_beep()
	
	# Auto-Check wenn Code-Länge erreicht
	if current_input.length() == correct_code.length():
		await get_tree().create_timer(0.3).timeout
		check_code()

func remove_last_digit() -> void:
	if current_input.is_empty():
		return
	
	current_input = current_input.substr(0, current_input.length() - 1)
	update_display()
	play_beep()

# -------------------------
# Code Validation
# -------------------------
func check_code() -> void:
	if is_processing:
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
	
	print("🎉 SECRET CODE!")
	
	play_success()
	display_label.modulate = Color.MAGENTA
	
	is_active = false
	
	await get_tree().create_timer(1.0).timeout
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Transition.change_scene("res://scenes/rave.tscn", 1.0)

func on_correct_code() -> void:
	if is_processing:
		return
	
	is_processing = true  # 🔒 LOCK
	
	print("✅ CORRECT CODE!")
	
	play_success()
	display_label.modulate = Color.GREEN
	
	emit_signal("code_correct")
	
	is_active = false
	
	await get_tree().create_timer(1.0).timeout
	show_event_echo()

func on_incorrect_code() -> void:
	print("❌ FALSCHER CODE!")
	
	play_error()
	
	# Rote Anzeige kurz blinken
	display_label.modulate = Color.RED
	await get_tree().create_timer(0.5).timeout
	display_label.modulate = Color.WHITE
	
	# Reset Input
	current_input = ""
	update_display()
	
	emit_signal("code_incorrect")

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
		player = body
		activate()

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		deactivate()
		player = null

func activate() -> void:
	is_active = true
	print("🔢 Keypad aktiviert - Gib Code ein")
	
	# Optional: Zeige Hinweis-UI
	if display_label:
		display_label.modulate = Color(0.5, 1.0, 0.5)  # Grünlicher Schimmer

func deactivate() -> void:
	if not is_active:
		return
	
	is_active = false
	current_input = ""
	update_display()
	
	if display_label:
		display_label.modulate = Color.WHITE
	
	print("🔢 Keypad deaktiviert")
