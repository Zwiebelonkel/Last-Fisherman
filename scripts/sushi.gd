extends StaticBody3D
class_name StationSushi

signal cooking_started(fish_type: String)
signal cooking_finished(fish_type: String)
signal item_collected()

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var outline_mesh: MeshInstance3D = $OutlineMesh
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var timer_label: Label3D = $TimerLabel3D
@onready var interaction_prompt: Label3D = $InteractionPrompt

var cooking_time := 3.0
var current_cooking_time := 0.0
var current_fish_type := ""

enum State { IDLE, WAITING_FOR_FISH, COOKING, READY }
var current_state := State.IDLE

var tray: Tray
var controller: Node
var fish_selection_ui: Control

var original_material: StandardMaterial3D
var cooking_material: StandardMaterial3D

# ===============================
#  READY / PROCESS
# ===============================
func _ready() -> void:
	setup_materials()
	if timer_label:
		timer_label.visible = false
	update_prompt()

func _process(delta: float) -> void:
	if current_state == State.COOKING:
		current_cooking_time += delta

		if timer_label:
			var remaining := cooking_time - current_cooking_time
			timer_label.text = "%.1fs" % max(0.0, remaining)

		if current_cooking_time >= cooking_time:
			finish_cooking()

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
		original_material.albedo_color = Color(0.8, 0.8, 0.8)
		mesh.set_surface_override_material(0, original_material)

	cooking_material = StandardMaterial3D.new()
	cooking_material.albedo_color = Color(0.4, 0.8, 0.4)
	cooking_material.emission_enabled = true
	cooking_material.emission = Color(0.4, 0.8, 0.4)
	cooking_material.emission_energy = 1.5

# ===============================
#  SETTERS
# ===============================
func set_tray(tray_ref: Tray) -> void:
	tray = tray_ref

func set_controller(controller_ref: Node) -> void:
	controller = controller_ref

func set_fish_selection_ui(ui: Control) -> void:
	fish_selection_ui = ui
	if fish_selection_ui:
		fish_selection_ui.fish_selected.connect(_on_fish_selected)
		fish_selection_ui.cancelled.connect(_on_selection_cancelled)
		
func _on_selection_cancelled() -> void:
	if current_state == State.WAITING_FOR_FISH:
		current_state = State.IDLE
		update_prompt()

func set_hover(hovering: bool) -> void:
	if outline_mesh and current_state == State.IDLE:
		outline_mesh.visible = hovering

# ===============================
#  INTERACTION
# ===============================
func interact() -> void:
	print("interact")
	match current_state:
		State.IDLE:
			open_fish_selection()
		State.COOKING:
			print(tr("SUSHI_STILL_COOKING"))
		State.READY:
			collect_item()

func open_fish_selection() -> void:
	if not fish_selection_ui or not controller:
		return

	if controller.get_available_fish_types().is_empty():
		print(tr("SUSHI_NO_FISH_INVENTORY"))
		return

	fish_selection_ui.show_fish_selection(
		controller.get_available_fish_dicts(),
		tr("PREP_TYPE_SUSHI")
	)

	current_state = State.WAITING_FOR_FISH

# ===============================
#  FLOW
# ===============================
func _on_fish_selected(fish_name: String) -> void:
	if current_state != State.WAITING_FOR_FISH:
		return

	if not controller or not controller.current_customer:
		current_state = State.IDLE
		update_prompt()
		return

	var order = controller.current_customer.order

	# ✅ FIXED: Prüfe gegen "Sushi" statt tr("PREP_TYPE_SUSHI")
	if order.preparation_type != "Sushi":
		print(tr("SUSHI_CUSTOMER_NO_WANT"))
		current_state = State.IDLE
		update_prompt()
		return

	# Inventory check remains
	if not controller.has_fish_in_inventory(fish_name):
		print(tr("SUSHI_FISH_NOT_IN_INVENTORY"))
		current_state = State.IDLE
		update_prompt()
		return

	# ALWAYS cook - even wrong fish
	start_cooking(fish_name)

func start_cooking(fish_type: String) -> void:
	current_fish_type = fish_type
	current_cooking_time = 0.0
	current_state = State.COOKING

	if mesh:
		mesh.set_surface_override_material(0, cooking_material)
	if timer_label:
		timer_label.visible = true
	if outline_mesh:
		outline_mesh.visible = false

	update_prompt()
	cooking_started.emit(fish_type)

func finish_cooking() -> void:
	current_state = State.READY

	if mesh:
		mesh.set_surface_override_material(0, original_material)
	if timer_label:
		timer_label.visible = false

	update_prompt()
	cooking_finished.emit(current_fish_type)

func collect_item() -> void:
	if not tray:
		return

	# ✅ FIXED: Nutze "Sushi" statt tr("PREP_TYPE_SUSHI")
	if tray.add_item(current_fish_type, "Sushi"):
		current_state = State.IDLE
		current_fish_type = ""
		update_prompt()
		item_collected.emit()

# ===============================
#  UI PROMPT
# ===============================
func update_prompt() -> void:
	if not interaction_prompt:
		return

	match current_state:
		State.IDLE:
			interaction_prompt.text = tr("SUSHI_PROMPT_IDLE")
			interaction_prompt.visible = true
		State.COOKING:
			interaction_prompt.text = tr("SUSHI_PROMPT_COOKING")
			interaction_prompt.visible = true
		State.READY:
			interaction_prompt.text = tr("SUSHI_PROMPT_READY")
			interaction_prompt.visible = true
		_:
			interaction_prompt.visible = false
