extends Control

const GraphicsPanel := preload("res://scripts/GraphicsSettingsPanel.gd")

@onready var click: AudioStreamPlayer = $Audio/click
@onready var graphics_window: GraphicsPanel = $GraphicsWindow
@onready var stats_ui: Control = $StatsUI

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	$Panel/VBoxContainer/CRTControl.set_pressed_no_signal(Player.crt_enabled)
	_sync_graphics_controls()
	graphics_window.back_requested.connect(_on_graphics_back_pressed)
	visibility_changed.connect(_on_visibility_changed)
	_on_visibility_changed()

func _input(event: InputEvent) -> void:
	# The intro disables the fishing controller's input, so the menu must own
	# its Escape path even while that controller is suspended.
	if not is_visible_in_tree() or not event.is_action_released("pause"):
		return
	get_viewport().set_input_as_handled()
	if close_graphics_window():
		return
	hide()
	var scene := get_tree().current_scene
	var fishing := scene.get_node_or_null("PlayerCamera/FishingRod") if scene != null else null
	if fishing != null:
		fishing.set("paused", false)
	get_tree().paused = false
	Engine.time_scale = 1.0

func _on_visibility_changed() -> void:
	if not is_visible_in_tree():
		stats_ui.hide()
		graphics_window.hide()
		$Panel.show()

func _sync_graphics_controls() -> void:
	$Panel/VBoxContainer/CRTControl.set_pressed_no_signal(Player.crt_enabled)
	graphics_window.refresh_controls()

func _on_menu_pressed() -> void:
	get_tree().paused = false
	click.play()
	Engine.time_scale = 1
	Player.save_game()
	Transition.back_to_main()
	
func _on_stats_pressed() -> void:
	stats_ui.show()
	click.play()

func _on_graphics_pressed() -> void:
	$Panel.hide()
	_sync_graphics_controls()
	graphics_window.show()
	click.play()

func _on_graphics_back_pressed() -> void:
	graphics_window.hide()
	_sync_graphics_controls()
	$Panel.show()
	click.play()
	
func _on_crt_toggled(enabled: bool) -> void:
	Player.crt_enabled = enabled
	Player.save_settings()
	Player._set_crt_visible(get_tree().root, enabled)

func _on_godray_toggled(enabled: bool) -> void:
	Player.godray_enabled = enabled
	Player.save_settings()
	Player.apply_graphics_settings()

func _on_glow_toggled(enabled: bool) -> void:
	Player.glow_enabled = enabled
	Player.save_settings()
	Player.apply_graphics_settings()

func _on_fog_quality_selected(index: int) -> void:
	Player.fog_quality = min(max(index, 0), 3)
	Player.save_settings()
	Player.apply_graphics_settings()

func _set_crt_visible(node: Node, enabled: bool) -> void:
	Player._set_crt_visible(node, enabled)
		
func close_graphics_window() -> bool:
	# Existing pause controllers call this hook before resuming gameplay.
	# Close the topmost submenu first and leave the pause menu itself open.
	if stats_ui.visible:
		stats_ui.hide()
		$Panel.show()
		click.play()
		return true
	if graphics_window.visible:
		_on_graphics_back_pressed()
		return true
	
	return false
