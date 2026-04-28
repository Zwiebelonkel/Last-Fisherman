extends Control

@onready var panel: Panel = $"Panel"
@onready var fish_icon: TextureRect = $VBoxContainer/MarginContainer/PanelContainer/MarginContainer/FishIcon
@onready var fish_name: Label = $VBoxContainer/MarginContainer2/FishName
@onready var fish_rarity: Label = $VBoxContainer/MarginContainer3/FishRarity
@onready var fish_value: Label = $VBoxContainer/MarginContainer4/FishValue
@onready var fish_weight: Label = $VBoxContainer/MarginContainer5/FishWeight
@onready var new_label: Label = $NewLabel
@onready var continue_button: Button = $ContinueButton
@onready var detail_hint_label: Label = $DetailHintLabel if has_node("DetailHintLabel") else null
@onready var anim: AnimationPlayer = $VBoxContainer/AnimationPlayer
@onready var splash: GPUParticles2D = $Splash
@onready var confetti: Control = $ConfettiBurst
@onready var click: AudioStreamPlayer = $Audio/click

@onready var story_label: Label = $StoryLabel if has_node("StoryLabel") else null

var lightning_node: ColorRect
var sparkle_node: ColorRect        # ✨ NEU

var detail_popup: Control
var fish_detail_popup_scene
var current_fish: Dictionary
var _is_exiting: bool = false

const CENTER_OFFSETS := Rect2(-120.0, -150.0, 240.0, 262.0)

signal story_item_used(biome: String)

const SPLASH_COMMON      := preload("res://assets/particles/dropletNormal.png")
const SPLASH_UNCOMMON    := preload("res://assets/particles/dropletUncommon.png")
const SPLASH_RARE        := preload("res://assets/particles/dropletRare.png")
const SPLASH_EPIC        := preload("res://assets/particles/dropletEpic.png")
const SPLASH_LEGENDARY   := preload("res://assets/particles/dropletLegendary.png")
const SPLASH_EXOTIC      := preload("res://assets/particles/dropletExotic.png")
const SPLASH_ANTIK       := preload("res://assets/particles/dropletExotic.png")
const SHINE_SHADER       := preload("res://shader/2DShine.gdshader")
const SPARKLE_SHADER     := preload("res://shader/2DSparkle.gdshader")  # ✨ NEU
const LIGHTNING_SHADER   := preload("res://shader/lightning.gdshader")

# 🎴 Tilt-Parameter
const TILT_MAX_DEG   := 12.0   # maximale Neigung in Grad
const TILT_SMOOTH    := 8.0    # wie schnell folgt die Karte (höher = schneller)
var   _tilt_target   := Vector2.ZERO
var   _tilt_current  := Vector2.ZERO
var   _tilt_enabled  := false

func _ready() -> void:
	visible = false
	_reset_center_layout()
	continue_button.pressed.connect(_on_continue_pressed)
	_create_lightning_node()
	_create_sparkle_node()
	_ensure_splash_configured()
	
	# 🎴 Maus-Events für Tilt-Reset
	mouse_entered.connect(_on_card_mouse_entered)
	mouse_exited.connect(_on_card_mouse_exited)

	if fish_icon:
		fish_icon.mouse_filter = Control.MOUSE_FILTER_STOP
		fish_icon.gui_input.connect(_on_fish_icon_clicked)
		fish_icon.mouse_entered.connect(_on_fish_icon_hover.bind(true))
		fish_icon.mouse_exited.connect(_on_fish_icon_hover.bind(false))

	if ResourceLoader.exists("res://scenes/FishDetailPopup.tscn"):
		fish_detail_popup_scene = load("res://scenes/FishDetailPopup.tscn")
		detail_popup = fish_detail_popup_scene.instantiate()
		add_child(detail_popup)
		detail_popup.visible = false

func _on_card_mouse_entered() -> void:
	_tilt_enabled = true

func _on_card_mouse_exited() -> void:
	# Sanft zurück auf 0 tweenen statt hard reset
	_tilt_enabled = false
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_method(_apply_tilt, _tilt_current, Vector2.ZERO, 0.3)
	await tween.finished
	_tilt_current = Vector2.ZERO
	_tilt_target  = Vector2.ZERO
	
