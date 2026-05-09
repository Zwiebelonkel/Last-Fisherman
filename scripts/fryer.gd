extends StaticBody3D
class_name StationFryer

signal cooking_started(fish_type: String)
signal cooking_finished(fish_type: String)
signal item_collected()

@onready var model_root: Node3D = $Fryer
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var timer_label: Label3D = $TimerLabel3D
@onready var interaction_prompt: Label3D = $InteractionPrompt
@onready var outline_mesh: MeshInstance3D = $OutlineMesh

var cooking_time: float = 8.0
var current_cooking_time: float = 0.0
var current_fish_type: String = ""
var is_hovering: bool = false

enum State { IDLE, WAITING_FOR_FISH, MINIGAME, COOKING, READY }
var current_state: State = State.IDLE

var tray: Tray = null
var controller: Node = null
var fish_selection_ui: Control = null
var minigame: Node = null   # Timing-Minigame

var original_materials: Dictionary = {}
var cooking_material: StandardMaterial3D

# Kochzeit-Multiplikator basierend auf Minigame-Ergebnis
var _quality_multiplier: float = 1.0  # perfect=0.5, good=0.75, burned=1.5

func _ready() -> void:
	setup_materials()
	if timer_label:
		timer_label.visible = false
	update_prompt()

func _process(delta: float) -> void:
	if current_state == State.COOKING:
		current_cooking_time += delta

		var effective_time = cooking_time * _quality_multiplier
		if timer_label:
			var remaining = effective_time - current_cooking_time
			timer_label.text = "%.1fs" % max(0, remaining)

		if current_cooking_time >= effective_time:
			finish_cooking()

# ===============================
#  MESH HELPERS
# ===============================
func get_all_meshes() -> Array[MeshInstance3D]:
	var meshes: Array[MeshInstance3D] = []
	if not model_root:
		return meshes
	find_meshes_recursive(model_root, meshes)
	return meshes

func find_meshes_recursive(node: Node, meshes: Array[MeshInstance3D]) -> void:
	if node is MeshInstance3D:
		meshes.append(node)
	for child in node.get_children():
		find_meshes_recursive(child, meshes)

func setup_materials() -> void:
	var meshes = get_all_meshes()
	for mesh in meshes:
		if mesh.get_surface_override_material_count() > 0:
			original_materials[mesh] = mesh.get_surface_override_material(0)
		else:
			var mat = StandardMaterial3D.new()
			mat.albedo_color = Color(0.8, 0.8, 0.8)
			mesh.set_surface_override_material(0, mat)
			original_materials[mesh] = mat

	cooking_material = StandardMaterial3D.new()
	cooking_material.albedo_color = Color.ORANGE
	cooking_material.emission_enabled = true
	cooking_material.emission = Color.ORANGE_RED
	cooking_material.emission_energy = 2.0

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

func set_minigame(mg: Node) -> void:
	minigame = mg
	if minigame and minigame.has_signal("minigame_finished"):
		minigame.minigame_finished.connect(_on_minigame_finished)
		minigame.minigame_cancelled.connect(_on_minigame_cancelled)

func _on_selection_cancelled() -> void:
	if current_state == State.WAITING_FOR_FISH:
		current_state = State.IDLE
		update_prompt()

func set_hover(hovering: bool) -> void:
	is_hovering = hovering
	if current_state == State.IDLE:
		outline_mesh.visible = hovering

# ===============================
#  INTERACTION
# ===============================
func interact() -> void:
	match current_state:
		State.IDLE:
			open_fish_selection()
		State.COOKING:
			print(tr("FRYER_STILL_COOKING"))
		State.READY:
			collect_item()

func open_fish_selection() -> void:
	if not fish_selection_ui or not controller:
		return

	var available_fish = controller.get_available_fish_types()
	if available_fish.size() == 0:
		print(tr("FRYER_NO_FISH_INVENTORY"))
		return

	fish_selection_ui.show_fish_selection(
		controller.get_available_fish_dicts(),
		tr("PREP_TYPE_FRIED_FISH")
	)
	current_state = State.WAITING_FOR_FISH

# ===============================
#  FISH SELECTED → MINIGAME
# ===============================
func _on_fish_selected(fish_name: String) -> void:
	if current_state != State.WAITING_FOR_FISH:
		return

	if not controller or not controller.current_customer:
		current_state = State.IDLE
		update_prompt()
		return

	var order = controller.current_customer.order

	if order.preparation_type != "Backfisch":
		print(tr("FRYER_CUSTOMER_NO_WANT"))
		current_state = State.IDLE
		update_prompt()
		return

	if not controller.has_fish_in_inventory(fish_name):
		print(tr("FRYER_FISH_NOT_IN_INVENTORY"))
		current_state = State.IDLE
		update_prompt()
		return

	current_fish_type = fish_name

	# Timing-Minigame starten
	if minigame:
		current_state = State.MINIGAME
		update_prompt()
		minigame.call("set_fish", current_fish_type)
		minigame.call("start")
	else:
		start_cooking(fish_name)

func _on_minigame_finished(quality: String) -> void:
	match quality:
		"perfect":
			_quality_multiplier = 0.5   # Halbierte Kochzeit
		"good":
			_quality_multiplier = 0.75
		"burned":
			_quality_multiplier = 1.5   # Längere Kochzeit
	start_cooking(current_fish_type)

func _on_minigame_cancelled() -> void:
	current_state = State.IDLE
	update_prompt()

# ===============================
#  COOKING FLOW
# ===============================
func start_cooking(fish_type: String) -> void:
	current_fish_type = fish_type
	current_cooking_time = 0.0
	current_state = State.COOKING

	var meshes = get_all_meshes()
	for mesh in meshes:
		mesh.set_surface_override_material(0, cooking_material)

	if timer_label:
		timer_label.visible = true
	outline_mesh.visible = false

	update_prompt()
	cooking_started.emit(fish_type)

func finish_cooking() -> void:
	current_state = State.READY
	_quality_multiplier = 1.0

	for mesh in original_materials.keys():
		mesh.set_surface_override_material(0, original_materials[mesh])

	if timer_label:
		timer_label.visible = false

	update_prompt()
	cooking_finished.emit(current_fish_type)

func collect_item() -> void:
	if not tray:
		return

	if tray.add_item(current_fish_type, "Backfisch"):
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
			interaction_prompt.text = tr("FRYER_PROMPT_IDLE")
			interaction_prompt.visible = true
		State.MINIGAME:
			interaction_prompt.text = tr("FRYER_PROMPT_MINIGAME")
			interaction_prompt.visible = true
		State.COOKING:
			interaction_prompt.text = tr("FRYER_PROMPT_COOKING")
			interaction_prompt.visible = true
		State.READY:
			interaction_prompt.text = tr("FRYER_PROMPT_READY")
			interaction_prompt.visible = true
		_:
			interaction_prompt.visible = false
