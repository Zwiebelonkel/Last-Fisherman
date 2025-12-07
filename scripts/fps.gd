extends CharacterBody3D

# ========================================
# MOVEMENT SETTINGS
# ========================================
@export_group("Movement")
@export var walk_speed := 5.0
@export var jump_velocity := 4.5
@export var acceleration := 10.0
@export var deceleration := 12.0
@export var air_control := 0.3

# ========================================
# CAMERA SETTINGS
# ========================================
@export_group("Camera")
@export var mouse_sensitivity := 0.003
@export var camera_fov := 75.0
@export var head_bob_enabled := true
@export var head_bob_speed := 14.0
@export var head_bob_intensity := 0.05

# ========================================
# 🆕 UI REFERENCES
# ========================================
@export_group("UI")
@export var fishbook_ui: Control
@export var options: Control
@export var inventory_ui: Control
@export var journal_button: Button
@export var inventory_button: Button
@export var map_button: Button
@export var settings_button: Button

# 🆕 Close Buttons (manuell zuweisen im Inspector)
@export_group("Close Buttons")
@export var fishbook_close_button: Button
@export var inventory_close_button: Button
@export var options_close_button: Button

# ========================================
# NODE REFERENCES
# ========================================
@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var collision_shape = $CollisionShape3D

# ========================================
# INTERNAL VARIABLES
# ========================================
var head_bob_time := 0.0
var original_camera_y := 0.0
var paused := false

# Gravity
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	# Maus einfangen
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Kamera Setup
	if camera:
		camera.fov = camera_fov
		original_camera_y = camera.position.y
	
	# Button-Signals verbinden
	setup_buttons()
	
	print("🎮 FPS Player bereit!")

# Button Setup
func setup_buttons() -> void:
	if journal_button:
		journal_button.pressed.connect(toggle_fishbook)
	
	if inventory_button:
		inventory_button.pressed.connect(toggle_inventory)
	
	if map_button:
		map_button.pressed.connect(open_map)
	
	if settings_button:
		settings_button.pressed.connect(handle_pause_input)
	
	# 🆕 Close Buttons verbinden
	if fishbook_close_button:
		fishbook_close_button.pressed.connect(close_fishbook)
		print("✅ Fishbook Close Button verbunden")
	
	if inventory_close_button:
		inventory_close_button.pressed.connect(close_inventory)
		print("✅ Inventory Close Button verbunden")
	
	if options_close_button:
		options_close_button.pressed.connect(close_options)
		print("✅ Options Close Button verbunden")

func _input(event: InputEvent) -> void:
	# ESC/Pause behandeln - IMMER als erstes prüfen
	if event.is_action_released("pause"):
		handle_pause_input()
		return
	
	# Während Pause keine anderen Inputs verarbeiten
	if paused:
		return
	
	if event.is_action_pressed("journal"):
		toggle_fishbook()
		return
	
	if event.is_action_pressed("inventory_toggle"):
		toggle_inventory()
		return
	
	# 🆕 Map öffnen
	if event.is_action_pressed("map_open"):
		open_map()
		return
	
	# Maus-Look (nur wenn keine Menüs offen)
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if not (fishbook_ui and fishbook_ui.visible) and not (inventory_ui and inventory_ui.visible):
			rotate_y(-event.relative.x * mouse_sensitivity)
			head.rotate_x(-event.relative.y * mouse_sensitivity)
			head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _physics_process(delta):
	# Keine Bewegung während Pause oder wenn Menüs offen sind
	if paused or (fishbook_ui and fishbook_ui.visible) or (inventory_ui and inventory_ui.visible):
		return
	
	handle_gravity(delta)
	handle_movement(delta)
	handle_head_bob(delta)
	
	move_and_slide()

# ---------------------------------------------------------
# MENÜ-MANAGEMENT SYSTEM (aus Fishing Script)
# ---------------------------------------------------------
func handle_pause_input() -> void:
	# Prüfe welche Menüs offen sind (Priorität: Fishbook > Inventory > Options)
	
	# 1. Wenn Fishbook offen ist, schließe es
	if fishbook_ui and fishbook_ui.visible:
		close_fishbook()
		return
	
	# 2. Wenn Inventory offen ist, schließe es
	if inventory_ui and inventory_ui.visible:
		close_inventory()
		return
	
	# 3. Wenn Options offen ist, schließe es
	if options and options.visible:
		close_options()
		return
	
	# 4. Wenn alle zu sind, öffne Options
	open_options()