# ✨ Sparkle Node erstellen
func _create_sparkle_node() -> void:
	sparkle_node = ColorRect.new()
	sparkle_node.name = "SparkleEffect"
	sparkle_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sparkle_node.color = Color(0, 0, 0, 1)  # Schwarz = neutral bei blend_add
	sparkle_node.z_index = 2

	var mat := ShaderMaterial.new()
	mat.shader = SPARKLE_SHADER
	sparkle_node.material = mat
	sparkle_node.visible = false

	# Direkt als Kind dieser Node – KEIN get_tree().current_scene
	add_child(sparkle_node)
	
func _setup_sparkle_for_rarity(rarity: int, color: Color) -> void:
	if not sparkle_node:
		push_error("❌ sparkle_node ist null!")
		return
	
	var mat: ShaderMaterial = sparkle_node.material as ShaderMaterial
	if not mat:
		push_error("❌ Kein ShaderMaterial auf sparkle_node!")
		return
	if not mat.shader:
		push_error("❌ Kein Shader auf ShaderMaterial!")
		return
		
	print("✨ _setup_sparkle_for_rarity aufgerufen, rarity: ", rarity)
	
	mat.set_shader_parameter("panel_size_px", Vector2(240, 290))

	match rarity:
		FishDB.RARITY.NORMAL, FishDB.RARITY.UNGEWOEHNLICH:
			sparkle_node.visible = false
			print("✨ Sparkle ausgeblendet (zu niedrige Rarität)")
			return
		FishDB.RARITY.SELTEN:
			sparkle_node.visible = true
			mat.set_shader_parameter("Sparkle_Density",    0.25)
			mat.set_shader_parameter("Sparkle_Brightness", 1.5)
			mat.set_shader_parameter("Sparkle_Twinkle",    3.0)
			mat.set_shader_parameter("Chrome_Intensity",   0.08)
		FishDB.RARITY.EPISCH:
			sparkle_node.visible = true
			mat.set_shader_parameter("Sparkle_Density",    0.4)
			mat.set_shader_parameter("Sparkle_Brightness", 2.5)
			mat.set_shader_parameter("Sparkle_Twinkle",    4.0)
			mat.set_shader_parameter("Chrome_Intensity",   0.12)
		FishDB.RARITY.LEGENDAER:
			sparkle_node.visible = true
			mat.set_shader_parameter("Sparkle_Density",    0.6)
			mat.set_shader_parameter("Sparkle_Brightness", 3.5)
			mat.set_shader_parameter("Sparkle_Twinkle",    5.5)
			mat.set_shader_parameter("Chrome_Intensity",   0.18)
			mat.set_shader_parameter("Sparkle_Color_A",    Color(1.0, 0.85, 0.2, 1.0))
			mat.set_shader_parameter("Sparkle_Color_B",    Color(1.0, 1.0,  0.6, 1.0))
		FishDB.RARITY.EXOTISCH:
			sparkle_node.visible = true
			mat.set_shader_parameter("Sparkle_Density",    0.75)
			mat.set_shader_parameter("Sparkle_Brightness", 4.5)
			mat.set_shader_parameter("Sparkle_Twinkle",    6.0)
			mat.set_shader_parameter("Chrome_Intensity",   0.22)
		FishDB.RARITY.ANTIK:
			sparkle_node.visible = true
			mat.set_shader_parameter("Sparkle_Density",    0.92)
			mat.set_shader_parameter("Sparkle_Brightness", 5.5)
			mat.set_shader_parameter("Sparkle_Twinkle",    7.0)
			mat.set_shader_parameter("Chrome_Intensity",   0.3)

	mat.set_shader_parameter("Sparkle_Color_A", color)
	mat.set_shader_parameter("Chrome_Scale", 2.0)   # war 6.0, kleiner = gröbere Wellen
	print("✨ Sparkle aktiv, visible: ", sparkle_node.visible, " color: ", color)
# 🎴 Cursor-Tilt per _process
func _process(delta: float) -> void:
	if not _tilt_enabled or not visible:
		return

	var mouse_pos  : Vector2 = get_global_mouse_position()
	var card_center: Vector2 = global_position + size * 0.5
	var rel        : Vector2 = (mouse_pos - card_center) / (size * 0.5)
	rel = rel.clamp(Vector2(-1, -1), Vector2(1, 1))

	_tilt_target = Vector2(rel.y, rel.x) * TILT_MAX_DEG
	_tilt_current = _tilt_current.lerp(_tilt_target, delta * TILT_SMOOTH)
	_apply_tilt(_tilt_current)
	
