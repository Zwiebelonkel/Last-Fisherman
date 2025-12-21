extends Control

@onready var panel: Panel = $"Panel"
@onready var fish_icon: TextureRect = $VBoxContainer/MarginContainer/PanelContainer/MarginContainer/FishIcon
@onready var fish_name: Label = $VBoxContainer/MarginContainer2/FishName
@onready var fish_rarity: Label = $VBoxContainer/MarginContainer3/FishRarity
@onready var fish_value: Label = $VBoxContainer/MarginContainer4/FishValue
@onready var fish_weight: Label = $VBoxContainer/MarginContainer5/FishWeight
@onready var new_label: Label = $NewLabel
@onready var continue_button: Button = $ContinueButton
@onready var anim: AnimationPlayer = $VBoxContainer/AnimationPlayer
@onready var splash: GPUParticles2D = $Splash

# 🆕 Story-Text Label (in der Scene anlegen!)
@onready var story_label: Label = $StoryLabel if has_node("StoryLabel") else null

var detail_popup: Control
var fish_detail_popup_scene
var current_fish: Dictionary

# 🆕 Signal für Story-Events
signal story_item_used(biome: String)

const SPLASH_COMMON      := preload("res://assets/particles/dropletNormal.png")
const SPLASH_UNCOMMON    := preload("res://assets/particles/dropletUncommon.png")
const SPLASH_RARE        := preload("res://assets/particles/dropletRare.png")
const SPLASH_EPIC        := preload("res://assets/particles/dropletEpic.png")
const SPLASH_LEGENDARY   := preload("res://assets/particles/dropletLegendary.png")
const SPLASH_EXOTIC      := preload("res://assets/particles/dropletExotic.png")
const SPLASH_ANTIK       := preload("res://assets/particles/dropletExotic.png")  # 🆕 Nutze vorhandene Textur
const SHINE_SHADER       := preload("res://shader/2DShine.gdshader")


func _ready() -> void:
	visible = false
	continue_button.pressed.connect(_on_continue_pressed)
	
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


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cast"):
		_on_continue_pressed()
		return

# ---------------------------------------------------------
# HAUPTFUNKTION – FISCH ANZEIGEN
# ---------------------------------------------------------
func show_fish(fish: Dictionary) -> void:
	# 🔒 CRITICAL FIX: Prüfe und repariere Fish-Daten VOR allem anderen
	if not fish.has("rarity"):
		push_error("❌ CRITICAL: Fish ohne rarity in show_fish: %s" % fish.get("name", "Unknown"))
		# Notfall-Reparatur
		fish["rarity"] = FishDB.RARITY.NORMAL
	
	if not FishDB.RARITY_DATA.has(fish["rarity"]):
		push_error("❌ CRITICAL: Ungültige rarity in show_fish: %s" % fish["rarity"])
		# Notfall-Reparatur
		fish["rarity"] = FishDB.RARITY.NORMAL
	
	current_fish = prepare_fish_data(fish)
	visible = true
	
	var is_new_catch: bool = fish.get("is_new_catch", false)
	var is_story_item: bool = fish.get("is_story_item", false)
	var rarity: int = fish["rarity"]
	
	# AnimationPlayer Referenzen
	var ani_label: AnimationPlayer = $NewLabel/AnimationPlayer if has_node("NewLabel/AnimationPlayer") else null
	var ani_fish: AnimationPlayer = $VBoxContainer/MarginContainer/PanelContainer/AnimationPlayer
	
	# 🔒 FIX: Sichere Zugriffe
	var rarity_data: Dictionary = FishDB.RARITY_DATA[rarity]
	var rarity_color: Color = rarity_data["color"]
	
	# -----------------------------------
	# Button-Text & Story-Label
	# -----------------------------------
	if is_story_item and rarity == FishDB.RARITY.ANTIK:
		continue_button.text = "Use"
		
		if story_label and fish.has("story_text"):
			story_label.visible = true
			story_label.modulate = Color.WHITE
			story_label.text = fish["story_text"]
	else:
		continue_button.text = "Continue"
		if story_label:
			story_label.visible = false
	
	# -----------------------------------
	# NEW Label
	# -----------------------------------
	if new_label:
		new_label.visible = is_new_catch
		
		if is_new_catch and not is_story_item:
			Player.add_money(100)
		if is_new_catch and ani_label and ani_label.has_animation("idle"):
			ani_label.play("idle")
	
	# -----------------------------------
	# Icon & Texte (mit Typewriter)
	# -----------------------------------
	fish_icon.texture = _get_fish_icon(fish)
	
	# Name
	fish_name.text = fish["name"]
	
	# Rarity
	fish_rarity.modulate = rarity_color
	fish_rarity.text = rarity_data["name"]
	
	# Wert
	var display_value_text: String
	if is_story_item and rarity == FishDB.RARITY.ANTIK:
		display_value_text = "Unbezahlbar"
		fish_value.modulate = rarity_color
	else:
		var total_value: int = int(fish["base_value"] * rarity_data["value"])
		display_value_text = str(total_value) + " €"
	fish_value.text = display_value_text
	
	# Gewicht
	if fish_weight and fish.has("weight"):
		fish_weight.text = "Gewicht: %.2f kg" % fish["weight"]
	
	# -----------------------------------
	# Panel-Rand + Shine-Farbe
	# -----------------------------------
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.7) 
	style.border_color = rarity_color
	style.set_border_width_all(5)
	panel.add_theme_stylebox_override("panel", style)
	
	var mat := ShaderMaterial.new()
	mat.shader = SHINE_SHADER
	panel.material = mat
	panel.material.set_shader_parameter("ShineColor", rarity_color)
	
	# -----------------------------------
	# Partikel-Textur nach Rarität
	# -----------------------------------
	_set_splash_texture_for_rarity(rarity)
	splash.emitting = false
	splash.restart()
	
	# -----------------------------------
	# Popup-Animation
	# -----------------------------------
	if anim.has_animation("pop"):
		anim.play("pop")
	
	# -----------------------------------
	# Icon Shader mit Bobbing/Sway/Pulse
	# -----------------------------------
	var shadow_mat = ShaderMaterial.new()
	shadow_mat.shader = preload("res://shader/icon.gdshader")
	shadow_mat.set_shader_parameter("shadow_offset", Vector2(0, -4.5))
	shadow_mat.set_shader_parameter("shadow_color", Color(0, 0, 0, 0.7))
	
	# Bobbing für alle
	shadow_mat.set_shader_parameter("enable_bobbing", true)
	shadow_mat.set_shader_parameter("bobbing_amplitude", 1.5)
	shadow_mat.set_shader_parameter("bobbing_speed", 2.0)
	
	# Sway für seltene Fische
	if rarity >= FishDB.RARITY.SELTEN:
		shadow_mat.set_shader_parameter("enable_sway", true)
		shadow_mat.set_shader_parameter("sway_amplitude", 1.1)
		shadow_mat.set_shader_parameter("sway_speed", 1.5)
	
	# Pulse für legendäre Fische UND Story-Items
	if rarity >= FishDB.RARITY.LEGENDAER or rarity == FishDB.RARITY.ANTIK:
		shadow_mat.set_shader_parameter("enable_pulse", true)
		shadow_mat.set_shader_parameter("pulse_amount", 0.15)
		shadow_mat.set_shader_parameter("pulse_speed", 2.5)
	
	fish_icon.material = shadow_mat

