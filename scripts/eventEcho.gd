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
	ICE_STORM
}

# -------------------------
# Bild-Zuordnung
# -------------------------
const EVENT_IMAGES := {
	EventType.BEACH: "res://assets/echos/beach.png",
	EventType.CITY: "res://assets/echos/city.png",
	EventType.DESERT: "res://assets/echos/desert.png",
	EventType.FOREST: "res://assets/echos/forest.png",
	EventType.SEWER: "res://assets/echos/sewer.png",
	EventType.ICE_STORM: "res://assets/echos/ice.png"
}

# -------------------------
# Node-Referenzen
# -------------------------
@onready var background: ColorRect = $ColorRect
@onready var image: TextureRect = $image
@onready var label: RichTextLabel = $CanvasLayer/textContainer/Label
@onready var pixelate_material: ShaderMaterial = $Filter/PixelateOverlay.material


# -------------------------
# Öffentliche API
# -------------------------
func set_event(event_type: EventType, text: String) -> void:
	label.start_typewriter(text)
	_apply_image_event(event_type)


# -------------------------
# Normale Bild-Events
# -------------------------
func _apply_image_event(event_type: EventType) -> void:
	# Schwarzer Hintergrund
	background.color = Color(0, 0, 0, 1)

	# Bild anzeigen
	image.visible = true
	if EVENT_IMAGES.has(event_type):
		image.texture = load(EVENT_IMAGES[event_type])

	# Shader normal aktiv
	pixelate_material.set_shader_parameter("enable_pixelate", true)
	pixelate_material.set_shader_parameter("enable_posterize", true)
	pixelate_material.set_shader_parameter("grain_strength", 0.2)
	pixelate_material.set_shader_parameter("pixel_factor", 3.0)


# -------------------------
# Eissturm / Whiteout
# -------------------------
func _apply_ice_storm() -> void:
	# Weißer Screen
	background.color = Color(1, 1, 1, 1)

	# Kein Bild
	image.visible = false

	# Shader extrem ruhig
	pixelate_material.set_shader_parameter("enable_pixelate", false)
	pixelate_material.set_shader_parameter("enable_posterize", false)
	pixelate_material.set_shader_parameter("grain_strength", 0.05)
	pixelate_material.set_shader_parameter("pixel_factor", 1.0)
