extends PanelContainer

@onready var money_label: Label = $MarginContainer/MoneyLabel

func _process(_delta: float) -> void:
	money_label.text = str(Player.money) + " $"
