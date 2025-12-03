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

var detail_popup: Control
var fish_detail_popup_scene

var current_fish: Dictionary

# Partikel-Texturen je Seltenheit
const SPLASH_COMMON      := preload("res://assets/particles/dropletNormal.png")
const SPLASH_UNCOMMON    := preload("res://assets/particles/dropletUncommon.png")
const SPLASH_RARE        := preload("res://assets/particles/dropletRare.png")
const SPLASH_EPIC        := preload("res://assets/particles/dropletEpic.png")
const SPLASH_LEGENDARY   := preload("res://assets/particles/dropletLegendary.png")
const SPLASH_EXOTIC      := preload("res://assets/particles/dropletExotic.png")

# Shine-Shader
const SHINE_SHADER := preload("res://shader/2DShine.gdshader")

func _ready() -> void: 
	visible = false
	continue_button.pressed.connect(_on_continue_pressed)
	
	# 🆕 Fish-Icon klickbar machen
	if fish_icon:
		fish_icon.mouse_filter = Control.MOUSE_FILTER_STOP
		fish_icon.gui_input.connect(_on_fish_icon_clicked)
		
		# Hover-Cursor
		fish_icon.mouse_entered.connect(_on_fish_icon_hover.bind(true))
		fish_icon.mouse_exited.connect(_on_fish_icon_hover.bind(false))
	
	print("Versuche FishDetailPopup zu laden...")
	if ResourceLoader.exists("res://scenes/FishDetailPopup.tscn"):
		fish_detail_popup_scene = load("res://scenes/FishDetailPopup.tscn")
		print("  ✅ FishDetailPopup.tscn geladen")
		
		# Detail-Popup erstellen
		detail_popup = fish_detail_popup_scene.instantiate()
		add_child(detail_popup)
		detail_popup.visible = false
		print("  ✅ Detail Popup instantiiert")
	else:
		print("  ❌ res://scenes/FishDetailPopup.tscn nicht gefunden!")
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cast"):
		_on_continue_pressed()
		return

func show_fish(fish: Dictionary) -> void:
	# 🆕 Fish-Daten mit allen nötigen Feldern vorbereiten
	current_fish = prepare_fish_data(fish)
	visible = true
	
	# Prüfe ob Fisch neu ist
	var is_new_catch: bool = fish.get("is_new_catch", false)
	
	# AnimationPlayer Referenzen
	var ani_label: AnimationPlayer = $NewLabel/AnimationPlayer if has_node("NewLabel/AnimationPlayer") else null
	var ani_fish: AnimationPlayer = $VBoxContainer/MarginContainer/PanelContainer/AnimationPlayer
	
	# NEW Label anzeigen/verstecken
	if new_label:
		new_label.visible = is_new_catch
		
		if is_new_catch:
			Player.add_money(100)

		if is_new_catch and ani_label and ani_label.has_animation("idle"):
			ani_label.play("idle")
	
	# Icon & Texte
	fish_icon.texture = _get_fish_icon(fish)
	fish_name.text = fish["name"]
	
	var rarity_data: Dictionary = FishDB.RARITY_DATA[fish["rarity"]]
	var rarity_color: Color = rarity_data["color"]
	
	fish_rarity.text = rarity_data["name"]
	fish_rarity.modulate = rarity_color
	
	var total_value: int = int(fish["base_value"] * rarity_data["value"])
	fish_value.text = str(total_value) + " €"
	
	# Gewicht anzeigen
	if fish_weight and fish.has("weight"):
		fish_weight.text = "Gewicht: %.2f kg" % fish["weight"]
	
	# Panel-Rand + Shine-Farbe
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.7) 
	style.border_color = rarity_color
	style.set_border_width_all(5)
	panel.add_theme_stylebox_override("panel", style)
	
	# Shine Shader Material setzen
	var mat := ShaderMaterial.new()
	mat.shader = SHINE_SHADER
	panel.material = mat
	panel.material.set_shader_parameter("ShineColor", rarity_color)
	
	# Partikel-Textur nach Rarität
	_set_splash_texture_for_rarity(fish["rarity"])
	splash.emitting = false
	splash.restart()
	
	# Animation
	if anim.has_animation("pop"):
		anim.play("pop")
	
	# 🎨 Icon Shader mit Bobbing/Sway/Pulse
	var shadow_mat = ShaderMaterial.new()
	shadow_mat.shader = preload("res://shader/icon.gdshader")
	shadow_mat.set_shader_parameter("shadow_offset", Vector2(0, -4.5))
	shadow_mat.set_shader_parameter("shadow_color", Color(0, 0, 0, 0.7))
	
	# Für alle Fische: Bobbing
	shadow_mat.set_shader_parameter("enable_bobbing", true)
	shadow_mat.set_shader_parameter("bobbing_amplitude", 1.5)
	shadow_mat.set_shader_parameter("bobbing_speed", 2.0)
	
	var rarity: int = fish["rarity"]
	
	# Für seltene Fische: Bobbing + Sway
	if rarity >= FishDB.RARITY.SELTEN:
		shadow_mat.set_shader_parameter("enable_sway", true)
		shadow_mat.set_shader_parameter("sway_amplitude", 1.1)
		shadow_mat.set_shader_parameter("sway_speed", 1.5)
	
	# Für legendäre Fische: Alle Effekte!
	if rarity >= FishDB.RARITY.LEGENDAER:
		shadow_mat.set_shader_parameter("enable_pulse", true)
		shadow_mat.set_shader_parameter("pulse_amount", 0.1)
		shadow_mat.set_shader_parameter("pulse_speed", 3.0)
	
	fish_icon.material = shadow_mat

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
		_:
			tex = SPLASH_COMMON
	
	if tex:
		splash.texture = tex

