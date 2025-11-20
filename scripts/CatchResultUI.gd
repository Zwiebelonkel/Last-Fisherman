extends PanelContainer

@onready var fish_icon: TextureRect = $VBoxContainer/FishIcon
@onready var fish_name: Label = $VBoxContainer/FishName
@onready var fish_rarity: Label = $VBoxContainer/FishRarity
@onready var fish_value: Label = $VBoxContainer/FishValue
@onready var continue_button: Button = $VBoxContainer/ContinueButton
@onready var anim: AnimationPlayer = $VBoxContainer/AnimationPlayer

var current_fish: Dictionary

func _ready():
	visible = false
	continue_button.pressed.connect(_on_continue_pressed)


func show_fish(fish: Dictionary):
	current_fish = fish
	visible = true

	# Füllen
	fish_icon.texture = preload("res://textures/NEURA_Logo.jpeg") # Platzhalter
	fish_name.text = fish["name"]

	var rarity_data = FishDB.RARITY_DATA[fish["rarity"]]
	fish_rarity.text = rarity_data["name"]
	fish_rarity.modulate = rarity_data["color"]

	var total_value = int(fish["base_value"] * rarity_data["value"])
	fish_value.text = str(total_value) + " €"

	# Rahmenfarb-Override
	self.modulate = Color(1, 1, 1)
	add_theme_color_override("panel", rarity_data["color"])

	# Animation
	if anim.has_animation("pop"):
		anim.play("pop")


func _on_continue_pressed():
	visible = false
