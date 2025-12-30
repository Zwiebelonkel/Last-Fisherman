extends Resource
class_name Order

var fish_type: String = ""
var preparation_type: String = ""  # "Roh", "Backfisch", "Sushi"
var wants_drink: bool = false
var base_payment: float = 0.0

func _init() -> void:
	pass

func get_description() -> String:
	var drink_text = " + Getraenk" if wants_drink else ""
	return "%s (%s)%s - $%.2f" % [fish_type, preparation_type, drink_text, base_payment]
