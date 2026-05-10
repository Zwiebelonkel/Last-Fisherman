extends Control

@onready var click: AudioStreamPlayer = $Audio/click
@onready var graphics_window: Panel = $GraphicsWindow
@onready var godray_control: CheckButton = $GraphicsWindow/VBoxContainer/GodrayControl
@onready var glow_control: CheckButton = $GraphicsWindow/VBoxContainer/GlowControl
@onready var fog_quality_control: OptionButton = $GraphicsWindow/VBoxContainer/FogRow/FogQualityControl

func _ready() -> void:
	$Panel/VBoxContainer/CRTControl.button_pressed = Player.crt_enabled
	_sync_graphics_controls()

func _sync_graphics_controls() -> void:
	godray_control.set_pressed_no_signal(Player.godray_enabled)
	glow_control.set_pressed_no_signal(Player.glow_enabled)
	fog_quality_control.select(min(max(Player.fog_quality, 0), fog_quality_control.item_count - 1))

func _on_menu_pressed() -> void:
	get_tree().paused = false
	click.play()
	Engine.time_scale = 1
	Player.save_game()
	Transition.back_to_main()
	
func _on_stats_pressed() -> void:
	var stats = $StatsUI
	stats.show()
	click.play()

func _on_graphics_pressed() -> void:
	_sync_graphics_controls()
	graphics_window.show()
	click.play()

func _on_graphics_back_pressed() -> void:
	graphics_window.hide()
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
	for child in node.get_children():
		if child.name == "CRT":
			child.visible = enabled
		_set_crt_visible(child, enabled)
