extends StaticBody3D
class_name StationDrinks

signal item_dispensed(item_type: String)

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var outline_mesh: MeshInstance3D = $OutlineMesh
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var interaction_prompt: Label3D = $InteractionPrompt

var tray: Tray
var controller: Node
var minigame: Node = null

var original_material: StandardMaterial3D

enum State { IDLE, MINIGAME }
var current_state: State = State.IDLE

# Emoji-Mapping: Getränk-Name → Emoji für das Grid
const DRINK_EMOJIS: Dictionary = {
	"Cola":     "🥤",
	"Bier":     "🍺",
	"Saft":     "🧃",
	"Kaffee":   "☕",
	"Tee":      "🍵",
	"Wasser":   "💧",
	"Milch":    "🥛",
	"Limo":     "🍹",
}
const FALLBACK_EMOJI: String = "🥤"

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

func set_minigame(mg: Node) -> void:
	minigame = mg
	if minigame and minigame.has_signal("minigame_finished"):
		minigame.minigame_finished.connect(_on_minigame_finished)
		minigame.minigame_cancelled.connect(_on_minigame_cancelled)

func set_hover(hover: bool) -> void:
	if outline_mesh:
		outline_mesh.visible = hover
	if interaction_prompt:
		interaction_prompt.visible = hover
		if hover:
			interaction_prompt.text = tr("DRINKS_PROMPT_HOVER")

# ===============================
#  INTERACTION
# ===============================
func interact() -> void:
	if current_state == State.MINIGAME:
		return

	if not controller or not controller.current_customer:
		print(tr("DRINKS_NO_CUSTOMER"))
		return

	var order = controller.current_customer.order
	if not order.wants_drink:
		print(tr("DRINKS_NOT_ORDERED"))
		return

	for item in tray.get_items():
		if item.is_drink:
			print(tr("DRINKS_ALREADY_ON_TRAY"))
			return

	if minigame:
		var drink_name: String = order.drink_type if order.get("drink_type") else "Cola"
		var target_emoji = DRINK_EMOJIS.get(drink_name, FALLBACK_EMOJI)
		minigame.call("set_target", target_emoji)
		current_state = State.MINIGAME
		minigame.call("start")
	else:
		_dispense_drink()
# ===============================
#  MINIGAME CALLBACKS
# ===============================
func _on_minigame_finished(success: bool) -> void:
	current_state = State.IDLE
	if success:
		_dispense_drink()
	else:
		print(tr("DRINKS_MINI_FAILED"))
		# Optional: kleiner Penalty, z.B. Geduld des Kunden sinkt
		if controller and controller.current_customer:
			controller.current_customer.reduce_patience(15.0)

func _on_minigame_cancelled() -> void:
	current_state = State.IDLE

# ===============================
#  DISPENSE
# ===============================
func _dispense_drink() -> void:
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

	if is_instance_valid(mesh):
		mesh.set_surface_override_material(0, original_material)
