extends StaticBody3D
class_name StationDrinks

signal item_dispensed(item_type: String)

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var outline_mesh: MeshInstance3D = $OutlineMesh
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var interaction_prompt: Label3D = $InteractionPrompt

var tray: Tray
var controller: Node

var original_material: StandardMaterial3D

# ===============================
#  READY
# ===============================
func _ready() -> void:
	setup_materials()
	if interaction_prompt:
		interaction_prompt.visible = false

# ===============================
#  MATERIALS
# ===============================
func setup_materials() -> void:
	if not mesh:
		return

	if mesh.get_surface_override_material_count() > 0:
		original_material = mesh.get_surface_override_material(0)

	if not original_material:
		original_material = StandardMaterial3D.new()
		original_material.albedo_color = Color.CYAN
		mesh.set_surface_override_material(0, original_material)

# ===============================
#  SETTERS
# ===============================
func set_tray(tray_ref: Tray) -> void:
	tray = tray_ref

func set_controller(controller_ref: Node) -> void:
	controller = controller_ref

func set_hover(hover: bool) -> void:
	if outline_mesh:
		outline_mesh.visible = hover

	if interaction_prompt:
		interaction_prompt.visible = hover

# ===============================
#  INTERACTION
# ===============================
func interact() -> void:
	if not controller or not controller.current_customer:
		print("Kein aktiver Kunde!")
		return

	var order = controller.current_customer.order

	if not order.wants_drink:
		print("Kunde hat kein Getränk bestellt!")
		return

	# Prüfe ob Getränk schon auf dem Tablett ist
	for item in tray.get_items():
		if item.is_drink:
			print("Getränk bereits auf dem Tablett!")
			return

	if tray.add_drink():
		flash_effect()
		item_dispensed.emit("Drink")

# ===============================
#  VISUAL FX
# ===============================
func flash_effect() -> void:
	if not mesh:
		return

	var flash_material := StandardMaterial3D.new()
	flash_material.albedo_color = Color.WHITE
	flash_material.emission_enabled = true
	flash_material.emission = Color.WHITE
	flash_material.emission_energy = 3.0

	mesh.set_surface_override_material(0, flash_material)

	await get_tree().create_timer(0.2).timeout

	if mesh:
		mesh.set_surface_override_material(0, original_material)
