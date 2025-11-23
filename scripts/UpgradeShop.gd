extends Node3D
@onready var grip_button: Button = $UI/Panel/GripButton
@onready var bait_button: Button = $UI/Panel/BaitButton
@onready var line_button: Button = $UI/Panel/LineButton
@onready var money_label: Label = $UI/MoneyLabel
@onready var rod_preview: Node3D = $RodPreview
@onready var music: AudioStreamPlayer = $Audio/music
@onready var interact: AudioStreamPlayer = $Audio/interact


var base_grip_cost := 50
var base_bait_cost := 75
var base_line_cost := 100

func _ready():
	update_ui()

func calculate_cost(base_cost: int, level: int) -> int:
	return int(base_cost * pow(1.3, level - 1))

func update_ui():
	money_label.text = str(Player.money) + " €"
	
	var grip_cost = calculate_cost(base_grip_cost, Player.upgrade_grip)
	var bait_cost = calculate_cost(base_bait_cost, Player.upgrade_bait)
	var line_cost = calculate_cost(base_line_cost, Player.upgrade_line)
	
	grip_button.text = "Griff: Level " + str(Player.upgrade_grip) + "\n(" + str(grip_cost) + "€)"
	bait_button.text  = "Köder: Level " + str(Player.upgrade_bait) + "\n(" + str(bait_cost) + "€)"
	line_button.text  = "Faden: Level " + str(Player.upgrade_line) + "\n(" + str(line_cost) + "€)"

func _process(delta):
	# leichte Rotation der Angel
	rod_preview.rotate_y(delta * 0.5)

func _on_GripButton_pressed():
	var grip_cost = calculate_cost(base_grip_cost, Player.upgrade_grip)
	if Player.money >= grip_cost:
		Player.money -= grip_cost
		Player.upgrade_grip += 1
		Player.save_game()
		interact.play()
		update_ui()

func _on_BaitButton_pressed():
	var bait_cost = calculate_cost(base_bait_cost, Player.upgrade_bait)
	if Player.money >= bait_cost:
		Player.money -= bait_cost
		Player.upgrade_bait += 1
		Player.save_game()
		interact.play()

		update_ui()

func _on_LineButton_pressed():
	var line_cost = calculate_cost(base_line_cost, Player.upgrade_line)
	if Player.money >= line_cost:
		Player.money -= line_cost
		Player.upgrade_line += 1
		Player.save_game()
		interact.play()
		update_ui()

func _on_BackButton_pressed():
	Player.go_to_last_scene()
