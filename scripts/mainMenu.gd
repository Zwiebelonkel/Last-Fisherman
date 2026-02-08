extends Node3D

@export var options: Node
var optionsActive: bool = false

# Preload Modal
const CONFIRM_RESET_MODAL = preload("res://scenes/ConfirmResetModal.tscn")

# References zu den UI-Elementen
@onready var ui_animations = $UI/UIAnimations
@onready var title_label = $UI/MenuContainer/TitleContainer/Label
@onready var wishlist_button = $UI/ActionButtons/WishlistPanel/Button2
@onready var start_button = $UI/MenuContainer/ButtonsContainer/Start

func _ready() -> void:
	var ani : AnimationPlayer = $DirectionalLight3D/AnimationPlayer
	ani.play("circle")
	
	# Starte UI Animationen
	start_ui_animations()
	
	# Verbinde Hover-Events für coole Effekte
	setup_button_effects()

func start_ui_animations() -> void:
	# Animationen starten automatisch via autoplay in der Scene
	pass

func setup_button_effects() -> void:
	# Start Button Effects
	if start_button:
		start_button.mouse_entered.connect(_on_start_button_hover)
		start_button.mouse_exited.connect(_on_start_button_unhover)
	
	# Wishlist Button Effects
	if wishlist_button:
		wishlist_button.mouse_entered.connect(_on_wishlist_button_hover)
		wishlist_button.mouse_exited.connect(_on_wishlist_button_unhover)

# Hover Effekte für Start Button
func _on_start_button_hover() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(start_button, "scale", Vector2(1.15, 1.15), 0.3)
	tween.parallel().tween_property(start_button, "rotation", deg_to_rad(-3), 0.3)

func _on_start_button_unhover() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(start_button, "scale", Vector2(1.0, 1.0), 0.3)
	tween.parallel().tween_property(start_button, "rotation", 0.0, 0.3)

# Hover Effekte für Wishlist Button (grüner Glow)
func _on_wishlist_button_hover() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(wishlist_button, "scale", Vector2(1.2, 1.2), 0.25)
	tween.parallel().tween_property(wishlist_button, "modulate", Color(0.6, 1.2, 0.6, 1), 0.25)
	
	# Shake Effekt
	shake_button(wishlist_button)

func _on_wishlist_button_unhover() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(wishlist_button, "scale", Vector2(1.0, 1.0), 0.3)
	tween.parallel().tween_property(wishlist_button, "modulate", Color(1, 1, 1, 1), 0.3)

# Shake Effekt für den Wishlist Button
func shake_button(button: Button) -> void:
	var original_pos = button.position
	var tween = create_tween()
	tween.set_loops(3)
	tween.tween_property(button, "position", original_pos + Vector2(3, 0), 0.05)
	tween.tween_property(button, "position", original_pos + Vector2(-3, 0), 0.05)
	tween.tween_callback(func(): button.position = original_pos)

# ESC-Handling
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("pause"):  # ESC-Taste
		if optionsActive:
			hideSettings()

# Button Click Handlers
func _on_button_pressed() -> void:
	# Click Animation
	animate_button_click(start_button)
	await get_tree().create_timer(0.2).timeout
	
	Player.update_last_scene("res://scenes/MainScene.tscn")
	Transition.change_scene("res://scenes/MainScene.tscn", 0.8)

func _on_reset_button_pressed() -> void:
	# Zeige Confirm Modal
	show_reset_confirmation()

func show_reset_confirmation() -> void:
	var modal = CONFIRM_RESET_MODAL.instantiate()
	add_child(modal)
	
	# Verbinde Signals
	modal.confirm_reset.connect(_on_reset_confirmed)
	modal.cancel_reset.connect(_on_reset_cancelled)

