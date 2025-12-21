extends CanvasLayer

# Font als Konstante preloaden (statt dynamisch laden)
const CUSTOM_FONT = preload("res://fonts/VCR_OSD_MONO_1.001.ttf")

# Node-Referenzen
var color_rect: ColorRect
var loading_label: Label        # 🆕 Loading Text

# Transition-Status
var is_transitioning: bool = false
var loading_active := false     # 🆕 Loading Status

# Biom-spezifische Farben
var biome_colors = {
	"lake": Color(0.2, 0.5, 0.8, 1.0),      # Blau
	"city": Color(0.3, 0.3, 0.3, 1.0),       # Grau
	"sewer": Color(0.2, 0.4, 0.2, 1.0),      # Schmutziges Grün
	"forest": Color(0.2, 0.5, 0.2, 1.0),     # Grün
	"desert": Color(0.9, 0.7, 0.3, 1.0),     # Sand-Gelb
	"iceland": Color(0.7, 0.9, 1.0, 1.0),    # Eisblau
	"main": Color(0.0, 0.0, 0.0, 1.0),       # Schwarz (Standard)
}

func _ready():
	print("🎬 Transition wird initialisiert...")
	
	# ColorRect erstellen falls nicht vorhanden
	if not has_node("ColorRect"):
		print("📦 Erstelle ColorRect...")
		color_rect = ColorRect.new()
		color_rect.name = "ColorRect"
		add_child(color_rect)
		
		# ColorRect auf Fullscreen setzen
		color_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		color_rect.size = get_viewport().get_visible_rect().size
		color_rect.color = Color.BLACK
		color_rect.z_index = 100
	else:
		print("📦 ColorRect gefunden!")
		color_rect = get_node("ColorRect")
	
	# Stelle sicher, dass Layer ganz oben ist
	layer = 128
	
	# ColorRect initial unsichtbar machen
	color_rect.modulate.a = 0.0
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# 🆕 Loading Label erstellen
	if not has_node("LoadingLabel"):
		print("📦 Erstelle Loading Label...")
		loading_label = Label.new()
		loading_label.name = "LoadingLabel"
		loading_label.text = "Loading..."
		loading_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		loading_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		loading_label.visible = false
		loading_label.modulate = Color(1, 1, 1, 1)
		loading_label.z_index = 101
		
		# Label zentrieren
		loading_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
		loading_label.size = Vector2(400, 100)
		loading_label.position = Vector2(-200, -50)
		
		# 🎨 Custom Font Settings
		var label_settings = LabelSettings.new()
		label_settings.font_size = 48
		label_settings.font_color = Color.WHITE
		label_settings.outline_size = 8
		label_settings.outline_color = Color.BLACK
		
		# Font direkt zuweisen (wurde oben als Konstante preloaded)
		if CUSTOM_FONT:
			label_settings.font = CUSTOM_FONT
			print("✅ Custom Font geladen!")
		else:
			print("⚠️ Custom Font nicht gefunden - nutze Standard-Font")
		
		loading_label.label_settings = label_settings
		
		add_child(loading_label)
	else:
		print("📦 Loading Label gefunden!")
		loading_label = get_node("LoadingLabel")
	
	print("✅ Transition bereit! Layer:", layer, "ColorRect Size:", color_rect.size)

# Standard-Transition (Swipe von unten nach oben) mit Async Loading
func change_scene(target_scene: String, duration: float = 0.5) -> void:
	GodotSteam.flush_scores()
	if is_transitioning:
		print("⚠️ Transition läuft bereits!")
		return
	
	print("🎬 START Swipe-Transition zu:", target_scene)
	is_transitioning = true
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	color_rect.color = Color.BLACK
	color_rect.show()
	
	# Hole Bildschirmgröße
	var screen_size = get_viewport().get_visible_rect().size
	
	# Starte von unten außerhalb des Bildschirms
	color_rect.position = Vector2(0, screen_size.y)
	color_rect.size = screen_size
	color_rect.modulate.a = 1.0  # Voll sichtbar
	
	print("📺 Swipe In - Start Position:", color_rect.position)
	
	# Swipe In (von unten nach oben)
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(color_rect, "position:y", 0.0, duration)
	print("⬆️ Swipe In gestartet...")
	await tween.finished
	print("⬆️ Swipe In fertig! Position:", color_rect.position)
	
	# 🆕 Szene asynchron laden
	print("🔄 Lade Szene asynchron...")
	await load_scene_async(target_scene)
	await get_tree().process_frame
	print("✅ Szene gewechselt!")
	
	# Swipe Out (nach oben raus)
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(color_rect, "position:y", -screen_size.y, duration)
	print("⬆️ Swipe Out gestartet...")
	await tween.finished
	print("⬆️ Swipe Out fertig! Position:", color_rect.position)
	
	# Zurücksetzen für nächste Transition
	color_rect.position = Vector2.ZERO
	color_rect.modulate.a = 0.0
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	is_transitioning = false
	print("✅ Swipe-Transition komplett beendet!")