func _apply_tilt(tilt: Vector2) -> void:
	pivot_offset = size * 0.5
	var depth_scale: float = 1.0 + (abs(tilt.y) + abs(tilt.x)) * 0.003
	scale = Vector2(depth_scale, depth_scale)
	rotation = deg_to_rad(tilt.y * 0.3)

func _reset_tilt() -> void:
	_tilt_enabled = false
	_tilt_current = Vector2.ZERO
	_tilt_target  = Vector2.ZERO
	scale         = Vector2.ONE
	rotation      = 0.0
	pivot_offset  = Vector2.ZERO
func _ensure_splash_configured() -> void:
	if not splash:
		push_warning("⚠️ Splash node nicht gefunden - wird übersprungen")
		return

	if not splash.process_material:
		var mat = ParticleProcessMaterial.new()
		mat.particle_flag_disable_z = true
		mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
		mat.emission_sphere_radius = 100.0
		mat.direction = Vector3(0, 0, 0)
		mat.spread = 180.0
		mat.initial_velocity_min = 150.0
		mat.initial_velocity_max = 250.0
		mat.angular_velocity_min = -180.0
		mat.angular_velocity_max = 180.0
		mat.gravity = Vector3(0, 200, 0)
		mat.scale_min = 1.0
		mat.scale_max = 2.0

		var scale_curve = Curve.new()
		scale_curve.add_point(Vector2(0, 1))
		scale_curve.add_point(Vector2(0.5, 1.2))
		scale_curve.add_point(Vector2(1, 0))
		var scale_texture = CurveTexture.new()
		scale_texture.curve = scale_curve
		mat.scale_curve = scale_texture

		var gradient = Gradient.new()
		gradient.set_color(0, Color(1, 1, 1, 1))
		gradient.set_color(1, Color(1, 1, 1, 0))
		gradient.add_point(0.3, Color(1, 1, 1, 1))
		gradient.add_point(0.7, Color(1, 1, 1, 0.8))
		var gradient_texture = GradientTexture1D.new()
		gradient_texture.gradient = gradient
		mat.color_ramp = gradient_texture
		splash.process_material = mat

	splash.emitting = false
	splash.amount = 50
	splash.lifetime = 1.2
	splash.one_shot = true
	splash.explosiveness = 1.0
	splash.randomness = 0.5

	if ResourceLoader.exists("res://assets/particles/dropletNormal.png"):
		splash.texture = load("res://assets/particles/dropletNormal.png")

# ⚡ Lightning Node Setup
func _create_lightning_node() -> void:
	lightning_node = ColorRect.new()
	lightning_node.name = "LightningEffect"
	lightning_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lightning_node.size = panel.size
	lightning_node.position = Vector2.ZERO
	add_child(lightning_node)
	lightning_node.color = Color(0, 0, 0, 0)
	var lightning_mat = ShaderMaterial.new()
	lightning_mat.shader = LIGHTNING_SHADER
	lightning_node.material = lightning_mat
	lightning_node.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if not visible or _is_exiting:
		return
	if event.is_action_pressed("cast"):
		_on_continue_pressed()

