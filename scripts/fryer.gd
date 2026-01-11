extends StaticBody3D
class_name StationFryer

signal cooking_started(fish_type: String)
signal cooking_finished(fish_type: String)
signal item_collected()

# Statt einem Mesh haben wir jetzt mehrere
@onready var model_root: Node3D = $Fryer
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var timer_label: Label3D = $TimerLabel3D
@onready var interaction_prompt: Label3D = $InteractionPrompt
@onready var outline_mesh: MeshInstance3D = $OutlineMesh


var cooking_time: float = 8.0
var current_cooking_time: float = 0.0
var current_fish_type: String = ""
var is_hovering: bool = false

# States
enum State { IDLE, WAITING_FOR_FISH, COOKING, READY }
var current_state: State = State.IDLE

var tray: Tray = null
var controller: Node = null
var fish_selection_ui: Control = null

# Materials - jetzt für alle Meshes
var original_materials: Dictionary = {}  # mesh -> original material
var cooking_material: StandardMaterial3D

func _ready() -> void:
	setup_materials()
	if timer_label:
		timer_label.visible = false
	update_prompt()

func _process(delta: float) -> void:
	if current_state == State.COOKING:
		current_cooking_time += delta
		
		if timer_label:
			var remaining = cooking_time - current_cooking_time
			timer_label.text = "%.1fs" % max(0, remaining)
		
		if current_cooking_time >= cooking_time:
			finish_cooking()

func get_all_meshes() -> Array[MeshInstance3D]:
	"""Findet alle MeshInstance3D Nodes im GLTF-Modell"""
	var meshes: Array[MeshInstance3D] = []
	
	if not model_root:
		print("⚠️ Kein model_root gefunden!")
		return meshes
	
	# Rekursiv alle MeshInstance3D finden
	find_meshes_recursive(model_root, meshes)
	
	print("✅ %d Meshes gefunden im Modell" % meshes.size())
	return meshes

func find_meshes_recursive(node: Node, meshes: Array[MeshInstance3D]) -> void:
	"""Durchsucht rekursiv alle Kinder nach MeshInstance3D"""
	if node is MeshInstance3D:
		meshes.append(node)
	
	for child in node.get_children():
		find_meshes_recursive(child, meshes)

func setup_materials() -> void:
	var meshes = get_all_meshes()
	
	if meshes.size() == 0:
		print("⚠️ Keine MeshInstances gefunden!")
		return
	
	# Speichere Original-Materialien von allen Meshes
	for mesh in meshes:
		if mesh.get_surface_override_material_count() > 0:
			original_materials[mesh] = mesh.get_surface_override_material(0)
		else:
			# Fallback: Standard-Material
			var mat = StandardMaterial3D.new()
			mat.albedo_color = Color(0.8, 0.8, 0.8)
			mesh.set_surface_override_material(0, mat)
			original_materials[mesh] = mat
	
	# Koch-Material (für alle Meshes gleich)
	cooking_material = StandardMaterial3D.new()
	cooking_material.albedo_color = Color.ORANGE
	cooking_material.emission_enabled = true
	cooking_material.emission = Color.ORANGE_RED
	cooking_material.emission_energy = 2.0

