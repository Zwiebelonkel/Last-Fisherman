extends CanvasLayer

# Node-Referenzen
var color_rect: ColorRect
var loading_label: Label        # 🆕 Loading Text
var loading_active := false     # 🆕 Status

var is_transitioning: bool = false

# Biom-spezifische Farben
var biome_colors = {
	"lake": Color(0.2, 0.5, 0.8, 1.0),
	"city": Color(0.3, 0.3, 0.3, 1.0),
	"sewer": Color(0.2, 0.4, 0.2, 1.0),
	"forest": Color(0.2, 0.5, 0.2, 1.0),
	"desert": Color(0.9, 0.7, 0.3, 1.0),
	"iceland": Color(0.7, 0.9, 1.0, 1.0),
	"main": Color(0, 0, 0, 1)
}

func _ready():
	# ColorRect erzeugen
	if not has_node("ColorRect"):
		color_rect = ColorRect.new()
		color_rect.name = "ColorRect"
		add_child(color_rect)

		color_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		color_rect.color = Color.BLACK
		color_rect.modulate.a = 0.0
		color_rect.z_index = 100
	else:
		color_rect = get_node("ColorRect")

	layer = 128

	# 🆕 Loading Label erzeugen
	if not has_node("LoadingLabel"):
		loading_label = Label.new()
		loading_label.name = "LoadingLabel"
		loading_label.text = "Loading..."
		loading_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		loading_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		loading_label.visible = false
		loading_label.modulate = Color(1, 1, 1, 1)
		add_child(loading_label)

		loading_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	else:
		loading_label = get_node("LoadingLabel")



# ---------------------------------------------------------
# 🆕 LOADING-MANAGER: Szene async laden
# ---------------------------------------------------------
func load_scene_async(path: String) -> void:
	if loading_active:
		return

	loading_active = true
	loading_label.visible = true
	loading_label.text = "Loading..."

	# Anfrage starten
	ResourceLoader.load_threaded_request(path)

	var load_status = 0

	# Polling Loop → blockiert NICHT das Spiel
	while load_status < ResourceLoader.THREAD_LOAD_LOADED:
		load_status = ResourceLoader.load_threaded_get_status(path)

		await get_tree().process_frame

	var resource = ResourceLoader.load_threaded_get(path)
	get_tree().change_scene_to_packed(resource)

	loading_label.visible = false
	loading_active = false



# ---------------------------------------------------------
# 🎬 Transition + Async Loading
# ---------------------------------------------------------
func transition_and_load(target_scene: String, duration: float = 0.4):
	if is_transitioning: return
	is_transitioning = true

	color_rect.modulate.a = 0.0
	color_rect.show()

	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(color_rect, "modulate:a", 1.0, duration)
	await tween.finished

	# 🆕 Jetzt Szene laden (async)
	await load_scene_async(target_scene)

	# Fade wieder raus
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(color_rect, "modulate:a", 0.0, duration)
	await tween.finished

	color_rect.hide()
	is_transitioning = false



# ---------------------------------------------------------
# HAUPT-FUNKTION
# ---------------------------------------------------------
func go_to_scene(target_scene: String) -> void:
	# Falls du die Biom-Transitions weiter nutzen willst:
	var biome = detect_biome_from_path(target_scene)

	match biome:
		"iceland":
			await freeze_transition(target_scene)
		"lake", "forest":
			await water_transition(target_scene)
		"desert":
			await change_to_biome(target_scene, "desert", 0.5)
		"city", "sewer":
			await change_to_biome(target_scene, biome, 0.4)
		_:
			await transition_and_load(target_scene)