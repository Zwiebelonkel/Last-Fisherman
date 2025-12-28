extends Control

@export var animation_player: AnimationPlayer
@export var animation_name := "day_cycle"

# 🔑 WICHTIG: pro Szene setzen!
@export_range(0.0, 60.0, 0.1)
var day_time_offset_seconds := 0.0

@onready var time_label: Label = $Panel/TimeLabel

const DAY_LENGTH := 60.0 # Sekunden = 24h

func _process(_delta: float) -> void:
	if not animation_player:
		return
	
	if animation_player.current_animation != animation_name:
		return
	
	var anim_pos := animation_player.current_animation_position
	
	# 🔁 Offset addieren + sauber wrappen
	var world_time := fposmod(anim_pos + day_time_offset_seconds, DAY_LENGTH)
	
	time_label.text = _format_time(world_time)


func _format_time(seconds: float) -> String:
	var day_fraction := seconds / DAY_LENGTH
	var total_minutes := int(day_fraction * 24.0 * 60.0)

	var hours := total_minutes / 60
	var minutes := total_minutes % 60

	return "%02d:%02d" % [hours, minutes]