# ---------------------------------------------------------
# Continue/Use Button Handler
# ---------------------------------------------------------
func _on_continue_pressed() -> void:
	var is_story_item: bool = current_fish.get("is_story_item", false)
	var rarity: int = current_fish.get("rarity", FishDB.RARITY.NORMAL)
	
	# Wenn Story-Item (ANTIK) → Event auslösen
	if is_story_item and rarity == FishDB.RARITY.ANTIK:
		var biome: String = current_fish.get("biome", "")
		if biome != "":
			emit_signal("story_item_used", biome)
			print("🎭 Story-Item verwendet:", current_fish["name"], "→ Biom:", biome)
	
	visible = false


# ---------------------------------------------------------
# Icon Click / Hover / Detail Popup
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
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	
	if is_hovering:
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
		tween.tween_property(fish_icon, "scale", Vector2(1.05, 1.05), 0.15)
	else:
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
		tween.tween_property(fish_icon, "scale", Vector2(1.0, 1.0), 0.15)


# ---------------------------------------------------------
# Datenaufbereitung
# ---------------------------------------------------------
func prepare_fish_data(fish: Dictionary) -> Dictionary:
	var prepared_fish = fish.duplicate(true)
	
	if not prepared_fish.has("original_name"):
		prepared_fish["original_name"] = prepared_fish.get("name", "Unknown")
	
	if not prepared_fish.has("description"):
		prepared_fish["description"] = get_description_from_fishdb(prepared_fish.get("name", ""))
	
	if not prepared_fish.has("caught"):
		prepared_fish["caught"] = true
	
	if not prepared_fish.has("location"):
		prepared_fish["location"] = "unknown"

	# 🆕 Gewicht generieren
	if not prepared_fish.has("weight") and prepared_fish.has("weight_min") and prepared_fish.has("weight_max"):
		prepared_fish["weight"] = randf_range(
			prepared_fish["weight_min"],
			prepared_fish["weight_max"]
		)

	return prepared_fish



func get_description_from_fishdb(fish_name: String) -> String:
	if fish_name == "":
		return ""
	
	var all_lists = [
		FishDB.FISH_LAKE,
		FishDB.FISH_CITY,
		FishDB.FISH_SEWER,
		FishDB.FISH_FOREST,
		FishDB.FISH_DESERT,
		FishDB.FISH_ICELAND
	]
	
	for fish_list in all_lists:
		for fish in fish_list:
			if fish["name"] == fish_name:
				return fish.get("description", "")
	
	return ""


func show_fish_detail_popup(fish_data: Dictionary) -> void:
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
# Partikel & Icon Helper
# ---------------------------------------------------------
func _get_fish_icon(fish: Dictionary) -> Texture2D:
	if fish.has("icon"):
		var icon_path: String = fish["icon"]
		var tex: Texture2D = load(icon_path)
		if tex:
			return tex
	return preload("res://assets/fish/unknown.png")


func _set_splash_texture_for_rarity(rarity: int) -> void:
	var tex: Texture2D = null
	match rarity:
		FishDB.RARITY.NORMAL:
			tex = SPLASH_COMMON
		FishDB.RARITY.UNGEWOEHNLICH:
			tex = SPLASH_UNCOMMON
		FishDB.RARITY.SELTEN:
			tex = SPLASH_RARE
		FishDB.RARITY.EPISCH:
			tex = SPLASH_EPIC
		FishDB.RARITY.LEGENDAER:
			tex = SPLASH_LEGENDARY
		FishDB.RARITY.EXOTISCH:
			tex = SPLASH_EXOTIC
		FishDB.RARITY.ANTIK:
			tex = SPLASH_ANTIK
		_:
			tex = SPLASH_COMMON
	
	if tex:
		splash.texture = tex
