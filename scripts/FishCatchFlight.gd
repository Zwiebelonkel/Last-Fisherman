extends Node3D
## Pull a solid, spinning fish out of the water and into the player's view.

signal finished

const FishVisual := preload("res://scripts/FishVisual3D.gd")
const DURATION: float = 1.05
const LensSplash := preload("res://scripts/CatchLensSplash.gd")

var fish_mesh: FishVisual
var _camera: Camera3D
var _start: Vector3
var _body_scale: float
var _catch_ui: Control


func play(fish: Dictionary, water_position: Vector3, view_camera: Camera3D, catch_ui: Control = null) -> void:
	_camera = view_camera
	_catch_ui = catch_ui
	_start = water_position
	fish_mesh = FishVisual.new()
	add_child(fish_mesh)
	fish_mesh.set_texture(FishDB.get_fish_icon(fish), bool(fish.get("is_shiny", false)))
	var rarity := FishDB.get_rarity_safe(fish)
	_body_scale = 0.42 + 0.025 * clampi(rarity, 0, 6)
	# This flight begins in the successful 100% catch callback: splash the lens
	# immediately as the fish leaves the water, before its first animation frame.
	var scene := get_tree().current_scene
	var splash := scene.get_node_or_null("CatchLensSplash") as LensSplash
	if splash == null:
		splash = LensSplash.new()
		scene.add_child(splash)
	splash.play()
	_advance(0.0)
	var tween := create_tween()
	tween.tween_method(_advance, 0.0, 1.0, DURATION)
	tween.tween_callback(_finish)


func _advance(progress: float) -> void:
	if not is_instance_valid(_camera):
		return
	# The end follows the actual camera, including sway and all four directions.
	var view_basis := _camera.global_basis.orthonormalized()
	var end := _camera.global_position + view_basis * Vector3(0.0, -0.08, -1.65)
	var landing_scale := Vector3.ONE * _body_scale
	if is_instance_valid(_catch_ui):
		# Project the actual laid-out icon into world space. This follows window
		# resizing, translated card heights, camera sway, and transparent icon margins.
		var rect: Rect2 = _catch_ui.get_flight_icon_rect(fish_mesh.texture_region)
		var depth: float = maxf(1.65, _camera.near + 0.5)
		var top_left := _camera.project_position(rect.position, depth)
		var bounds := fish_mesh.mesh.get_aabb().size
		landing_scale.x = top_left.distance_to(_camera.project_position(Vector2(rect.end.x, rect.position.y), depth)) / maxf(bounds.x, 0.001)
		landing_scale.y = top_left.distance_to(_camera.project_position(Vector2(rect.position.x, rect.end.y), depth)) / maxf(bounds.y, 0.001)
		landing_scale.z = minf(landing_scale.x, landing_scale.y)
		# Align the front face, rather than the center of the extruded body.
		end = _camera.project_position(rect.get_center(), depth) - view_basis.z * bounds.z * landing_scale.z * 0.5
	var distance := _start.distance_to(end)
	var lift := clampf(distance * 0.22, 1.0, 2.4)
	var first := _start + Vector3.UP * lift
	var second := end - view_basis.z * minf(distance * 0.3, 2.5) + Vector3.UP * lift * 0.65
	var t := smoothstep(0.0, 1.0, progress)
	global_position = _start.bezier_interpolate(first, second, end, t)
	# Real rotation reveals the colored side walls and back of the shared mesh.
	global_basis = view_basis
	fish_mesh.rotation = Vector3(
		deg_to_rad(-18.0) * sin(PI * progress),
		TAU * progress + deg_to_rad(-24.0) * (1.0 - progress),
		deg_to_rad(24.0) * sin(TAU * progress)
	)
	fish_mesh.scale = (Vector3.ONE * _body_scale).lerp(landing_scale, smoothstep(0.45, 1.0, progress))


func _finish() -> void:
	finished.emit()
	queue_free()
