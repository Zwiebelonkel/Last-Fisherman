extends Control

@export var animation_player: AnimationPlayer
@export var animation_name := "day_cycle"

# 🔑 WICHTIG: pro Szene setzen!
@export_range(0.0, 60.0, 0.1)
var day_time_offset_seconds := 0.0

@onready var time_label: Label = $Panel/TimeLabel

const DAY_LENGTH := 60.0 # Sekunden = 24h

var _location_key := ""
var _cycle_position := 0.0
var _time_initialized := false

func _ready() -> void:
	add_to_group("location_clocks")
	# Parent controllers start their day-cycle animation in _ready(). Restore after that.
	_restore_time.call_deferred()

func _restore_time() -> void:
	if not is_inside_tree():
		return
	var scene: Node = self
	while scene.get_parent() != null and scene.get_parent() != get_tree().root:
		scene = scene.get_parent()
	_location_key = scene.scene_file_path
	if _location_key.is_empty() or scene == self:
		return
	if Player.location_times.has(_location_key):
		_cycle_position = float(Player.location_times[_location_key])
		if is_instance_valid(animation_player) and animation_player.has_animation(animation_name):
			var length := animation_player.get_animation(animation_name).length
			_cycle_position = fposmod(_cycle_position, maxf(length, 0.001))
			animation_player.play(animation_name)
			animation_player.seek(_cycle_position, true)
	_time_initialized = true
	capture_time()
	_update_label()

func capture_time() -> void:
	if not _time_initialized:
		return
	# Cache the last position too: the animation node may leave the tree before this UI.
	if is_instance_valid(animation_player) and animation_player.is_inside_tree():
		if animation_player.assigned_animation == animation_name:
			_cycle_position = animation_player.current_animation_position
	Player.location_times[_location_key] = _cycle_position

func reset_time() -> void:
	_cycle_position = 0.0
	if is_instance_valid(animation_player) and animation_player.has_animation(animation_name):
		animation_player.seek(0.0, true)
	_update_label()

func _exit_tree() -> void:
	if _time_initialized and is_instance_valid(Player):
		capture_time()
		Player.save_game()

func _process(_delta: float) -> void:
	if not _time_initialized:
		return
	capture_time()
	_update_label()

func _update_label() -> void:
	# 🔁 Offset addieren + sauber wrappen
	var world_time := fposmod(_cycle_position + day_time_offset_seconds, DAY_LENGTH)
	
	time_label.text = _format_time(world_time)


func _format_time(seconds: float) -> String:
	var day_fraction := seconds / DAY_LENGTH
	var total_minutes := int(day_fraction * 24.0 * 60.0)

	var hours := total_minutes / 60
	var minutes := total_minutes % 60

	return "%02d:%02d" % [hours, minutes]