# Biom-spezifische Transition mit Farbe
func change_to_biome(target_scene: String, biome_name: String, duration: float = 0.6) -> void:
	if is_transitioning:
		return
	
	is_transitioning = true
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Setze Biom-Farbe
	var biome_color = biome_colors.get(biome_name, Color.BLACK)
	color_rect.color = biome_color
	
	# Fade Out mit Biom-Farbe
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(color_rect, "modulate:a", 1.0, duration * 0.5)
	await tween.finished
	
	# Kurze Pause in der Biom-Farbe
	await get_tree().create_timer(0.1).timeout
	
	# Szene wechseln
	get_tree().change_scene_to_file(target_scene)
	await get_tree().process_frame
	
	# Fade In
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(color_rect, "modulate:a", 0.0, duration * 0.5)
	await tween.finished
	
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	is_transitioning = false

# Schnelle Transition zurück zum Hauptmenü (von oben nach unten)
func back_to_main(duration: float = 0.4) -> void:
	change_scene_reverse("res://scenes/mainMenu.tscn", duration)

# Reverse Transition (von oben nach unten - für "Zurück") mit Async Loading
func change_scene_reverse(target_scene: String, duration: float = 0.5) -> void:
	if is_transitioning:
		print("⚠️ Transition läuft bereits!")
		return
	
	print("🎬 START Reverse Swipe-Transition zu:", target_scene)
	is_transitioning = true
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	color_rect.color = Color.BLACK
	color_rect.show()
	
	# Hole Bildschirmgröße
	var screen_size = get_viewport().get_visible_rect().size
	
	# Starte von oben außerhalb des Bildschirms
	color_rect.position = Vector2(0, -screen_size.y)
	color_rect.size = screen_size
	color_rect.modulate.a = 1.0
	
	print("📺 Swipe In - Start Position:", color_rect.position)
	
	# Swipe In (von oben nach unten)
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(color_rect, "position:y", 0.0, duration)
	print("⬇️ Swipe In gestartet...")
	await tween.finished
	print("⬇️ Swipe In fertig! Position:", color_rect.position)
	
	# 🆕 Szene asynchron laden
	print("🔄 Lade Szene asynchron...")
	await load_scene_async(target_scene)
	await get_tree().process_frame
	print("✅ Szene gewechselt!")
	
	# Swipe Out (nach unten raus)
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(color_rect, "position:y", screen_size.y, duration)
	print("⬇️ Swipe Out gestartet...")
	await tween.finished
	print("⬇️ Swipe Out fertig! Position:", color_rect.position)
	
	# Zurücksetzen für nächste Transition
	color_rect.position = Vector2.ZERO
	color_rect.modulate.a = 0.0
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	is_transitioning = false
	print("✅ Reverse Swipe-Transition komplett beendet!")

