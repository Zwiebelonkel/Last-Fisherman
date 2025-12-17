extends Control

@onready var loading_label = $LoadingLabel
@onready var progress_bar = $ProgressBar
@onready var logo = $Logo  # Optional: Dein Spiel-Logo
@onready var fish_icon = $FishIcon  # 🆕 Zufälliger Fisch
@onready var animation_player = $AnimationPlayer  # Optional: Für Animationen

var loading_progress := 0.0
var target_scene := "res://scenes/mainMenu.tscn"

# 🆕 WICHTIG: Definiere alle Fisch-Assets MANUELL
# DirAccess funktioniert NICHT in exportierten Builds!
var fish_textures := [
	"res://assets/fish/seetang.png",
	"res://assets/fish/makrele.png",
	"res://assets/fish/fish1.png",
	"res://assets/fish/fish2.png",
	"res://assets/fish/tuna.png",
	"res://assets/fish/fish3.png",
	"res://assets/fish/hermitcrab.png",
	"res://assets/fish/manta.png",
	"res://assets/fish/fish4.png",
	"res://assets/fish/Kaugummi.png",
	"res://assets/fish/glubschi.png",
	"res://assets/fish/Prinzessinor.png",
	"res://assets/fish/fish6.png",
	"res://assets/fish/plutonium.png",
	"res://assets/fish/button.png",
	"res://assets/fish/Aal.png",
	"res://assets/fish/signal.png",
	"res://assets/fish/trümmer.png",
	"res://assets/fish/dorsch.png",
	"res://assets/fish/diskus.png",
	"res://assets/fish/baracuda.png",
	"res://assets/fish/brot.png",
	"res://assets/fish/Eel.png",
	"res://assets/fish/Boro.png",
	"res://assets/fish/ghost.png",
	"res://assets/fish/bullenhai.png",
	"res://assets/fish/unknown.png",
	"res://assets/fish/corpse.png",
	"res://assets/fish/krake.png",
	"res://assets/fish/plug.png",
	"res://assets/fish/kackwurst.png",
	"res://assets/fish/sardine.png",
	"res://assets/fish/forelle.png",
	"res://assets/fish/Wels.png",
	"res://assets/fish/teerfisch.png",
	"res://assets/fish/potato.png",
	"res://assets/fish/mond.png",
	"res://assets/fish/katzenhai.png",
	"res://assets/fish/führerschein.png",
	"res://assets/fish/mantapoison.png",
	"res://assets/fish/Rainbowi.png",
	"res://assets/fish/scholle.png",
	"res://assets/fish/Kondom.png",
	"res://assets/fish/ticket.png",
	"res://assets/fish/Karpfen.png",
	"res://assets/fish/koi.png",
	"res://assets/fish/rohrschatten.png",
	"res://assets/fish/angel.png",
	"res://assets/fish/waldaal.png",
	"res://assets/fish/Gutter.png",
	"res://assets/fish/bambus.png",
	"res://assets/fish/makrele2.png",
	"res://assets/fish/wurzelfisch.png",
	"res://assets/fish/zahn.png",
	"res://assets/fish/schmutzgrundel.png",
	"res://assets/fish/solarfänger.png",
	"res://assets/fish/rostflosser.png",
	"res://assets/fish/sandstreifer.png",
	"res://assets/fish/garnele.png",
	"res://assets/fish/staubhai.png",
	"res://assets/fish/wasserfisch.png",
	"res://assets/fish/mantafire.png",
	"res://assets/fish/sonne.png",
	"res://assets/fish/goldhai.png",
	"res://assets/fish/benzin.png",
	"res://assets/fish/eisfisch.png",
	"res://assets/fish/angler.png",
	"res://assets/fish/blob.png",
	"res://assets/fish/speerfisch.png",
	"res://assets/fish/marlin.png",
	"res://assets/fish/megalodon.png",
	"res://assets/fish/pinguin.png"
]

# 🌍 Localized Loading Messages
var loading_messages := {
	"prepare": {
		"de": "🎣 Bereite Angelruten vor... %d%%",
		"en": "🎣 Preparing fishing rods... %d%%"
	},
	"fill": {
		"de": "🐟 Fülle Seen mit Fischen... %d%%",
		"en": "🐟 Filling lakes with fish... %d%%"
	},
	"physics": {
		"de": "🌊 Erstelle Wasser-Physik... %d%%",
		"en": "🌊 Creating water physics... %d%%"
	},
	"biomes": {
		"de": "🏔️ Richte Biome ein... %d%%",
		"en": "🏔️ Setting up biomes... %d%%"
	},
	"polish": {
		"de": "✨ Poliere Haken... %d%%",
		"en": "✨ Polishing hooks... %d%%"
	},
	"ready": {
		"de": "🎮 Bereit zum Angeln! %d%%",
		"en": "🎮 Ready to fish! %d%%"
	}
}

func _ready():
	print("🎮 Splash Screen gestartet")
	
	# 🆕 Lade zufälligen Fisch
	load_random_fish()
	
	# Kurze Verzögerung für visuellen Effekt
	await get_tree().create_timer(0.5).timeout
	
	# Starte das Laden
	start_loading()

# 🆕 Lädt zufälliges Fisch-Icon aus vordefiniertem Array
func load_random_fish():
	if fish_textures.is_empty():
		print("⚠️ Keine Fisch-Assets definiert!")
		return
	
	# Wähle zufälliges Bild
	var random_fish = fish_textures.pick_random()
	print("🎲 Zeige zufälligen Fisch:", random_fish)
	
	if fish_icon and ResourceLoader.exists(random_fish):
		fish_icon.texture = load(random_fish)
		
		# Optional: Animiere den Fisch
		animate_fish()
	else:
		print("⚠️ Konnte Fisch nicht laden:", random_fish)

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

# 🌍 Helper für übersetzten Text
func get_loading_text(key: String, percent: int) -> String:
	var current_lang = Player.current_language if Player else "de"
	if loading_messages.has(key) and loading_messages[key].has(current_lang):
		return loading_messages[key][current_lang] % percent
	return loading_messages[key]["de"] % percent

func update_ui():
	var percent = int(loading_progress * 100)
	
	# 🌍 Update Label mit lokalisierten Messages
	if loading_label:
		if percent < 20:
			loading_label.text = get_loading_text("prepare", percent)
		elif percent < 40:
			loading_label.text = get_loading_text("fill", percent)
		elif percent < 60:
			loading_label.text = get_loading_text("physics", percent)
		elif percent < 80:
			loading_label.text = get_loading_text("biomes", percent)
		elif percent < 95:
			loading_label.text = get_loading_text("polish", percent)
		else:
			loading_label.text = get_loading_text("ready", percent)
	
	# Update Progress Bar
	if progress_bar:
		progress_bar.value = loading_progress * 100
		
		# Optional: Farbwechsel basierend auf Fortschritt
		if percent < 33:
			progress_bar.modulate = Color(1.0, 0.3, 0.3)  # Rot
		elif percent < 66:
			progress_bar.modulate = Color(1.0, 0.8, 0.2)  # Gelb
		else:
			progress_bar.modulate = Color(0.3, 1.0, 0.3)  # Grün