func _on_continue_pressed() -> void:
	visible = false

# 🆕 Fish-Icon geklickt
func _on_fish_icon_clicked(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if not current_fish.is_empty():
				show_fish_detail_popup(current_fish)

# 🎨 Hover-Effekt für Fish-Icon
func _on_fish_icon_hover(is_hovering: bool) -> void:
	if not fish_icon:
		return
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	
	if is_hovering:
		# Cursor ändern
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
		# Leicht vergrößern
		tween.tween_property(fish_icon, "scale", Vector2(1.05, 1.05), 0.15)
	else:
		# Cursor zurücksetzen
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
		# Normale Größe
		tween.tween_property(fish_icon, "scale", Vector2(1.0, 1.0), 0.15)

# 🆕 Fish-Daten für Popup vorbereiten
func prepare_fish_data(fish: Dictionary) -> Dictionary:
	# Kopie erstellen, um Original nicht zu verändern
	var prepared_fish = fish.duplicate(true)
	
	# Fehlende Felder mit Standardwerten ergänzen
	if not prepared_fish.has("original_name"):
		prepared_fish["original_name"] = prepared_fish.get("name", "Unknown")
	
	if not prepared_fish.has("description"):
		prepared_fish["description"] = get_description_from_fishdb(prepared_fish.get("name", ""))
	
	if not prepared_fish.has("caught"):
		prepared_fish["caught"] = true
	
	if not prepared_fish.has("location"):
		prepared_fish["location"] = "unknown"
	
	# Stelle sicher, dass alle Basis-Felder vorhanden sind
	var required_fields = ["name", "rarity", "base_value", "icon"]
	for field in required_fields:
		if not prepared_fish.has(field):
			print("⚠️ Warnung: Fehlendes Feld '%s' im Fish-Dictionary!" % field)
	
	return prepared_fish

# 🔍 Beschreibung aus FishDB holen
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

# 🆕 Fish Detail Popup anzeigen
func show_fish_detail_popup(fish_data: Dictionary) -> void:
	print("show_fish_detail_popup() aufgerufen mit:", fish_data.get("name", "Unknown"))
	
	if detail_popup:
		print("  → detail_popup existiert")
		if detail_popup.has_method("show_fish_details"):
			print("  → Methode gefunden, rufe auf...")
			detail_popup.show_fish_details(fish_data)
		else:
			print("  ❌ Methode 'show_fish_details' nicht gefunden!")
	else:
		print("  ❌ detail_popup ist null!")
		
		# Fallback: Popup neu erstellen
		if fish_detail_popup_scene:
			detail_popup = fish_detail_popup_scene.instantiate()
			add_child(detail_popup)
			detail_popup.visible = false
			
			await get_tree().process_frame
			
			if detail_popup.has_method("show_fish_details"):
				detail_popup.show_fish_details(fish_data)
			else:
				print("  ❌ Auch nach Neuerstellen keine Methode gefunden")
