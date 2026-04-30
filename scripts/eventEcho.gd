extends CanvasLayer
class_name EventEcho

# -------------------------
# Event-Typen
# -------------------------
enum EventType {
	BEACH,
	CITY,
	DESERT,
	FOREST,
	SEWER,
	ICE_STORM,
	OCEAN,
	ENDING
}

# -------------------------
# Bild-Zuordnung
# -------------------------
const EVENT_IMAGES := {
	EventType.BEACH:     "res://assets/echos/beach.png",
	EventType.CITY:      "res://assets/echos/city.png",
	EventType.DESERT:    "res://assets/echos/desert.png",
	EventType.FOREST:    "res://assets/echos/forest.png",
	EventType.SEWER:     "res://assets/echos/sewer.png",
	EventType.ICE_STORM: "res://assets/echos/ice.png",
	EventType.OCEAN:     "res://assets/echos/ocean.png",
	EventType.ENDING:    "res://assets/echos/ending.png",
}

# -------------------------
# Node-Referenzen
# -------------------------
@onready var background: ColorRect = $ColorRect
@onready var image: TextureRect = $image
@onready var label: RichTextLabel = $CanvasLayer/textContainer/Label
@onready var pixelate_material: ShaderMaterial = $Filter/PixelateOverlay.material
@export var ending_music: AudioStream
@export var ending_music_bus := "Music"

var _waiting_for_input := false
var _ending_player: AudioStreamPlayer

# -------------------------
# Ready
# -------------------------
func _ready() -> void:
	print("📌 EventEcho._ready() aufgerufen")
	
	# Verstecke alles initial
	if background:
		background.visible = true
		background.color = Color.TRANSPARENT
		print("📌 Background initialisiert")
	
	if image:
		image.visible = false
		print("📌 Image versteckt")
	
	if label:
		print("📌 Label gefunden")
	else:
		print("⚠️ FEHLER: Label nicht gefunden!")
	
	set_process_input(false)
	print("📌 EventEcho._ready() abgeschlossen")

# -------------------------
# Öffentliche API
# -------------------------
func set_event(event_type: EventType, text: String) -> void:
	var resolved_text := _resolve_event_text(text)
	print("📌 set_event() aufgerufen - Type:", event_type, " Text:", resolved_text)
	
	# Warte einen Frame für Sicherheit
	await get_tree().process_frame
	
	print("📌 Starte Typewriter mit Text:", resolved_text)
	if label and label.has_method("start_typewriter"):
		label.start_typewriter(resolved_text)
		print("📌 Typewriter gestartet")
	else:
		print("⚠️ FEHLER: Label oder start_typewriter nicht verfügbar!")
		if label:
			label.text = text  # Fallback: Zeige Text direkt
	
	match event_type:
		EventType.ENDING:
			print("📌 Erkannt: ENDING Event")
			_apply_ending()
		_:
			print("📌 Erkannt: Standard Bild Event")
			_apply_image_event(event_type)


func _resolve_event_text(raw_text: String) -> String:
	var translated_text := raw_text

	if raw_text.begins_with("EVENT_"):
		translated_text = TranslationServer.translate(raw_text)

	return translated_text.replace("\\n", "\n")
# -------------------------
# Ending
# -------------------------
func _apply_ending() -> void:
	print("📌 _apply_ending() gestartet")
	
	if not background or not image or not pixelate_material:
		print("⚠️ FEHLER: Nodes nicht initialisiert!")
		return
	
	# Schwarzer Hintergrund
	background.color = Color.BLACK
	background.visible = true
	print("📌 Hintergrund auf Schwarz gesetzt")
	
	# Bild laden und anzeigen
	image.visible = true
	var texture_path = EVENT_IMAGES[EventType.ENDING]
	print("📌 Lade Texture:", texture_path)
	
	if ResourceLoader.exists(texture_path):
		image.texture = load(texture_path)
		print("📌 Ending-Texture erfolgreich geladen")
	else:
		print("⚠️ FEHLER: Texture nicht gefunden:", texture_path)
	
	# Shader für Ending deaktivieren
	pixelate_material.set_shader_parameter("enable_pixelate", false)
	pixelate_material.set_shader_parameter("enable_posterize", false)
	pixelate_material.set_shader_parameter("grain_strength", 0.0)
	pixelate_material.set_shader_parameter("pixel_factor", 1.0)
	print("📌 Shader-Parameter gesetzt")
	
	# -------------------------
	# 🔊 NUR MUSIC BUS UNMUTEN (für Ending Music)
	# -------------------------
	var music_bus := AudioServer.get_bus_index(ending_music_bus)
	if music_bus != -1:
		AudioServer.set_bus_mute(music_bus, false)
		print("📌 Music Bus unmuted für Ending-Musik")
	
	# ⚠️ SFX und andere Busse bleiben MUTED
	# (Optional: Du kannst auch alle unmuten wenn du willst)
	
	# Ending-Musik starten
	if ending_music:
		print("📌 Starte Ending-Musik")
		_ending_player = AudioStreamPlayer.new()
		_ending_player.stream = ending_music
		_ending_player.bus = ending_music_bus
		add_child(_ending_player)
		_ending_player.play()
		print("📌 Ending-Musik läuft")
	else:
		print("⚠️ Keine Ending-Musik konfiguriert")
	
	_waiting_for_input = true
	set_process_input(true)
	print("📌 Warte auf Input (ui_accept)")
# -------------------------
# Normale Bild-Events
# -------------------------
func _apply_image_event(event_type: EventType) -> void:
	print("📌 _apply_image_event() gestartet für:", event_type)
	
	if not background or not image or not pixelate_material:
		print("⚠️ FEHLER: Nodes nicht initialisiert!")
		return
	
	background.color = Color.BLACK
	background.visible = true
	image.visible = true
	
	if EVENT_IMAGES.has(event_type):
		var texture_path = EVENT_IMAGES[event_type]
		print("📌 Lade Texture:", texture_path)
		
		if ResourceLoader.exists(texture_path):
			image.texture = load(texture_path)
			print("📌 Texture geladen")
		else:
			print("⚠️ FEHLER: Texture nicht gefunden:", texture_path)
	else:
		print("⚠️ Keine Texture für EventType:", event_type)
	
	# Shader aktivieren
	pixelate_material.set_shader_parameter("enable_pixelate", true)
	pixelate_material.set_shader_parameter("enable_posterize", true)
	pixelate_material.set_shader_parameter("grain_strength", 0.2)
	pixelate_material.set_shader_parameter("pixel_factor", 3.0)
	print("📌 Shader-Parameter gesetzt")

# -------------------------
# Input-Handhabung für Ending
# -------------------------
func _input(event: InputEvent) -> void:
	if _waiting_for_input and event.is_action_pressed("ui_accept"):
		print("📌 Input erkannt! Beende Spiel...")
		_waiting_for_input = false
		
		# Optional: Fade out
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, 1.0)
		await tween.finished
		
		# Szene wechseln
		get_tree().change_scene_to_file("res://scenes/mainMenu.tscn")
