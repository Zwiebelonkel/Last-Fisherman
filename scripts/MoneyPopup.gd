extends Control
class_name MoneyPopup

@onready var label: Label = $Label

func show_amount(amount: int) -> void:
	label.show()
	label.text = "+%d €" % amount
	modulate.a = 1.0
	scale = Vector2.ONE

	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)

	# leicht nach oben
	tween.tween_property(self, "position:y", position.y - 50, 0.7)

	# kleines Pop-Scaling
	tween.parallel().tween_property(self, "scale", Vector2(1.2, 1.2), 0.25)

	# ausfaden
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.7)

	await tween.finished
	queue_free()
