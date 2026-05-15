extends Node

@export var camera: Camera3D
@export var prompt_label: Label
@export var dman_area: Area3D
@export var sev_area: Area3D
@export var dman_url := "https://www.youtube.com/"
@export var sev_url := "https://www.youtube.com/"
@export var interaction_distance := 6.0
@export var visit_prompt_text := "E to visit"
@export var note_prompt_text := "E to read"

var current_url := ""
var current_note: Node = null

func _ready() -> void:
	if prompt_label:
		prompt_label.hide()

func _process(_delta: float) -> void:
	_update_target()

func _unhandled_input(event: InputEvent) -> void:
	if not _has_current_target():
		return

	if _is_e_interact_event(event):
		_interact_with_current_target()
		get_viewport().set_input_as_handled()

func _update_target() -> void:
	current_url = ""
	current_note = null

	if not camera:
		_set_prompt(false)
		return

	var space_state := camera.get_world_3d().direct_space_state
	var ray_origin := camera.global_position
	var ray_end := ray_origin + (-camera.global_transform.basis.z * interaction_distance)
	var query := PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.collide_with_areas = true
	query.collide_with_bodies = false

	var hit := space_state.intersect_ray(query)
	if hit.is_empty():
		_set_prompt(false)
		return

	var collider := hit.get("collider") as Node
	if collider == dman_area:
		current_url = dman_url
		_set_prompt(true, visit_prompt_text)
		return
	if collider == sev_area:
		current_url = sev_url
		_set_prompt(true, visit_prompt_text)
		return

	current_note = _find_note_from_collider(collider)
	if current_note and current_note.has_method("open_note"):
		_set_prompt(true, note_prompt_text)
		return

	_set_prompt(false)

func _interact_with_current_target() -> void:
	if current_url != "":
		OS.shell_open(current_url)
		return

	if current_note and current_note.has_method("interact"):
		current_note.interact()
	elif current_note and current_note.has_method("open_note"):
		current_note.open_note()

func _has_current_target() -> bool:
	return current_url != "" or current_note != null

func _is_e_interact_event(event: InputEvent) -> bool:
	var key_event := event as InputEventKey
	if not key_event:
		return false
	if not key_event.pressed or key_event.echo:
		return false
	return key_event.keycode == KEY_E or key_event.physical_keycode == KEY_E

func _find_note_from_collider(collider: Node) -> Node:
	var node := collider
	while node:
		if node.is_in_group("notes"):
			return node
		node = node.get_parent()
	return null

func _set_prompt(should_show: bool, prompt_text := "") -> void:
	if not prompt_label:
		return

	if prompt_text != "":
		prompt_label.text = prompt_text
	prompt_label.visible = should_show
