extends Node

# ===========================
#  FREECAM CHEAT - F3 Toggle
#  DEBUG MODE   - F2 Toggle
# ===========================

var active: bool = false
var cam: Camera3D = null
var original_cam: Camera3D = null
var move_speed: float = 10.0
var fast_speed: float = 40.0
var sensitivity: float = 0.003

var yaw: float = 0.0
var pitch: float = 0.0

# --- DEBUG ---
var debug_active: bool = false
var debug_overlay: CanvasLayer = null
var debug_label: Label = null


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_F2 and event.pressed:
		if debug_active: _disable_debug()
		else: _enable_debug()
		get_viewport().set_input_as_handled()
		return

	if event is InputEventKey and event.keycode == KEY_F3 and event.pressed:
		if active: _disable()
		else: _enable()
		get_viewport().set_input_as_handled()
		return

	if not active:
		return

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		yaw -= event.relative.x * sensitivity
		pitch -= event.relative.y * sensitivity
		pitch = clamp(pitch, deg_to_rad(-89), deg_to_rad(89))
		var q = Quaternion(Vector3.UP, yaw) * Quaternion(Vector3.RIGHT, pitch)
		cam.global_transform.basis = Basis(q)
		get_viewport().set_input_as_handled()
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	if active and cam:
		var speed = fast_speed if Input.is_key_pressed(KEY_SHIFT) else move_speed
		var dir := Vector3.ZERO
		if Input.is_key_pressed(KEY_W): dir -= cam.global_transform.basis.z
		if Input.is_key_pressed(KEY_S): dir += cam.global_transform.basis.z
		if Input.is_key_pressed(KEY_A): dir -= cam.global_transform.basis.x
		if Input.is_key_pressed(KEY_D): dir += cam.global_transform.basis.x
		if Input.is_key_pressed(KEY_E): dir += Vector3.UP
		if Input.is_key_pressed(KEY_Q): dir -= Vector3.UP
		if dir.length() > 0:
			cam.global_position += dir.normalized() * speed * delta

	if debug_active and debug_label:
		_update_debug_label()


# ===========================
#  DEBUG SYSTEM
# ===========================

func _enable_debug() -> void:
	debug_overlay = CanvasLayer.new()
	debug_overlay.layer = 127
	get_tree().current_scene.add_child(debug_overlay)

	var panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	panel.position = Vector2(8, 8)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.75)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", style)
	debug_overlay.add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	panel.add_child(vbox)

	var title = Label.new()
	title.text = "[ DEBUG — F2 schließen ]"
	title.add_theme_color_override("font_color", Color(1, 0.8, 0.1))
	title.add_theme_font_size_override("font_size", 13)
	vbox.add_child(title)
	vbox.add_child(HSeparator.new())

	debug_label = Label.new()
	debug_label.add_theme_font_size_override("font_size", 12)
	debug_label.add_theme_color_override("font_color", Color(0.85, 1.0, 0.85))
	vbox.add_child(debug_label)

	debug_active = true
	print("🐛 Debug Mode AKTIV — F2 = aus")


func _disable_debug() -> void:
	if debug_overlay:
		debug_overlay.queue_free()
		debug_overlay = null
		debug_label = null
	debug_active = false
	print("🐛 Debug Mode DEAKTIVIERT")


func _update_debug_label() -> void:
	var current_cam = get_viewport().get_camera_3d()
	var cam_pos = Vector3.ZERO
	var cam_rot_deg = Vector3.ZERO
	var cam_fwd = Vector3.ZERO
	if current_cam:
		cam_pos = current_cam.global_position
		cam_rot_deg = current_cam.global_rotation_degrees
		cam_fwd = -current_cam.global_transform.basis.z

	var fishing = _get_fishing_script()
	var fish_state = "N/A"
	if fishing:
		var s = fishing.get("state")
		if s != null:
			fish_state = str(s)

	var scene = get_tree().current_scene
	var node_count = 0
	if scene:
		node_count = _count_nodes(scene)

	var freecam_line = ""
	if active:
		freecam_line = "\nFreeCam yaw: %.1f°  pitch: %.1f°" % [rad_to_deg(yaw), rad_to_deg(pitch)]

	debug_label.text = (
		"FPS:        %d  (%.1f ms)\n" % [Engine.get_frames_per_second(), 1000.0 / maxf(Engine.get_frames_per_second(), 1)] +
		"Cam Pos:    x=%.2f  y=%.2f  z=%.2f\n" % [cam_pos.x, cam_pos.y, cam_pos.z] +
		"Cam Rot:    x=%.1f°  y=%.1f°  z=%.1f°\n" % [cam_rot_deg.x, cam_rot_deg.y, cam_rot_deg.z] +
		"Cam Fwd:    x=%.2f  y=%.2f  z=%.2f\n" % [cam_fwd.x, cam_fwd.y, cam_fwd.z] +
		"Nodes:      %d\n" % node_count +
		"FreeCam:    %s%s\n" % [("AN" if active else "AUS"), freecam_line] +
		"Fish State: %s\n" % fish_state +
		"Money:      %d\n" % Player.get_money() +
		"Time Scale: %.2f" % Engine.time_scale
	)


