extends PanelContainer

@onready var money_label: Label = $MarginContainer/MoneyLabel

func _process(delta: float) -> void:
	money_label.text = str(Player.money) + " €"