# ---------------------------------------------------------
# HAUPTFUNKTION – FISCH ANZEIGEN
# ---------------------------------------------------------
func show_fish(fish: Dictionary) -> void:
	var rarity: int = FishDB.get_rarity_safe(fish)
	current_fish = prepare_fish_data(fish)
	_reset_center_layout()
	visible = true
	_tilt_enabled = true   # 🎴 Tilt aktivieren

	var is_new_catch: bool  = fish.get("is_new_catch", false)
	var is_story_item: bool = fish.get("is_story_item", false)

	var ani_label: AnimationPlayer = $NewLabel/AnimationPlayer if has_node("NewLabel/AnimationPlayer") else null
	var rarity_color: Color = FishDB.get_rarity_color(fish)
	confetti.play_confetti(rarity, rarity_color)

	# Button / Story
	if is_story_item and rarity == FishDB.RARITY.ANTIK:
		continue_button.text = "Use"
		if story_label and fish.has("story_key"):
			story_label.visible = true
			story_label.modulate = Color.WHITE
			story_label.text = FishDB.get_fish_story(fish)
	else:
		continue_button.text = "Continue"
		if story_label:
			story_label.visible = false

	# Hint (einmalig bis angeklickt)
	if detail_hint_label:
		detail_hint_label.visible = not Player.fish_detail_hint_seen

	# NEW Label
	if new_label:
		new_label.visible = is_new_catch
		if is_new_catch and not is_story_item:
			Player.add_money(100)
		if is_new_catch and ani_label and ani_label.has_animation("idle"):
			ani_label.play("idle")

	# Icon & Texte
	fish_icon.texture = FishDB.get_fish_icon(fish)
	fish_name.text    = FishDB.get_fish_name(fish)
	fish_rarity.modulate = rarity_color
	fish_rarity.text  = tr(FishDB.get_rarity_name_key(fish))

	var display_value_text: String
	if is_story_item and rarity == FishDB.RARITY.ANTIK:
		display_value_text = tr("FISH_VALUE_PRICELESS")
		fish_value.modulate = rarity_color
	else:
		display_value_text = str(FishDB.get_fish_value(fish)) + " €"
	fish_value.text = display_value_text

	if fish_weight and fish.has("weight"):
		fish_weight.text = tr("FISH_WEIGHT") + ": %.2f kg" % fish["weight"]

	# Effekte
	_setup_lightning_for_rarity(rarity, rarity_color)
	_setup_sparkle_for_rarity(rarity, rarity_color)   # ✨ NEU
	_setup_sparkle_for_rarity(rarity, rarity_color)
	# Sparkle exakt auf Panel legen
	if sparkle_node:
		sparkle_node.position = Vector2.ZERO
		sparkle_node.size = panel.size

	# Panel Stil + Shine
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.7)
	style.border_color = rarity_color
	style.set_border_width_all(5)
	panel.add_theme_stylebox_override("panel", style)

	var mat := ShaderMaterial.new()
	mat.shader = SHINE_SHADER
	panel.material = mat
	panel.material.set_shader_parameter("ShineColor", rarity_color)
	panel.material.set_shader_parameter("panel_size_px", panel.size)

	# Splash
	_set_splash_texture_for_rarity(rarity)
	splash.position = Vector2(120, 145)

	if splash.process_material is ParticleProcessMaterial:
		var splash_mat: ParticleProcessMaterial = splash.process_material as ParticleProcessMaterial
		match rarity:
			FishDB.RARITY.NORMAL:
				splash.amount = 20; splash_mat.initial_velocity_min = 80.0;  splash_mat.initial_velocity_max = 120.0; splash_mat.scale_min = 0.8;  splash_mat.scale_max = 1.2
			FishDB.RARITY.UNGEWOEHNLICH:
				splash.amount = 30; splash_mat.initial_velocity_min = 100.0; splash_mat.initial_velocity_max = 150.0; splash_mat.scale_min = 1.0;  splash_mat.scale_max = 1.5
			FishDB.RARITY.SELTEN:
				splash.amount = 40; splash_mat.initial_velocity_min = 120.0; splash_mat.initial_velocity_max = 180.0; splash_mat.scale_min = 1.2;  splash_mat.scale_max = 1.8
			FishDB.RARITY.EPISCH:
				splash.amount = 50; splash_mat.initial_velocity_min = 150.0; splash_mat.initial_velocity_max = 220.0; splash_mat.scale_min = 1.5;  splash_mat.scale_max = 2.2
			FishDB.RARITY.LEGENDAER:
				splash.amount = 60; splash_mat.initial_velocity_min = 180.0; splash_mat.initial_velocity_max = 260.0; splash_mat.scale_min = 1.8;  splash_mat.scale_max = 2.5
			FishDB.RARITY.EXOTISCH:
				splash.amount = 75; splash_mat.initial_velocity_min = 220.0; splash_mat.initial_velocity_max = 300.0; splash_mat.scale_min = 2.0;  splash_mat.scale_max = 3.0
			FishDB.RARITY.ANTIK:
				splash.amount = 100; splash_mat.initial_velocity_min = 250.0; splash_mat.initial_velocity_max = 350.0; splash_mat.scale_min = 2.5; splash_mat.scale_max = 3.5

	splash.emitting = false
	await get_tree().process_frame
	splash.restart()
	splash.emitting = true

	if anim.has_animation("pop"):
		anim.play("pop")

	# Icon Shader
	var shadow_mat = ShaderMaterial.new()
	shadow_mat.shader = preload("res://shader/icon.gdshader")
	shadow_mat.set_shader_parameter("shadow_offset", Vector2(0, -4.5))
	shadow_mat.set_shader_parameter("shadow_color",  Color(0, 0, 0, 0.7))
	shadow_mat.set_shader_parameter("enable_bobbing",      true)
	shadow_mat.set_shader_parameter("bobbing_amplitude",   1.5)
	shadow_mat.set_shader_parameter("bobbing_speed",       2.0)
	if rarity >= FishDB.RARITY.SELTEN:
		shadow_mat.set_shader_parameter("enable_sway",    true)
		shadow_mat.set_shader_parameter("sway_amplitude", 1.1)
		shadow_mat.set_shader_parameter("sway_speed",     1.5)
	if rarity >= FishDB.RARITY.LEGENDAER or rarity == FishDB.RARITY.ANTIK:
		shadow_mat.set_shader_parameter("enable_pulse",  true)
		shadow_mat.set_shader_parameter("pulse_amount",  0.15)
		shadow_mat.set_shader_parameter("pulse_speed",   2.5)
	fish_icon.material = shadow_mat