func _count_nodes(node: Node) -> int:
	if not is_instance_valid(node):
		return 0
	var count = 1
	for child in node.get_children():
		count += _count_nodes(child)
	return count


# ===========================
#  FREECAM SYSTEM
# ===========================

func _get_fishing_script() -> Node:
	var scene = get_tree().current_scene
	if not scene: return null
	var player_cam = scene.get_node_or_null("PlayerCamera")
	if not player_cam: return null
	return player_cam.get_node_or_null("FishingRod")


func _enable() -> void:
	original_cam = get_viewport().get_camera_3d()
	if not original_cam:
		push_warning("FreeCam: Keine Camera3D gefunden!")
		return

	# Yaw/Pitch aus World-Space Forward-Vektor
	# WICHTIG: fwd zeigt wohin die Camera schaut (world space, unabhängig von Scene-Transform)
	var fwd = -original_cam.global_transform.basis.z
	# atan2(x, z) gibt den Winkel in der XZ-Ebene — aber wir wollen von -Z aus messen
	# Wenn fwd = (0,0,1)  → Camera schaut in +Z → yaw sollte 180° sein
	# Wenn fwd = (0,0,-1) → Camera schaut in -Z → yaw sollte 0° sein
	yaw = atan2(fwd.x, -fwd.z)   # negiertes z: 0° = schaut in -Z (Godot Camera default)
	pitch = -asin(clamp(fwd.y, -1.0, 1.0))

	# FreeCam erstellen, in Tree einfügen, DANN global_transform setzen
	cam = Camera3D.new()
	# An get_tree().root hängen, nicht an current_scene!
	# current_scene kann selbst eine Rotation haben (z.B. Transform3D(-1,0,0,...))
	# die dann global_transform.basis beeinflusst.
	get_tree().root.add_child(cam)
	var q = Quaternion(Vector3.UP, yaw) * Quaternion(Vector3.RIGHT, pitch)
	cam.global_transform = Transform3D(Basis(q), original_cam.global_position)
	cam.make_current()

	print("🎥 FreeCam init:")
	print("  global fwd: ", fwd)
	print("  yaw: %.1f°  pitch: %.1f°" % [rad_to_deg(yaw), rad_to_deg(pitch)])

	# FishingRod Script pausieren
	var fishing = _get_fishing_script()
	if fishing:
		fishing.set_process(false)
		fishing.set_physics_process(false)
		fishing.set_process_input(false)
		fishing.set_process_unhandled_input(false)
		print("🎥 FishingRod pausiert: ", fishing.name)
	else:
		print("🎥 WARNUNG: FishingRod nicht gefunden!")

	# camera_sway auf der Camera pausieren
	if original_cam.get_script() != null:
		original_cam.set_process(false)
		original_cam.set_physics_process(false)
		print("🎥 camera_sway pausiert")

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	active = true
	print("🎥 FreeCam AKTIV — WASD, E/Q hoch/runter, Shift schnell, RMB Maus toggle, F3 aus")


func _disable() -> void:
	var fishing = _get_fishing_script()
	if fishing:
		fishing.set_process(true)
		fishing.set_physics_process(true)
		fishing.set_process_input(true)
		fishing.set_process_unhandled_input(true)

	if original_cam and is_instance_valid(original_cam) and original_cam.get_script() != null:
		original_cam.set_process(true)
		original_cam.set_physics_process(true)

	if cam:
		if original_cam and is_instance_valid(original_cam):
			original_cam.make_current()
		cam.queue_free()
		cam = null

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	active = false
	print("🎥 FreeCam DEAKTIVIERT")
