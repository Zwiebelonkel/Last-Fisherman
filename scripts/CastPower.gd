extends Control

@onready var container: Control = $Container
@onready var progress_bar: ProgressBar = $Container/ProgressBar

# Farben für ProgressBar
var color_start: Color = Color(0.0, 0.7, 1.0)  # blau
var color_end: Color   = Color(1.0, 0.0, 0.0)  # rot

func _ready():
	visible = false
	# ProgressBar StyleBox
	var style = StyleBoxFlat.new()
	style.bg_color = color_start
	style.set_border_width_all(2)
	progress_bar.add_theme_stylebox_override("fg", style)

func show_power(value: float):
	visible = true
	# Setze Wert
	progress_bar.value = clamp(value * 100.0, 0, 100)
	
	# Farbe interpolieren je nach Wert (blau -> rot)
	var col = color_start.lerp(color_end, progress_bar.value / 100.0)
	var style: StyleBoxFlat = progress_bar.get_theme_stylebox("fg")
	if style:
		style.bg_color = col
	
	# Shake-Effekt, stärker bei hoher Aufladung
	if progress_bar.value >= 90:
		var shake_amount = lerp(1.0, 6.0, (progress_bar.value - 90) / 10.0)
		container.position = Vector2(randf_range(-shake_amount, shake_amount),
									 randf_range(-shake_amount, shake_amount))
	else:
		container.position = Vector2.ZERO

func hide_power():
	visible = false
	container.position = Vector2.ZERO
