extends Node
class_name Tray

signal item_added(item: TrayItem)
signal item_removed(item: TrayItem)
signal tray_full()
signal tray_cleared()

const MAX_SLOTS = 4
const FishVisual := preload("res://scripts/FishVisual3D.gd")

var items: Array[TrayItem] = []

# 3D Tablett Referenzen
var tray_mesh: Node3D = null
var slot_positions: Array[Vector3] = [
	Vector3(-0.095, 0.014, -0.065),
	Vector3(0.095, 0.014, -0.065),
	Vector3(-0.095, 0.014, 0.065),
	Vector3(0.095, 0.014, 0.065)
]
var slot_meshes: Array[MeshInstance3D] = []

class TrayItem:
	var fish_type: String
	var preparation_type: String
	var is_drink: bool
	var visual_node: Node3D = null  # 3D Representation
	var fish_data: Dictionary = {}
	var quality: String = "good"
	
	func _init(fish: String = "", prep: String = "", drink: bool = false):
		fish_type = fish
		preparation_type = prep
		is_drink = drink
	
	func get_description() -> String:
		if is_drink:
			return "Getraenk"
		return "%s (%s)" % [fish_type, preparation_type]

func set_tray_mesh(mesh: Node3D) -> void:
	"""Setze das 3D Tablett Mesh"""
	tray_mesh = mesh
	setup_slots()

func setup_slots() -> void:
	"""Erstelle visuelle Slots auf dem Tablett"""
	if not tray_mesh:
		return
	for old_slot in slot_meshes:
		if is_instance_valid(old_slot):
			old_slot.free()
	slot_meshes.clear()
	
	for i in range(MAX_SLOTS):
		var slot = MeshInstance3D.new()
		tray_mesh.add_child(slot)
		slot.position = slot_positions[i]
		slot.visible = false  # Unsichtbar bis Item platziert wird
		slot_meshes.append(slot)
	for i in range(items.size()):
		create_item_visual(items[i], i)

func add_item(fish_type: String, preparation_type: String, fish_data: Dictionary = {}, quality: String = "good") -> bool:
	if items.size() >= MAX_SLOTS:
		tray_full.emit()
		print("Tablett ist voll!")
		return false
	
	var item = TrayItem.new(fish_type, preparation_type, false)
	item.fish_data = (fish_data if not fish_data.is_empty() else FishDB.get_fish_by_id(fish_type)).duplicate(true)
	item.quality = quality
	items.append(item)
	
	# Erstelle 3D Visual
	create_item_visual(item, items.size() - 1)
	
	item_added.emit(item)
	print("Item hinzugefuegt: %s" % item.get_description())
	return true

func add_drink() -> bool:
	if items.size() >= MAX_SLOTS:
		tray_full.emit()
		print("Tablett ist voll!")
		return false
	
	var item = TrayItem.new("", "", true)
	items.append(item)
	
	# Erstelle 3D Visual
	create_item_visual(item, items.size() - 1)
	
	item_added.emit(item)
	print("Getraenk hinzugefuegt")
	return true

