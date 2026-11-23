extends Resource
class_name Order

const NumberFormat = preload("res://scripts/NumberFormat.gd")

var fish_type: String = ""
var preparation_type: String = ""  # "Roh", "Backfisch", "Sushi"
var wants_drink: bool = false
var base_payment: float = 0.0

func _init() -> void:
	pass

func get_description() -> String:
	var drink_text = " + Getraenk" if wants_drink else ""
	return "%s (%s)%s - $%s" % [fish_type, preparation_type, drink_text, NumberFormat.compact(base_payment, 2)]