func _reset_center_layout() -> void:
	set_anchors_preset(Control.PRESET_CENTER, false)
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BOTH
	offset_left = CENTER_OFFSETS.position.x
	offset_top = CENTER_OFFSETS.position.y
	offset_right = CENTER_OFFSETS.position.x + CENTER_OFFSETS.size.x
	offset_bottom = CENTER_OFFSETS.position.y + CENTER_OFFSETS.size.y
	position = Vector2.ZERO

# ⚡ Lightning Setup
func _setup_lightning_for_rarity(rarity: int, color: Color) -> void:
	if not lightning_node or not lightning_node.material:
		return
	var mat: ShaderMaterial = lightning_node.material as ShaderMaterial
	match rarity:
		FishDB.RARITY.NORMAL:
			lightning_node.visible = false; return
		FishDB.RARITY.UNGEWOEHNLICH:
			lightning_node.visible = true
			mat.set_shader_parameter("intensity", 0.5); mat.set_shader_parameter("light_count", 2)
			mat.set_shader_parameter("rotation_speed", 0.3); mat.set_shader_parameter("light_size", 0.006)
			mat.set_shader_parameter("trail_length", 0.1); mat.set_shader_parameter("flicker_intensity", 0.2)
		FishDB.RARITY.SELTEN:
			lightning_node.visible = true
			mat.set_shader_parameter("intensity", 0.6); mat.set_shader_parameter("light_count", 3)
			mat.set_shader_parameter("rotation_speed", 0.4); mat.set_shader_parameter("light_size", 0.007)
			mat.set_shader_parameter("trail_length", 0.15); mat.set_shader_parameter("flicker_intensity", 0.25)
		FishDB.RARITY.EPISCH:
			lightning_node.visible = true
			mat.set_shader_parameter("intensity", 0.8); mat.set_shader_parameter("light_count", 4)
			mat.set_shader_parameter("rotation_speed", 0.5); mat.set_shader_parameter("light_size", 0.008)
			mat.set_shader_parameter("trail_length", 0.2); mat.set_shader_parameter("flicker_intensity", 0.3)
		FishDB.RARITY.LEGENDAER:
			lightning_node.visible = true
			mat.set_shader_parameter("intensity", 1.0); mat.set_shader_parameter("light_count", 5)
			mat.set_shader_parameter("rotation_speed", 0.6); mat.set_shader_parameter("light_size", 0.009)
			mat.set_shader_parameter("trail_length", 0.25); mat.set_shader_parameter("flicker_intensity", 0.35)
		FishDB.RARITY.EXOTISCH:
			lightning_node.visible = true
			mat.set_shader_parameter("intensity", 1.2); mat.set_shader_parameter("light_count", 6)
			mat.set_shader_parameter("rotation_speed", 0.7); mat.set_shader_parameter("light_size", 0.01)
			mat.set_shader_parameter("trail_length", 0.3); mat.set_shader_parameter("flicker_intensity", 0.4)
		FishDB.RARITY.ANTIK:
			lightning_node.visible = true
			mat.set_shader_parameter("intensity", 1.5); mat.set_shader_parameter("light_count", 8)
			mat.set_shader_parameter("rotation_speed", 0.8); mat.set_shader_parameter("light_size", 0.012)
			mat.set_shader_parameter("trail_length", 0.35); mat.set_shader_parameter("flicker_intensity", 0.5)
	mat.set_shader_parameter("glow_color", color)

