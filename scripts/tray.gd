extends Node
class_name Tray

signal item_added(item: TrayItem)
signal item_removed(item: TrayItem)
signal tray_full()
signal tray_cleared()

const MAX_SLOTS = 4

var items: Array[TrayItem] = []

# 3D Tablett Referenzen
var tray_mesh: Node3D = null
var slot_positions: Array[Vector3] = [
	Vector3(-0.15, 0.02, -0.1),  # Slot 1 (links vorne)
	Vector3(0.15, 0.02, -0.1),   # Slot 2 (rechts vorne)
	Vector3(-0.15, 0.02, 0.1),   # Slot 3 (links hinten)
	Vector3(0.15, 0.02, 0.1)     # Slot 4 (rechts hinten)
]
var slot_meshes: Array[MeshInstance3D] = []

class TrayItem:
	var fish_type: String
	var preparation_type: String
	var is_drink: bool
	var visual_node: Node3D = null  # 3D Representation
	
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
	
	for i in range(MAX_SLOTS):
		var slot = MeshInstance3D.new()
		tray_mesh.add_child(slot)
		slot.position = slot_positions[i]
		slot.visible = false  # Unsichtbar bis Item platziert wird
		slot_meshes.append(slot)

func add_item(fish_type: String, preparation_type: String) -> bool:
	if items.size() >= MAX_SLOTS:
		tray_full.emit()
		print("Tablett ist voll!")
		return false
	
	var item = TrayItem.new(fish_type, preparation_type, false)
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
		box.size = Vector3(0.12, 0.02, 0.09)
		slot.mesh = box
		
		var material = StandardMaterial3D.new()
		
		# Farbe basierend auf Zubereitungsart
		match item.preparation_type:
			"Backfisch":
				material.albedo_color = Color(0.9, 0.7, 0.4)  # Goldbraun
			"Sushi":
				material.albedo_color = Color(1.0, 0.5, 0.5)  # Rosa/Rot
			_:
				material.albedo_color = Color(0.8, 0.8, 0.8)
		
		slot.set_surface_override_material(0, material)
	
	slot.visible = true
	item.visual_node = slot

func remove_item(index: int) -> void:
	if index < 0 or index >= items.size():
		return
	
	var item = items[index]
	items.remove_at(index)
	item_removed.emit(item)
	print("Item entfernt: %s" % item.get_description())

func clear_all() -> void:
	# Entferne alle Visuals
	for item in items:
		if item.visual_node:
			item.visual_node.visible = false
			item.visual_node.mesh = null
	
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
