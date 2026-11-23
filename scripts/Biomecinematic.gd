extends Node

# ===========================
#  BIOME CINEMATIC INTRO
# ===========================
# Setup in jeder Biome-Scene:
#
# 1. Path3D Node erstellen (Name: "CinematicPath")
# 2. PathFollow3D als Kind von Path3D (Name: "PathFollow")
# 3. Dieses Script an einen Node in der Scene hängen (z.B. FishingRod oder ein eigener Node)
# 4. Exports im Inspector setzen
#
# Scene-Struktur:
#   CinematicPath (Path3D)
#     └── PathFollow (PathFollow3D)
# ===========================

@export var fishing_location: String = ""         # z.B. "desert", "lake"
@export var cinematic_path: Path3D = null         # Referenz auf CinematicPath
@export var duration: float = 6.0                 # Länge der Fahrt in Sekunden
@export var fade_duration: float = 0.8            # Schwarzblende rein/raus
# Intern
var _path_follow: PathFollow3D = null
var _cinematic_cam: Camera3D = null
var _overlay: CanvasLayer = null
var _fade_rect: ColorRect = null
var _original_cam: Camera3D = null
var _look_target: Node3D = null  # Worauf die Camera schaut (PlayerCamera)
var _elapsed: float = 0.0
var _active: bool = false
var _done: bool = false

var _blending: bool = false
var _blend_elapsed: float = 0.0
const BLEND_DURATION: float = 0.6  # Sekunden für den Übergang
var _blend_start_transform: Transform3D
var _fishing: Node
var _processing_before: Dictionary = {}
var _disabled_before: Dictionary = {}
var _camera_processing_before: bool = true


func _ready() -> void:
	# Kurz warten damit die Scene vollständig geladen ist
	await get_tree().process_frame
	await get_tree().process_frame

	if not cinematic_path:
		push_warning("BiomeCinematic: Kein cinematic_path gesetzt!")
		return

	if fishing_location == "":
		push_warning("BiomeCinematic: fishing_location nicht gesetzt!")
		return

	# Bereits besucht? → nichts tun
	if Player.has_visited_biome(fishing_location):
		return

	_start()


func _start() -> void:
	_path_follow = cinematic_path.get_node_or_null("PathFollow")
	if not _path_follow:
		push_warning("BiomeCinematic: Kein PathFollow3D als Kind von CinematicPath gefunden!")
		return

	# Prüfen ob der Pfad überhaupt Punkte hat
	if cinematic_path.curve == null or cinematic_path.curve.get_baked_length() < 0.01:
		push_warning("BiomeCinematic: CinematicPath hat keine Punkte! Bitte Pfad im Editor zeichnen.")
		return

	# PathFollow soll KEINE eigene Rotation machen — wir steuern das selbst
	_path_follow.rotation_mode = PathFollow3D.ROTATION_NONE

	# Look-Target finden: PlayerCamera in der Scene
	var scene = get_tree().current_scene
	_look_target = scene.get_node_or_null("PlayerCamera")
	if not _look_target:
		push_warning("BiomeCinematic: PlayerCamera nicht gefunden, Camera schaut in Fahrtrichtung.")

	# Always return to this location's camera, even after an interrupted intro.
	_original_cam = _look_target as Camera3D
	if _original_cam == null:
		return
	_fishing = _original_cam.get_node_or_null("FishingRod")

	# Cinematic Camera erstellen
	_cinematic_cam = Camera3D.new()
	_cinematic_cam.top_level = true
	_cinematic_cam.fov = _original_cam.fov
	_cinematic_cam.near = _original_cam.near
	_cinematic_cam.far = _original_cam.far
	add_child(_cinematic_cam)
	_cinematic_cam.global_transform = _path_follow.global_transform
	_cinematic_cam.make_current()

	# Schwarzblende Overlay erstellen
	_overlay = CanvasLayer.new()
	_overlay.layer = 200  # Über allem
	add_child(_overlay)

	_fade_rect = ColorRect.new()
	_fade_rect.anchors_preset = Control.PRESET_FULL_RECT
	_fade_rect.color = Color(0, 0, 0, 1.0)  # Start: schwarz
	# Gameplay buttons are disabled below; settings remain usable during the intro.
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.add_child(_fade_rect)

	_path_follow.progress_ratio = 0.0
	_elapsed = 0.0
	_active = true

	# Input blockieren
	_set_input_blocked(true)

	# Einblenden
	var tween = create_tween()
	tween.tween_property(_fade_rect, "color:a", 0.0, fade_duration)

