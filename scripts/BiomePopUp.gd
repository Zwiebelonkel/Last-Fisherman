extends Control

@onready var label = $Panel/MarginContainer/VBox/HBox/Label
@onready var progress_bar = $Panel/MarginContainer/VBox/ProgressBar


func show_popup(text: String, biome: String = "", percent: int = 0) -> void:
	label.text = text

	# Biome-Farbe bestimmen
	var biome_color: Color = Player.BIOME_COLORS.get(biome, Color(0.2, 0.75, 1.0))

	# ProgressBar einfärben
	progress_bar.modulate = biome_color

	# Progress animieren
	progress_bar.value = 0
	var tween_bar = create_tween()
	tween_bar.set_ease(Tween.EASE_OUT)
	tween_bar.set_trans(Tween.TRANS_CUBIC)
	tween_bar.tween_property(progress_bar, "value", float(percent), 0.6)

	# Slide-in von rechts
	var viewport_size = get_viewport_rect().size
	var popup_width = offset_right
	position = Vector2(viewport_size.x, viewport_size.y * 0.08)
	modulate.a = 1.0

	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "position:x", viewport_size.x - popup_width, 0.4)

	await get_tree().create_timer(3.2).timeout

	# Slide-out nach rechts
	var tween2 = create_tween()
	tween2.set_ease(Tween.EASE_IN)
	tween2.set_trans(Tween.TRANS_CUBIC)
	tween2.tween_property(self, "position:x", viewport_size.x + 20.0, 0.35)
	tween2.parallel().tween_property(self, "modulate:a", 0.0, 0.3)

	await tween2.finished
	queue_free()
