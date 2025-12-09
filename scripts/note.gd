extends Node3D
class_name Note

@export_multiline var note_title: String = "Notiz"
@export_multiline var note_text: String = "Dies ist eine Notiz."
@export var interaction_distance: float = 3.0

var player_in_range: bool = false
var player: Node3D = null
var note_is_open: bool = false

signal note_opened(title: String, text: String)
signal note_closed()

func _ready() -> void:
	if not is_in_group("notes"):
		add_to_group("notes")
	
	print("📝 NOTE READY: ", name, " | Title: ", note_title)
	
	var area = get_node_or_null("Area3D")
	if area:
		area.body_entered.connect(_on_body_entered)
		area.body_exited.connect(_on_body_exited)
		print("  ✅ Area3D Signals verbunden")
	else:
		push_error("  ❌ Area3D FEHLT!")
	

func _process(_delta: float) -> void:
	if not player_in_range or not player:
		return
	
	var distance = global_position.distance_to(player.global_position)
	
	if distance > interaction_distance:
		player_in_range = false
		if note_is_open:
			print("📏 Zu weit weg - Note automatisch schließen")
			close_note()
		return
	
	# E-Taste Toggle
	if Input.is_action_just_pressed("interact"):
		if note_is_open:
			print("🔥 E gedrückt - SCHLIESSE Note")
			close_note()
		else:
			print("🔥 E gedrückt - ÖFFNE Note")
			open_note()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		player = body
		print("✅ Player betritt Note-Bereich: ", name)

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		print("❌ Player verlässt Note-Bereich: ", name)
		player_in_range = false
		player = null
		
		if note_is_open:
			print("📏 Auto-Close: Note schließen")
			close_note()

func open_note() -> void:
	print("📖 ÖFFNE NOTE: ", note_title)
	note_is_open = true
	emit_signal("note_opened", note_title, note_text)

func close_note() -> void:
	print("📕 SCHLIESSE NOTE: ", note_title)
	note_is_open = false
	emit_signal("note_closed")

func add_hover_indicator() -> void:
	var mesh = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.15
	mesh.mesh = sphere
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(1, 1, 0, 0.8)
	mat.emission_enabled = true
	mat.emission = Color(1, 1, 0)
	mat.emission_energy_multiplier = 3.0
	mesh.material_override = mat
	
	add_child(mesh)
	mesh.position.y = 0.5
