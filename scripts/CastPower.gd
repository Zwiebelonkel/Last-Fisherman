extends Control
   
@onready var progress_bar: ProgressBar = $ProgressBar
   
func _ready():
	visible = false
	
func show_power(value: float):
	visible = true
	progress_bar.value = value * 100.0
   
func hide_power():
	visible = false