# ---------------------------------------------------------
# Continue/Use Button Handler
# ---------------------------------------------------------
func _on_continue_pressed() -> void:
	if _is_exiting:
		return
	_is_exiting = true
	#click.play()
	var is_story_item: bool = current_fish.get("is_story_item", false)
	var rarity: int         = current_fish.get("rarity", FishDB.RARITY.NORMAL)

	if is_story_item and rarity == FishDB.RARITY.ANTIK:
		var biome: String = current_fish.get("biome", "")
		if biome != "":
			story_item_used.emit(biome)

	await _play_exit_animation()

	if sparkle_node:
		sparkle_node.visible = false

	_reset_tilt()
	visible = false
	modulate = Color.WHITE
	scale = Vector2.ONE
	position = Vector2.ZERO
	_is_exiting = false
# ---------------------------------------------------------
# Icon Click / Hover
# ---------------------------------------------------------
func _on_fish_icon_clicked(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if not current_fish.is_empty():
				show_fish_detail_popup(current_fish)

func _on_fish_icon_hover(is_hovering: bool) -> void:
	if not fish_icon:
		return
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if is_hovering:
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
		tween.tween_property(fish_icon, "scale", Vector2(1.05, 1.05), 0.15)
	else:
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
		tween.tween_property(fish_icon, "scale", Vector2(1.0, 1.0), 0.15)

func _play_exit_animation() -> void:
	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate:a", 0.0, 0.18)
	tween.tween_property(self, "scale", Vector2(0.96, 0.96), 0.18)
	tween.tween_property(self, "position:y", position.y + 10.0, 0.18)
	await tween.finished

# ---------------------------------------------------------
# Datenaufbereitung
# ---------------------------------------------------------
func prepare_fish_data(fish: Dictionary) -> Dictionary:
	var prepared_fish = fish.duplicate(true)
	if not prepared_fish.has("id"):
		push_error("Fish ohne ID übergeben!")
	if not prepared_fish.has("caught"):
		prepared_fish["caught"] = true
	if not prepared_fish.has("location"):
		prepared_fish["location"] = "unknown"
	if not prepared_fish.has("weight") and prepared_fish.has("weight_min") and prepared_fish.has("weight_max"):
		prepared_fish["weight"] = randf_range(prepared_fish["weight_min"], prepared_fish["weight_max"])
	return prepared_fish

func show_fish_detail_popup(fish_data: Dictionary) -> void:
	click.play()
	if not Player.fish_detail_hint_seen:
		Player.fish_detail_hint_seen = true
		Player.save_game()
		if detail_hint_label:
			detail_hint_label.visible = false
	if detail_popup:
		if detail_popup.has_method("show_fish_details"):
			detail_popup.show_fish_details(fish_data)
	else:
		if fish_detail_popup_scene:
			detail_popup = fish_detail_popup_scene.instantiate()
			add_child(detail_popup)
			detail_popup.visible = false
			await get_tree().process_frame
			if detail_popup.has_method("show_fish_details"):
				detail_popup.show_fish_details(fish_data)

# ---------------------------------------------------------
# Partikel Helper
# ---------------------------------------------------------
func _set_splash_texture_for_rarity(rarity: int) -> void:
	var tex: Texture2D = null
	match rarity:
		FishDB.RARITY.NORMAL:       tex = SPLASH_COMMON
		FishDB.RARITY.UNGEWOEHNLICH:tex = SPLASH_UNCOMMON
		FishDB.RARITY.SELTEN:       tex = SPLASH_RARE
		FishDB.RARITY.EPISCH:       tex = SPLASH_EPIC
		FishDB.RARITY.LEGENDAER:    tex = SPLASH_LEGENDARY
		FishDB.RARITY.EXOTISCH:     tex = SPLASH_EXOTIC
		FishDB.RARITY.ANTIK:        tex = SPLASH_ANTIK
		_:                          tex = SPLASH_COMMON
	if tex:
		splash.texture = tex
