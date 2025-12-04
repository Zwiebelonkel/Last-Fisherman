extends Control

@onready var loading_label = $LoadingLabel
@onready var progress_bar = $ProgressBar
@onready var logo = $Logo  # Optional: Dein Spiel-Logo
@onready var fish_icon = $FishIcon  # 🆕 Zufälliger Fisch
@onready var animation_player = $AnimationPlayer  # Optional: Für Animationen

var loading_progress := 0.0
var target_scene := "res://scenes/MainMenu.tscn"
var fish_textures := []  # 🆕 Array für Fisch-Bilder

func _ready():
	print("🎮 Splash Screen gestartet")
	
	# 🆕 Lade alle Fisch-Assets
	load_random_fish()
	
	# Kurze Verzögerung für visuellen Effekt
	await get_tree().create_timer(0.5).timeout
	
	# Starte das Laden
	start_loading()

# 🆕 Lädt zufälliges Fisch-Icon
func load_random_fish():
	var fish_dir = "res://assets/fish/"
	var dir = DirAccess.open(fish_dir)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		# Sammle alle PNG-Dateien
		while file_name != "":
			if not dir.current_is_dir() and (file_name.ends_with(".png") or file_name.ends_with(".jpg")):
				fish_textures.append(fish_dir + file_name)
				print("🐟 Gefunden:", file_name)
			file_name = dir.get_next()
		
		dir.list_dir_end()
	else:
		print("⚠️ Konnte Ordner nicht öffnen:", fish_dir)
	
	# Wähle zufälliges Bild
	if fish_textures.size() > 0:
		var random_fish = fish_textures[randi() % fish_textures.size()]
		print("🎲 Zeige zufälligen Fisch:", random_fish)
		
		if fish_icon:
			fish_icon.texture = load(random_fish)
			
			# Optional:Animiere den Fisch (leichtes Wippen)
			animate_fish()
	else:
		print("⚠️ Keine Fisch-Assets gefunden!")

# 🆕 Animiert den Fisch (schwimmt hin und her)
func animate_fish():
	if not fish_icon:
		return
	
	var tween = create_tween()
	tween.set_loops()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	# Rotation Animation (leichtes Schwanken)
	tween.tween_property(fish_icon, "rotation_degrees", 5, 1.5)
	tween.tween_property(fish_icon, "rotation_degrees", -5, 1.5)
	
	# Optional: Auch Position
	var original_pos = fish_icon.position
	tween.parallel().tween_property(fish_icon, "position:y", original_pos.y - 10, 1.5)
	tween.tween_property(fish_icon, "position:y", original_pos.y + 10, 1.5)

func start_loading():
	print("⏳ Beginne mit Laden...")
	
	# Optional: Spiele eine Animation ab
	if animation_player and animation_player.has_animation("logo_fade"):
		animation_player.play("logo_fade")
	
	# Starte asynchrones Laden
	ResourceLoader.load_threaded_request(target_scene)
	
	# Warte bis fertig
	await poll_loading_progress()
	
	# Kurze Pause bevor gewechselt wird
	await get_tree().create_timer(0.3).timeout
	
	print("✅ Laden abgeschlossen! Wechsle zu Hauptszene...")
	get_tree().change_scene_to_file(target_scene)

func poll_loading_progress():
	var status = ResourceLoader.THREAD_LOAD_IN_PROGRESS
	var progress = []
	
	while status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		status = ResourceLoader.load_threaded_get_status(target_scene, progress)
		
		if progress.size() > 0:
			loading_progress = progress[0]
			update_ui()
		
		await get_tree().process_frame
	
	# Finale Updates
	loading_progress = 1.0
	update_ui()
	
	if status != ResourceLoader.THREAD_LOAD_LOADED:
		print("❌ Fehler beim Laden!")
		loading_label.text = "Error loading game!"

func update_ui():
	var percent = int(loading_progress * 100)
	
	# Update Label mit Fishing-Themed Messages
	if loading_label:
		if percent < 20:
			loading_label.text = "🎣 Preparing fishing rods... %d%%" % percent
		elif percent < 40:
			loading_label.text = "🐟 Filling lakes with fish... %d%%" % percent
		elif percent < 60:
			loading_label.text = "🌊 Creating water physics... %d%%" % percent
		elif percent < 80:
			loading_label.text = "🏔️ Setting up biomes... %d%%" % percent
		elif percent < 95:
			loading_label.text = "✨ Polishing hooks... %d%%" % percent
		else:
			loading_label.text = "🎮 Ready to fish! %d%%" % percent
	
	# Update Progress Bar
	if progress_bar:
		progress_bar.value = loading_progress * 100
		
		# Optional: Farbwechsel basierend auf Fortschritt
		var bar_style = progress_bar.get_theme_stylebox("fill")
		if bar_style:
			if percent < 33:
				progress_bar.modulate = Color(1.0, 0.3, 0.3)  # Rot
			elif percent < 66:
				progress_bar.modulate = Color(1.0, 0.8, 0.2)  # Gelb
			else:
				progress_bar.modulate = Color(0.3, 1.0, 0.3)  # Grün