#func setup_outlines() -> void:
	#"""Erstellt Outlines für ALLE Meshes im Modell"""
	#var meshes = get_all_meshes()
	#
	#if meshes.size() == 0:
		#return
	#
	#for mesh in meshes:
		#if not mesh.mesh:
			#continue
		#
		#var outline_mesh = MeshInstance3D.new()
		#add_child(outline_mesh)
		#
		## Kopiere Transform vom Original-Mesh (relativ zum Fryer-Node)
		#outline_mesh.global_transform = mesh.global_transform
		#outline_mesh.scale = mesh.scale * 1.05  # 5% größer
		#outline_mesh.mesh = mesh.mesh
		#
		## Outline-Material
		#var outline_material = StandardMaterial3D.new()
		#outline_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		#outline_material.albedo_color = Color.YELLOW
		#outline_material.cull_mode = BaseMaterial3D.CULL_FRONT
		#outline_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		#outline_material.albedo_color.a = 0.8
		#
		## Setze Material für alle Surfaces dieses Meshes
		#for i in range(mesh.get_surface_override_material_count()):
			#outline_mesh.set_surface_override_material(i, outline_material)
		#
		#outline_mesh.visible = false
		#outline_meshes.append(outline_mesh)
	#
	#print("✅ %d Outline-Meshes erstellt" % outline_meshes.size())

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
	"""Zeigt/versteckt ALLE Outlines"""
	is_hovering = hovering
	if current_state == State.IDLE:
		outline_mesh.visible = hovering

func interact() -> void:
	match current_state:
		State.IDLE:
			open_fish_selection()
		State.COOKING:
			print("Noch am Kochen!")
		State.READY:
			collect_item()

func open_fish_selection() -> void:
	if not fish_selection_ui or not controller:
		return
	
	var available_fish = controller.get_available_fish_types()
	if available_fish.size() == 0:
		print("Keine Fische im Inventar!")
		return
	
	fish_selection_ui.show_fish_selection(
		controller.get_available_fish_dicts(),
		"Fritteuse"
	)

	current_state = State.WAITING_FOR_FISH

func _on_fish_selected(fish_name: String) -> void:
	if current_state != State.WAITING_FOR_FISH:
		return

	if not controller or not controller.current_customer:
		current_state = State.IDLE
		update_prompt()
		return

	var order = controller.current_customer.order

	# Station prüft NUR, ob sie die richtige Zubereitungsart ist
	if order.preparation_type != "Backfisch":
		print("Kunde will keinen Backfisch!")
		current_state = State.IDLE
		update_prompt()
		return

	# Inventar-Prüfung
	if not controller.has_fish_in_inventory(fish_name):
		print("Fisch nicht im Inventar!")
		current_state = State.IDLE
		update_prompt()
		return

	# IMMER kochen – auch falscher Fisch
	start_cooking(fish_name)

func start_cooking(fish_type: String) -> void:
	current_fish_type = fish_type
	current_cooking_time = 0.0
	current_state = State.COOKING
	
	# Setze Koch-Material für ALLE Meshes
	var meshes = get_all_meshes()
	for mesh in meshes:
		mesh.set_surface_override_material(0, cooking_material)
	
	if timer_label:
		timer_label.visible = true
	
	# Verstecke alle Outlines während dem Kochen
	outline_mesh.visible = false
	
	update_prompt()
	cooking_started.emit(fish_type)
	print("Frittiere %s..." % fish_type)

func finish_cooking() -> void:
	current_state = State.READY
	
	# Setze Original-Materialien zurück
	for mesh in original_materials.keys():
		mesh.set_surface_override_material(0, original_materials[mesh])
	
	if timer_label:
		timer_label.visible = false
	
	update_prompt()
	cooking_finished.emit(current_fish_type)
	print("Backfisch fertig! Klicke erneut zum Aufnehmen")

func collect_item() -> void:
	if not tray:
		print("Kein Tablett gefunden!")
		return
	
	if tray.add_item(current_fish_type, "Backfisch"):
		print("Backfisch auf Tablett gelegt!")
		current_state = State.IDLE
		current_fish_type = ""
		update_prompt()
		item_collected.emit()

func update_prompt() -> void:
	if not interaction_prompt:
		return
	
	match current_state:
		State.IDLE:
			interaction_prompt.text = "Klicken: Fisch waehlen"
			interaction_prompt.visible = true
		State.COOKING:
			interaction_prompt.text = "Kocht..."
			interaction_prompt.visible = true
		State.READY:
			interaction_prompt.text = "Klicken: Aufnehmen"
			interaction_prompt.visible = true
		_:
			interaction_prompt.visible = false