# Wellen-Effekt für Wasser-Biome
func water_transition(target_scene: String, duration: float = 1.2) -> void:
	if is_transitioning:
		return
	
	print("🌊 Starte Wasser-Transition zu:", target_scene)
	is_transitioning = true
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	color_rect.color = Color(0.1, 0.4, 0.7, 1.0)  # Dunkleres, sichtbareres Blau
	color_rect.modulate.a = 0.0  # Start bei unsichtbar
	
	# Wellen-Animation (simuliert durch mehrfache Alpha-Änderungen)
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	print("🌊 Welle 1...")
	# Erste Welle
	tween.tween_property(color_rect, "modulate:a", 0.6, duration * 0.2)
	tween.tween_property(color_rect, "modulate:a", 0.3, duration * 0.15)
	print("🌊 Welle 2...")
	# Zweite Welle
	tween.tween_property(color_rect, "modulate:a", 0.8, duration * 0.2)
	tween.tween_property(color_rect, "modulate:a", 0.4, duration * 0.15)
	print("🌊 Voller Übergang...")
	# Voller Übergang
	tween.tween_property(color_rect, "modulate:a", 1.0, duration * 0.3)
	await tween.finished
	
	print("🌊 Wechsle Szene...")
	# Szene wechseln
	get_tree().change_scene_to_file(target_scene)
	await get_tree().process_frame
	
	print("🌊 Fade In...")
	# Fade In
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(color_rect, "modulate:a", 0.0, duration * 0.4)
	await tween.finished
	
	print("🌊 Wasser-Transition beendet!")
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	is_transitioning = false

# ---------------------------------------------------------
# 🆕 ASYNC LOADING: Szene asynchron laden
# ---------------------------------------------------------
func load_scene_async(path: String) -> void:
	if loading_active:
		return
	
	print("⏳ Starte asynchrones Laden:", path)
	loading_active = true
	loading_label.visible = true
	loading_label.text = "Loading..."
	
	# Anfrage starten
	var error = ResourceLoader.load_threaded_request(path)
	if error != OK:
		print("❌ Fehler beim Laden-Request:", error)
		loading_active = false
		loading_label.visible = false
		return
	
	var load_status = ResourceLoader.THREAD_LOAD_IN_PROGRESS
	var progress = []
	
	# Polling Loop
	while load_status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		load_status = ResourceLoader.load_threaded_get_status(path, progress)
		
		if progress.size() > 0:
			loading_label.text = "Loading... %d%%" % int(progress[0] * 100)
			print("📊 Loading Progress:", int(progress[0] * 100), "%")
		
		await get_tree().process_frame
	
	if load_status == ResourceLoader.THREAD_LOAD_LOADED:
		print("✅ Szene geladen!")
		var resource = ResourceLoader.load_threaded_get(path)
		get_tree().change_scene_to_packed(resource)
	else:
		print("❌ Fehler beim Laden! Status:", load_status)
	
	loading_label.visible = false
	loading_active = false

# HAUPT-FUNKTION: Automatische Transition-Auswahl
func go_to_scene(target_scene: String) -> void:
	# Erkenne Biom aus Scene-Pfad
	var biome = detect_biome_from_path(target_scene)
	
	# Wähle passende Transition
	match biome:
		"iceland":
			freeze_transition(target_scene)
		"lake", "forest":
			water_transition(target_scene)
		"desert":
			change_to_biome(target_scene, "desert", 0.5)
		"city", "sewer":
			change_to_biome(target_scene, biome, 0.4)
		_:
			change_scene(target_scene)

# Erkennt Biom aus Scene-Pfad
func detect_biome_from_path(scene_path: String) -> String:
	var lower_path = scene_path.to_lower()
	
	if "iceland" in lower_path or "ice" in lower_path:
		return "iceland"
	elif "lake" in lower_path or "see" in lower_path:
		return "lake"
	elif "city" in lower_path or "stadt" in lower_path:
		return "city"
	elif "sewer" in lower_path or "kanal" in lower_path:
		return "sewer"
	elif "forest" in lower_path or "wald" in lower_path:
		return "forest"
	elif "desert" in lower_path or "wueste" in lower_path:
		return "desert"
	else:
		return "main"

# Eis-Freeze Effekt für Iceland
func freeze_transition(target_scene: String, duration: float = 1.0) -> void:
	if is_transitioning:
		return
	
	is_transitioning = true
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	color_rect.color = Color(0.7, 0.9, 1.0, 1.0)  # Eisblau
	
	# Langsames "Einfrieren"
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_EXPO)  # Exponentiell = wird immer langsamer
	tween.tween_property(color_rect, "modulate:a", 1.0, duration * 0.7)
	await tween.finished
	
	# Szene wechseln
	get_tree().change_scene_to_file(target_scene)
	await get_tree().process_frame
	
	# Schnelles "Auftauen"
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)  # Leichtes Überschwingen
	tween.tween_property(color_rect, "modulate:a", 0.0, duration * 0.3)
	await tween.finished
	
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	is_transitioning = false
