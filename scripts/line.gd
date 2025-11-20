extends MeshInstance3D

@export var rod_tip: Node3D
@export var hook: Node3D
@export var fishing_script: Node  # link to FishingRod

var im := ImmediateMesh.new()

func _ready() -> void:
	mesh = im

	# Schnur anfangs unsichtbar
	visible = false

	# Verbindung zum Signal herstellen
	if fishing_script:
		fishing_script.connect("line_visible", Callable(self, "set_line_visible"))

func set_line_visible(visible_state: bool) -> void:
	visible = visible_state

func _process(delta: float) -> void:
	if not visible:
		return

	if rod_tip == null or hook == null:
		return

	var start = rod_tip.global_transform.origin
	var end = hook.global_transform.origin

	var local_start = to_local(start)
	var local_end = to_local(end)

	im.clear_surfaces()

	im.surface_begin(Mesh.PRIMITIVE_LINES)
	im.surface_add_vertex(local_start)
	im.surface_add_vertex(local_end)
	im.surface_end()
