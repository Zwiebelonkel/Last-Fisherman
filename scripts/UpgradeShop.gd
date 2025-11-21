extends Node3D

@onready var grip_button: Button = $UI/Panel/GripButton
@onready var bait_button: Button = $UI/Panel/BaitButton
@onready var line_button: Button = $UI/Panel/LineButton
@onready var money_label: Label = $UI/MoneyLabel
@onready var rod_preview: Node3D = $RodPreview

var grip_cost := 50
var bait_cost := 75
var line_cost := 100

func _ready():
	update_ui()

func update_ui():
	money_label.text = str(Player.money) + " €"

	grip_button.text = "Griff: Level " + str(Player.upgrade_grip) + "\n(" + str(grip_cost) + "€)"
	bait_button.text  = "Köder: Level " + str(Player.upgrade_bait) + "\n(" + str(bait_cost) + "€)"
	line_button.text  = "Faden: Level " + str(Player.upgrade_line) + "\n(" + str(line_cost) + "€)"

func _process(delta):
	# leichte Rotation der Angel
	rod_preview.rotate_y(delta * 0.5)


func _on_GripButton_pressed():
	if Player.money >= grip_cost:
		Player.money -= grip_cost
		Player.upgrade_grip += 1
		grip_cost = int(grip_cost * 1.3)
		update_ui()

func _on_BaitButton_pressed():
	if Player.money >= bait_cost:
		Player.money -= bait_cost
		Player.upgrade_bait += 1
		bait_cost = int(bait_cost * 1.3)
		update_ui()

func _on_LineButton_pressed():
	if Player.money >= line_cost:
		Player.money -= line_cost
		Player.upgrade_line += 1
		line_cost = int(line_cost * 1.3)
		update_ui()

func _on_BackButton_pressed():
	get_tree().change_scene_to_file("res://scenes/MainScene.tscn")