func _on_reset_confirmed() -> void:
	print("Reset bestätigt!")
	
	# Reset durchführen
	Player.reset()
	Player.save_game()
	
	# Fade out Effekt
	var fade_overlay = ColorRect.new()
	fade_overlay.color = Color(0, 0, 0, 0)
	fade_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	$UI.add_child(fade_overlay)
	
	var tween = create_tween()
	tween.tween_property(fade_overlay, "color", Color(0, 0, 0, 1), 0.5)
	await tween.finished
	
	get_tree().reload_current_scene()

func _on_reset_cancelled() -> void:
	print("Reset abgebrochen")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_settings_pressed() -> void:
	if optionsActive:
		hideSettings()
	elif !optionsActive:
		showSettings()

func showSettings() -> void:
	options.modulate = Color(1, 1, 1, 0)
	options.show()
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(options, "modulate", Color(1, 1, 1, 1), 0.3)
	
	optionsActive = true

func hideSettings() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(options, "modulate", Color(1, 1, 1, 0), 0.2)
	await tween.finished
	
	options.hide()
	optionsActive = false

func _on_credits_pressed() -> void:
	Transition.change_scene("res://scenes/credits.tscn", 0.5)

# 🆕 Submit your fish - Google Forms (mit Animation)
func _on_submit_fish_pressed() -> void:
	var submit_button = $UI/ActionButtons/SubmitFishPanel/Button
	animate_button_click(submit_button)
	await get_tree().create_timer(0.15).timeout
	
	OS.shell_open("https://docs.google.com/forms/d/e/1FAIpQLSeNz33Jtbl9iz90gy_N_YITzMgdQWv42qW-uAbpcQ-FguplpA/viewform")

# 🆕 Wishlist now - Steam Store (mit grüner Explosion)
func _on_wishlist_pressed() -> void:
	# Grüner Flash Effekt
	var flash = ColorRect.new()
	flash.color = Color(0.2, 1, 0.3, 0)
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	$UI.add_child(flash)
	
	var tween = create_tween()
	tween.tween_property(flash, "color", Color(0.2, 1, 0.3, 0.4), 0.1)
	tween.tween_property(flash, "color", Color(0.2, 1, 0.3, 0), 0.3)
	tween.tween_callback(flash.queue_free)
	
	# Button Animation
	animate_wishlist_explosion(wishlist_button)
	await get_tree().create_timer(0.2).timeout
	
	OS.shell_open("https://store.steampowered.com/app/4262030/Last_Fisherman/")

# Generische Button Click Animation
func animate_button_click(button: Button) -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(button, "scale", Vector2(0.9, 0.9), 0.1)
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.2)

# Spezielle Wishlist Explosion Animation
func animate_wishlist_explosion(button: Button) -> void:
	var tween = create_tween()
	
	# Pulse
	tween.set_parallel(true)
	tween.tween_property(button, "scale", Vector2(1.3, 1.3), 0.15)
	tween.tween_property(button, "modulate", Color(0.4, 1.5, 0.4, 1), 0.15)
	tween.tween_property(button, "rotation", deg_to_rad(5), 0.15)
	
	# Return
	tween.chain()
	tween.set_parallel(true)
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.2)
	tween.tween_property(button, "modulate", Color(1, 1, 1, 1), 0.2)
	tween.tween_property(button, "rotation", 0.0, 0.2)
	
	# Particles Effekt simulieren
	create_green_particles(button.global_position)

# Grüne Partikel für Wishlist Button
func create_green_particles(pos: Vector2) -> void:
	for i in range(12):
		var particle = ColorRect.new()
		particle.size = Vector2(8, 8)
		particle.color = Color(0.3 + randf() * 0.4, 0.8 + randf() * 0.2, 0.3, 1)
		particle.position = pos
		$UI.add_child(particle)
		
		var angle = (i / 12.0) * TAU
		var distance = 80 + randf() * 40
		var target = pos + Vector2(cos(angle), sin(angle)) * distance
		
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "position", target, 0.6)
		tween.tween_property(particle, "modulate", Color(1, 1, 1, 0), 0.6)
		tween.tween_property(particle, "scale", Vector2(0, 0), 0.6)
		tween.tween_callback(particle.queue_free)
