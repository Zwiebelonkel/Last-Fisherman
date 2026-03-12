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

	_original_cam = get_viewport().get_camera_3d()

	# Cinematic Camera erstellen
	_cinematic_cam = Camera3D.new()
	get_tree().root.add_child(_cinematic_cam)
	_cinematic_cam.global_transform = _path_follow.global_transform
	_cinematic_cam.make_current()

	# Schwarzblende Overlay erstellen
	_overlay = CanvasLayer.new()
	_overlay.layer = 200  # Über allem
	get_tree().root.add_child(_overlay)

	_fade_rect = ColorRect.new()
	_fade_rect.anchors_preset = Control.PRESET_FULL_RECT
	_fade_rect.color = Color(0, 0, 0, 1.0)  # Start: schwarz
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP  # Blockiert Klicks
	_overlay.add_child(_fade_rect)

	_path_follow.progress_ratio = 0.0
	_elapsed = 0.0
	_active = true

	# Input blockieren
	_set_input_blocked(true)

	# Einblenden
	var tween = create_tween()
	tween.tween_property(_fade_rect, "color:a", 0.0, fade_duration)


func _process(delta: float) -> void:
	if not _active or _done:
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
	# FishingRod pausieren/fortsetzen
	var scene = get_tree().current_scene
	if not scene:
		return

	var player_cam = scene.get_node_or_null("PlayerCamera")
	if not player_cam:
		return

	var fishing = player_cam.get_node_or_null("FishingRod")
	if fishing:
		fishing.set_process(not blocked)
		fishing.set_physics_process(not blocked)
		fishing.set_process_input(not blocked)
		fishing.set_process_unhandled_input(not blocked)

	# camera_sway pausieren
	if player_cam.get_script() != null:
		player_cam.set_process(not blocked)
