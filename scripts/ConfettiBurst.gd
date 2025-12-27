extends Control

@onready var left: GPUParticles2D = $LeftEmitter
@onready var right: GPUParticles2D = $RightEmitter

const PARTICLES := {
	FishDB.RARITY.NORMAL: preload("res://assets/particles/dropletNormal.png"),
	FishDB.RARITY.UNGEWOEHNLICH: preload("res://assets/particles/dropletUncommon.png"),
	FishDB.RARITY.SELTEN: preload("res://assets/particles/dropletRare.png"),
	FishDB.RARITY.LEGENDAER: preload("res://assets/particles/dropletLegendary.png"),
	FishDB.RARITY.EXOTISCH: preload("res://assets/particles/dropletExotic.png"),
	FishDB.RARITY.ANTIK: preload("res://assets/particles/dropletExotic.png")
}

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func play_confetti(rarity: int, color: Color) -> void:
	var screen: Vector2 = get_viewport().get_visible_rect().size

	# Positionen: untere Ecken
	left.position = Vector2(0, screen.y)
	right.position = Vector2(screen.x, screen.y)

	var tex: Texture2D = PARTICLES.get(rarity, PARTICLES[FishDB.RARITY.NORMAL])
	left.texture = tex
	right.texture = tex

	left.modulate = color
	right.modulate = color

	left.restart()
	right.restart()
	left.emitting = true
	right.emitting = true
