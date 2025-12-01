extends Control

@onready var container: Control = $Container
@onready var progress_bar: ProgressBar = $Container/ProgressBar

# Farben für ProgressBar
var color_start: Color = Color(0.0, 0.7, 1.0)  # blau
var color_end: Color   = Color(1.0, 0.0, 0.0)  # rot

# StyleBox-Referenz speichern
var fg_style: StyleBoxFlat

func _ready():
	visible = false
	
	# ProgressBar StyleBox erstellen
	fg_style = StyleBoxFlat.new()
	fg_style.bg_color = color_start
	fg_style.set_border_width_all(2)
	fg_style.border_color = Color.WHITE
	
	# Setze auch den Background (optional, für besseren Look)
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.2, 0.2, 0.2, 0.8)
	bg_style.set_border_width_all(2)
	bg_style.border_color = Color.WHITE
	
	progress_bar.add_theme_stylebox_override("fill", fg_style)
	progress_bar.add_theme_stylebox_override("background", bg_style)
	
	# Wichtig: Min/Max Werte setzen
	progress_bar.min_value = 0
	progress_bar.max_value = 100
	progress_bar.value = 0

func show_power(value: float):
	visible = true
	
	# Setze Wert
	progress_bar.value = clamp(value * 100.0, 0, 100)
	
	# Farbe interpolieren je nach Wert (blau -> rot)
	var col = color_start.lerp(color_end, progress_bar.value / 100.0)
	
	# WICHTIG: Ändere die Farbe direkt am gespeicherten StyleBox
	if fg_style:
		fg_style.bg_color = col
	
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
	progress_bar.value = 0