func toggle_fishbook() -> void:
	if not fishbook_ui:
		return
		
	if fishbook_ui.visible:
		close_fishbook()
	else:
		open_fishbook()


func toggle_inventory() -> void:
	if not inventory_ui:
		return
		
	if inventory_ui.visible:
		close_inventory()
	else:
		open_inventory()


func open_fishbook() -> void:
	if not fishbook_ui:
		return
	
	# Schließe alle anderen Menüs
	if inventory_ui:
		close_inventory()
	if options:
		close_options()
	
	fishbook_ui.visible = true
	paused = false
	Engine.time_scale = 1
	
	# Maus freigeben für UI
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func close_fishbook() -> void:
	if not fishbook_ui:
		return
		
	fishbook_ui.visible = false
	paused = false
	Engine.time_scale = 1
	
	# Maus wieder einfangen
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func open_inventory() -> void:
	if not inventory_ui:
		return
	
	# Schließe alle anderen Menüs
	if fishbook_ui:
		close_fishbook()
	if options:
		close_options()
	
	inventory_ui.show()
	paused = false
	Engine.time_scale = 1
	
	# Maus freigeben für UI
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func close_inventory() -> void:
	if not inventory_ui:
		return
		
	inventory_ui.hide()
	paused = false
	Engine.time_scale = 1
	
	# Maus wieder einfangen
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func open_options() -> void:
	if not options:
		return
	
	# Schließe alle anderen Menüs
	if fishbook_ui:
		close_fishbook()
	if inventory_ui:
		close_inventory()
	
	options.show()
	paused = true
	Engine.time_scale = 0
	
	# Maus freigeben für Options-Menü
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func close_options() -> void:
	if not options:
		return
		
	options.hide()
	paused = false
	Engine.time_scale = 1
	
	# Maus wieder einfangen
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# 🆕 Map öffnen
func open_map() -> void:
	# Maus freigeben VOR dem Szenenwechsel
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Speichere aktuelle Szene falls du GameData nutzt
	# GameData.update_last_scene(get_tree().current_scene.scene_file_path)
	
	# Wechsle zur Map-Szene
	Transition.change_scene("res://scenes/MapScene.tscn")


# ========================================
# GRAVITY
# ========================================
func handle_gravity(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

# ========================================
# MOVEMENT
# ========================================
func handle_movement(delta):
	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
	
	# Input Direction
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Bewegung mit Acceleration
	if is_on_floor():
		if direction:
			velocity.x = lerp(velocity.x, direction.x * walk_speed, acceleration * delta)
			velocity.z = lerp(velocity.z, direction.z * walk_speed, acceleration * delta)
		else:
			velocity.x = lerp(velocity.x, 0.0, deceleration * delta)
			velocity.z = lerp(velocity.z, 0.0, deceleration * delta)
	else:
		# Luftkontrolle
		if direction:
			velocity.x = lerp(velocity.x, direction.x * walk_speed, air_control * delta)
			velocity.z = lerp(velocity.z, direction.z * walk_speed, air_control * delta)

# ========================================
# HEAD BOB
# ========================================
func handle_head_bob(delta):
	if not head_bob_enabled or not camera:
		return
	
	# Nur Head Bob wenn auf Boden und bewegt
	if is_on_floor() and velocity.length() > 0.1:
		head_bob_time += delta * head_bob_speed * (velocity.length() / walk_speed)
		
		var bob_offset_y = sin(head_bob_time) * head_bob_intensity
		var bob_offset_x = cos(head_bob_time * 0.5) * head_bob_intensity * 0.5
		
		camera.position.y = original_camera_y + bob_offset_y
		camera.position.x = bob_offset_x
	else:
		# Zurück zur Normalposition
		head_bob_time = 0.0
		camera.position.y = lerp(camera.position.y, original_camera_y, delta * 10.0)
		camera.position.x = lerp(camera.position.x, 0.0, delta * 10.0)

# ========================================
# HELPER FUNCTIONS
# ========================================
func is_moving() -> bool:
	return velocity.length() > 0.1