func create_item_visual(item: TrayItem, slot_index: int) -> void:
	"""Erstellt ein 3D Mesh für das Item auf dem Tablett"""
	if not tray_mesh or slot_index >= slot_meshes.size():
		return
	
	var slot = slot_meshes[slot_index]
	_clear_slot(slot)
	
	# Erstelle Mesh basierend auf Item-Typ
	if item.is_drink:
		# Getränk = Zylinder (Glas)
		var cylinder = CylinderMesh.new()
		cylinder.top_radius = 0.03
		cylinder.bottom_radius = 0.03
		cylinder.height = 0.08
		slot.mesh = cylinder
		
		var material = StandardMaterial3D.new()
		material.albedo_color = Color(0.8, 0.9, 1.0, 0.7)
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		slot.set_surface_override_material(0, material)
		
	else:
		# Fisch-Gericht = Flache Box (Teller)
		var box = BoxMesh.new()
		box.size = Vector3(0.17, 0.008, 0.118)
		slot.mesh = box
		
		var material = StandardMaterial3D.new()
		
		material.albedo_color = Color(0.92, 0.91, 0.85)
		material.roughness = 0.55
		
		slot.set_surface_override_material(0, material)
		var dish := Node3D.new()
		dish.name = "FishDish"
		slot.add_child(dish)
		dish.rotation.x = -PI * 0.5
		dish.position.y = 0.012
		dish.scale = Vector3.ONE * 0.065
		var pieces := 5 if item.preparation_type == "Sushi" else 1
		var dish_bounds := AABB()
		for i in range(pieces):
			var fish := FishVisual.new()
			fish.name = "FishPiece%d" % i
			fish.slice_region = Vector2(float(i) / pieces, float(i + 1) / pieces)
			dish.add_child(fish)
			fish.set_texture(FishDB.get_fish_icon(item.fish_data), bool(item.fish_data.get("is_shiny", false)))
			if item.preparation_type == "Backfisch":
				fish.set_cooked(0.94, 0.7 if item.quality == "burned" else 0.0)
			else:
				fish.position.x = (i - (pieces - 1) * 0.5) * 0.12
			if fish.mesh != null:
				var bounds := fish.mesh.get_aabb()
				bounds.position += fish.position
				dish_bounds = dish_bounds.merge(bounds)
		var fit := minf(0.065, minf(0.15 / maxf(dish_bounds.size.x, 0.001), 0.102 / maxf(dish_bounds.size.y, 0.001)))
		dish.scale = Vector3.ONE * fit
		dish.position.y = 0.004 + 0.11 * fit
	
	slot.visible = true
	item.visual_node = slot


func _clear_slot(slot: MeshInstance3D) -> void:
	for child in slot.get_children():
		child.free()
	slot.mesh = null
	slot.material_override = null
	slot.visible = false

func remove_item(index: int) -> void:
	if index < 0 or index >= items.size():
		return
	
	var item = items[index]
	items.remove_at(index)
	item.visual_node = null
	for slot in slot_meshes:
		_clear_slot(slot)
	for i in range(items.size()):
		create_item_visual(items[i], i)
	item_removed.emit(item)
	print("Item entfernt: %s" % item.get_description())

func clear_all() -> void:
	# Entferne alle Visuals
	for item in items:
		item.visual_node = null
	for slot in slot_meshes:
		_clear_slot(slot)
	
	items.clear()
	tray_cleared.emit()
	print("Tablett geleert")

func get_items() -> Array[TrayItem]:
	return items

func has_items() -> bool:
	return items.size() > 0

func matches_order(order: Order) -> bool:
	# Überprüfe ob das Tablett exakt die Bestellung enthält
	var required_items = []
	
	# Hauptgericht
	required_items.append(TrayItem.new(order.fish_type, order.preparation_type, false))
	
	# Getränk falls gewünscht
	if order.wants_drink:
		required_items.append(TrayItem.new("", "", true))
	
	# Vergleiche Anzahl
	if items.size() != required_items.size():
		print("Falsche Anzahl Items: %d statt %d" % [items.size(), required_items.size()])
		return false
	
	# Vergleiche Items
	var found_fish = false
	var found_drink = false
	
	for item in items:
		if item.is_drink:
			found_drink = true
		elif item.fish_type == order.fish_type and item.preparation_type == order.preparation_type:
			found_fish = true
	
	var needs_fish = true
	var needs_drink = order.wants_drink
	
	if needs_fish and not found_fish:
		print("Fisch fehlt oder falsch!")
		return false
	
	if needs_drink and not found_drink:
		print("Getränk fehlt!")
		return false
	
	if found_drink and not needs_drink:
		print("Getränk nicht bestellt!")
		return false
	
	return true

func get_slot_count() -> int:
	return items.size()

func get_free_slots() -> int:
	return MAX_SLOTS - items.size()
