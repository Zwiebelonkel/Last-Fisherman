extends Node3D
# StoryItem.gd
# Platziere dieses Script auf einem 3D-Objekt in jeder Map
# Hover + Linksklick zum Aufsammeln

class_name StoryItem

@export var item_id: String = "van"  # "van", "opensign", "friteuse", "sushimesser"
@export var highlight_color: Color = Color(1.0, 0.9, 0.3)
@export var rotation_speed: float = 1.0

@export var float_height: float = 0.2
@export var float_speed: float = 1.5

var is_hovering: bool = false
var glow_intensity: float = 0.8
var base_y: float = 0.0

var mesh_instances: Array[MeshInstance3D] = []
var area: Area3D = null


# =========================
# ITEM NAMEN
# =========================
const ITEM_NAMES = {
	"van": {
		"de": "Food Truck Karosserie",
		"en": "Food Truck Body"
	},
	"opensign": {
		"de": "Geöffnet-Schild",
		"en": "Open Sign"
	},
	"friteuse": {
		"de": "Fritteuse",
		"en": "Deep Fryer"
	},
	"sushimesser": {
		"de": "Sushi-Messer",
		"en": "Sushi Knife"
	}
}


# =========================
# READY
# =========================
func _ready() -> void:
	# Bereits gefunden?
	if Player.used_story_items.has(item_id):
		queue_free()
		return

	base_y = position.y

	# 🔍 Alle Meshes sammeln (auch tief verschachtelt)
	mesh_instances.clear()
	_find_meshes(self)

	if mesh_instances.is_empty():
		push_error("❌ StoryItem braucht mindestens eine MeshInstance3D!")
		return

	# 🖱️ Click / Hover Detection
	_setup_click_detection()

	add_to_group("story_items")
	print("✨ Story Item bereit:", item_id)


# =========================
# MESH FINDER (REKURSIV)
# =========================
func _find_meshes(node: Node) -> void:
	for child in node.get_children():
		if child is MeshInstance3D:
			mesh_instances.append(child)
		_find_meshes(child)


# =========================
# CLICK / HOVER SETUP
# =========================
func _setup_click_detection() -> void:
	var existing_area = find_child("Area3D", true, false)

	if existing_area:
		area = existing_area
	else:
		push_error("❌ Kein Area3D für Interaktion gefunden!")
		return

	area.input_ray_pickable = true
	area.input_event.connect(_on_area_input_event)
	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(_on_mouse_exited)

	print("✅ Click Detection aktiviert für:", item_id)


# =========================
# PROCESS
# =========================
func _process(delta: float) -> void:
	# Rotation
	if rotation_speed != 0.0:
		rotate_y(rotation_speed * delta)

	# Floating
	var time = Time.get_ticks_msec() / 1000.0
	position.y = base_y + sin(time * float_speed) * float_height

	# Glow Puls
	if is_hovering:
		glow_intensity = lerp(glow_intensity, 3.0, delta * 8.0)
	else:
		glow_intensity = lerp(glow_intensity, 0.8, delta * 5.0)

	_update_materials()


# =========================
# MATERIAL UPDATE (ALLE MESHES)
# =========================
func _update_materials() -> void:
	for mesh in mesh_instances:

		# 🔹 Originalmaterial sichern
		if not mesh.material_override:
			if mesh.get_active_material(0):
				mesh.material_override = mesh.get_active_material(0).duplicate()
			else:
				mesh.material_override = StandardMaterial3D.new()

		var mat := mesh.material_override as StandardMaterial3D
		if not mat:
			continue

		# 🔥 Emission nur beim Hover
		mat.emission_enabled = true
		mat.emission = highlight_color
		mat.emission_energy_multiplier = glow_intensity if is_hovering else 0.0

		# ✨ Rim optional
		if is_hovering:
			mat.rim_enabled = true
			mat.rim = 1.0
			mat.rim_tint = 0.7
		else:
			mat.rim_enabled = false


# =========================
# INTERACTION
# =========================
func interact() -> void:
	print("🎁 Story Item aufgesammelt:", item_id)

	if not Player.used_story_items.has(item_id):
		Player.used_story_items.append(item_id)
		Player.save_game()

	_show_collected_animation()
	Player.check_vendor_unlock()


# =========================
# COLLECT ANIMATION
# =========================
func _show_collected_animation() -> void:
	if area:
		area.input_ray_pickable = false

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector3.ONE * 1.8, 0.4)
	tween.tween_property(self, "position:y", position.y + 3.0, 0.6)

	await tween.finished

	# Fade alle Meshes aus
	for mesh in mesh_instances:
		if mesh.material_override:
			var mat := mesh.material_override as StandardMaterial3D
			if mat:
				mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				var fade := create_tween()
				fade.tween_property(mat, "albedo_color:a", 0.0, 0.3)

	await get_tree().create_timer(0.35).timeout
	queue_free()


# =========================
# MOUSE EVENTS
# =========================
func _on_mouse_entered() -> void:
	is_hovering = true
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	print("👆 Hover:", item_id)


func _on_mouse_exited() -> void:
	is_hovering = false
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)


func _on_area_input_event(
	_camera: Node,
	event: InputEvent,
	_position: Vector3,
	_normal: Vector3,
	_shape_idx: int
) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			print("🖱️ Click:", item_id)
			interact()


# =========================
# NAME HELPER
# =========================
func _get_item_name() -> String:
	var lang := Player.current_language
	if ITEM_NAMES.has(item_id) and ITEM_NAMES[item_id].has(lang):
		return ITEM_NAMES[item_id][lang]
	return item_id.capitalize()
