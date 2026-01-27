extends PanelContainer

@onready var bait_label: Label = $MarginContainer/MoneyLabel

func _process(_delta: float) -> void:
	if not Player.active_bait:
		hide()
		return

	show()

	var rarity_enum := FishDB.rarity_string_to_enum(Player.active_bait)
	if rarity_enum == -1:
		bait_label.text = tr("BAIT_NORMAL")
		return

	var rarity_key: String = FishDB.RARITY_DATA[rarity_enum]["name_key"]
	bait_label.text = tr("ACTIVE_BAIT_LABEL").format({
		"bait": tr(rarity_key)
	})