func _input(event: InputEvent) -> void:
	if not _active or not event.is_action_released("pause"):
		return
	if is_instance_valid(_fishing):
		_fishing.handle_pause_input()
		get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	if not _active or _done or Engine.time_scale <= 0.0:
		return

	_elapsed += delta
	var t = clamp(_elapsed / duration, 0.0, 1.0)
	var smooth_t = smoothstep(0.0, 1.0, t)
	_path_follow.progress_ratio = smooth_t
	_cinematic_cam.global_position = _path_follow.global_position

	# Blend-Phase: sanft in PlayerCamera-Transform interpolieren
	if _blending:
		_blend_elapsed += delta
		var bt = clamp(_blend_elapsed / BLEND_DURATION, 0.0, 1.0)
		var smooth_bt = smoothstep(0.0, 1.0, bt)
		if _look_target and is_instance_valid(_look_target):
			_cinematic_cam.global_transform = _blend_start_transform.interpolate_with(
				_look_target.global_transform, smooth_bt
			)
		if bt >= 1.0 and not _done:
			_finish()
		return

	# Normale Phase: auf Look-Target schauen
	if _look_target and is_instance_valid(_look_target):
		var target_pos = _look_target.global_position
		target_pos.y += 1.0
		if _cinematic_cam.global_position.distance_to(target_pos) > 0.1:
			_cinematic_cam.look_at(target_pos, Vector3.UP)

	# Blend starten wenn fast am Ende
	if t >= 0.85 and not _blending:
		_blending = true
		_blend_elapsed = 0.0
		_blend_start_transform = _cinematic_cam.global_transform

func _finish() -> void:
	_done = true

	# Ausblenden
	var tween = create_tween()
	tween.tween_property(_fade_rect, "color:a", 1.0, fade_duration)
	await tween.finished

	# Original Camera wiederherstellen
	if _original_cam and is_instance_valid(_original_cam):
		_original_cam.make_current()

	# Einblenden
	var tween2 = create_tween()
	tween2.tween_property(_fade_rect, "color:a", 0.0, fade_duration)
	await tween2.finished

	# Cleanup
	_active = false
	if _cinematic_cam:
		_cinematic_cam.queue_free()
		_cinematic_cam = null
	if _overlay:
		_overlay.queue_free()
		_overlay = null

	# Input wieder freigeben
	_set_input_blocked(false)

	# Als besucht markieren
	Player.mark_biome_visited(fishing_location)

	print("🎬 Biome Cinematic abgeschlossen: ", fishing_location)


func _set_input_blocked(blocked: bool) -> void:
	if blocked:
		if is_instance_valid(_fishing):
			_processing_before = {
				"process": _fishing.is_processing(),
				"physics": _fishing.is_physics_processing(),
				"input": _fishing.is_processing_input(),
				"unhandled": _fishing.is_processing_unhandled_input(),
			}
			_fishing.set_process(false)
			_fishing.set_physics_process(false)
			_fishing.set_process_input(false)
			_fishing.set_process_unhandled_input(false)
			for property in ["journal_button", "inventory_button", "map_button", "left_button", "right_button", "interact_button"]:
				var button := _fishing.get(property) as BaseButton
				if button != null:
					_disabled_before[button] = button.disabled
					button.disabled = true
		if is_instance_valid(_original_cam):
			_camera_processing_before = _original_cam.is_processing()
			_original_cam.set_process(false)
	else:
		if is_instance_valid(_fishing) and not _processing_before.is_empty():
			_fishing.set_process(_processing_before.process)
			_fishing.set_physics_process(_processing_before.physics)
			_fishing.set_process_input(_processing_before.input)
			_fishing.set_process_unhandled_input(_processing_before.unhandled)
		for button in _disabled_before:
			if is_instance_valid(button):
				button.disabled = _disabled_before[button]
		if is_instance_valid(_original_cam):
			_original_cam.set_process(_camera_processing_before)
		_processing_before.clear()
		_disabled_before.clear()


func _exit_tree() -> void:
	if not _active:
		return
	_active = false
	_set_input_blocked(false)
	if is_instance_valid(_original_cam) and _original_cam.is_inside_tree():
		_original_cam.make_current()
	# Camera and overlay are children of this intro and leave with the location.
