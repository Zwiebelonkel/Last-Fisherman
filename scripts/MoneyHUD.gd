extends PanelContainer

const NumberFormat = preload("res://scripts/NumberFormat.gd")

@onready var money_label: Label = $MarginContainer/MoneyLabel

func _process(_delta: float) -> void:
	money_label.text = NumberFormat.compact(Player.money) + " $"
