extends PanelContainer

@onready var bait_label: Label = $MarginContainer/MoneyLabel

func _process(_delta: float) -> void:
	bait_label.text = "Köder: "+ str(Player.active_bait)
	
	if not Player.active_bait:
		hide()
	if Player.active_bait:
		show()
