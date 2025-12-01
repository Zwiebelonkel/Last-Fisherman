extends Control

@onready var panel: Panel = $"Panel"
@onready var fish_icon: TextureRect = $VBoxContainer/MarginContainer/PanelContainer/MarginContainer/FishIcon
@onready var fish_name: Label = $VBoxContainer/MarginContainer2/FishName
@onready var fish_rarity: Label = $VBoxContainer/MarginContainer3/FishRarity
@onready var fish_value: Label = $VBoxContainer/MarginContainer4/FishValue
@onready var fish_weight: Label = $VBoxContainer/MarginContainer5/FishWeight  # NEU
@onready var new_label: Label = $NewLabel  # NEU - direkt unter Control
@onready var continue_button: Button = $ContinueButton
@onready var anim: AnimationPlayer = $VBoxContainer/AnimationPlayer
@onready var splash: GPUParticles2D = $Splash

var current_fish: Dictionary

# Partikel-Texturen je Seltenheit
const SPLASH_COMMON      := preload("res://assets/particles/dropletNormal.png")
const SPLASH_UNCOMMON    := preload("res://assets/particles/dropletUncommon.png")
const SPLASH_RARE        := preload("res://assets/particles/dropletRare.png")
const SPLASH_EPIC        := preload("res://assets/particles/dropletEpic.png")
const SPLASH_LEGENDARY   := preload("res://assets/particles/dropletLegendary.png")
const SPLASH_EXOTIC      := preload("res://assets/particles/dropletExotic.png")

# Shine-Shader
const SHINE_SHADER := preload("res://shader/2DShine.gdshader")

func _ready() -> void: 
	visible = false
	continue_button.pressed.connect(_on_continue_pressed)
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cast"):
		_on_continue_pressed()
		return

func show_fish(fish: Dictionary) -> void:
	current_fish = fish
	visible = true
	
	# Prüfe ob Fisch neu ist (wurde bereits beim Generieren gesetzt)
	var is_new_catch: bool = fish.get("is_new_catch", false)
	var ani : AnimationPlayer = $NewLabel/AnimationPlayer
	
	print("DEBUG NEW Label - Fisch:", fish["name"], "| Ist neu?", is_new_catch)
	
	# NEW Label anzeigen/verstecken
	if new_label:
		new_label.visible = is_new_catch
		ani.play("idle")
		print("DEBUG - NewLabel visible gesetzt auf:", is_new_catch)
	else:
		print("ERROR - NewLabel nicht gefunden!")
	
	# Icon & Texte
	fish_icon.texture = _get_fish_icon(fish)
	fish_name.text = fish["name"]
	
	var rarity_data: Dictionary = FishDB.RARITY_DATA[fish["rarity"]]
	var rarity_color: Color = rarity_data["color"]
	
	fish_rarity.text = rarity_data["name"]
	fish_rarity.modulate = rarity_color
	
	var total_value: int = int(fish["base_value"] * rarity_data["value"])
	fish_value.text = str(total_value) + " €"
	
	# Gewicht anzeigen (aus fish Dictionary)
	if fish_weight and fish.has("weight"):
		fish_weight.text = "Gewicht: " + str(fish["weight"]) + " kg"
	
	# Panel-Rand + Shine-Farbe
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.7) 
	style.border_color = rarity_color
	style.set_border_width_all(5)
	panel.add_theme_stylebox_override("panel", style)
	
	# Shine Shader Material setzen
	var mat := ShaderMaterial.new()
	mat.shader = SHINE_SHADER
	panel.material = mat
	panel.material.set_shader_parameter("ShineColor", rarity_color)
	
	# Partikel-Textur nach Rarität
	_set_splash_texture_for_rarity(fish["rarity"])
	splash.emitting = false
	splash.restart()
	
	# Animation
	if anim.has_animation("pop"):
		anim.play("pop")

func _get_fish_icon(fish: Dictionary) -> Texture2D:
	if fish.has("icon"):
		var icon_path: String = fish["icon"]
		var tex: Texture2D = load(icon_path)
		if tex:
			return tex
	return preload("res://assets/fish/unknown.png")

func _set_splash_texture_for_rarity(rarity: int) -> void:
	var tex: Texture2D = null
	match rarity:
		FishDB.RARITY.NORMAL:
			tex = SPLASH_COMMON
		FishDB.RARITY.UNGEWOEHNLICH:
			tex = SPLASH_UNCOMMON
		FishDB.RARITY.SELTEN:
			tex = SPLASH_RARE
		FishDB.RARITY.EPISCH:
			tex = SPLASH_EPIC
		FishDB.RARITY.LEGENDAER:
			tex = SPLASH_LEGENDARY
		FishDB.RARITY.EXOTISCH:
			tex = SPLASH_EXOTIC
		_:
			tex = SPLASH_COMMON
	
	if tex:
		splash.texture = tex

func _on_continue_pressed() -> void:
	visible = false
