extends Control

@onready var popup_panel: PanelContainer = $CenterContainer/PopupPanel
@onready var fish_viewport: SubViewport = $CenterContainer/PopupPanel/MarginContainer/VBoxContainer/Header/IconContainer/SubViewportContainer/SubViewport
@onready var fish_name_label: Label = $CenterContainer/PopupPanel/MarginContainer/VBoxContainer/Header/InfoContainer/FishName
@onready var rarity_label: Label = $CenterContainer/PopupPanel/MarginContainer/VBoxContainer/Header/InfoContainer/Rarity
@onready var value_label: Label = $CenterContainer/PopupPanel/MarginContainer/VBoxContainer/Header/InfoContainer/StatsGrid/Value
@onready var weight_label: Label = $CenterContainer/PopupPanel/MarginContainer/VBoxContainer/Header/InfoContainer/StatsGrid/Weight
@onready var weight_range_label: Label = $CenterContainer/PopupPanel/MarginContainer/VBoxContainer/Header/InfoContainer/StatsGrid/WeightRange
@onready var caught_count_label: Label = $CenterContainer/PopupPanel/MarginContainer/VBoxContainer/Header/InfoContainer/StatsGrid/CaughtCount
@onready var description_text: RichTextLabel = $CenterContainer/PopupPanel/MarginContainer/VBoxContainer/Description
@onready var close_button: Button = $CenterContainer/PopupPanel/MarginContainer/VBoxContainer/ButtonContainer/CloseButton
@onready var overlay: Panel = $Overlay
@onready var click: AudioStreamPlayer = $Audio/click

var fish_data: Dictionary = {}

# 🌍 Localized Texts
var localized_texts := {
	"not_caught_yet": {
		"de": "⚖️ Noch nicht gefangen",
		"en": "⚖️ Not caught yet"
	},
	"unknown": {
		"de": "Unbekannt",
		"en": "Unknown"
	},
	"caught_times": {
		"de": "🎣 %dx gefangen",
		"en": "🎣 Caught %dx"
	},
	"no_description": {
		"de": "Keine Beschreibung verfügbar.",
		"en": "No description available."
	},
	"lore_weight": {
		"de": "⚖️ Gewicht unbekannt",
		"en": "⚖️ Weight unknown"
	},
	"lore_value": {
		"de": "💰 Kein Wert",
		"en": "💰 No value"
	},
	"lore_caught": {
		"de": "📜 Fragment gefunden",
		"en": "📜 Fragment found"
	},
	"lore_digit": {
		"de": "🔢 Ziffer: %d",
		"en": "🔢 Digit: %d"
	}
}

func _ready():
	visible = false
	close_button.pressed.connect(_on_close_pressed)
	overlay.gui_input.connect(_on_overlay_clicked)
	
func set_3d_fish(texture: Texture2D):
	# alten Fisch löschen
	for child in fish_viewport.get_children():
		child.queue_free()

	var fish_scene = preload("res://test.tscn").instantiate()
	fish_viewport.add_child(fish_scene)

	var mesh := fish_scene.get_node("MeshInstance3D") as MeshInstance3D
	var mat := mesh.material_override as ShaderMaterial
	
	if texture == null:
		texture = load("res://assets/fish/unknown.png")

	mat.set_shader_parameter("Texture", texture)

# ============================================
# 🌍 LOCALIZATION HELPER
# ============================================

func get_text(key: String) -> String:
	var current_lang = Player.current_language
	if localized_texts.has(key) and localized_texts[key].has(current_lang):
		return localized_texts[key][current_lang]
	elif localized_texts.has(key) and localized_texts[key].has("de"):
		return localized_texts[key]["de"]
	return key


# ============================================
# 📌 MAIN ENTRY POINT
# ============================================

func show_fish_details(fish: Dictionary):
	fish_data = fish
	visible = true

	var is_steam: bool = fish.get("is_steam_player", false)
	var is_lore: bool = _is_lore_fragment(fish)  # ← fish statt fish.get("id")
	
	if is_lore:
		_show_lore_fragment(fish)
		_play_open_animation()
		return

	# -----------------------------------------------
	# 🗺️ LORE FRAGMENT
	# -----------------------------------------------
	if is_lore:
		_show_lore_fragment(fish)
		_play_open_animation()
		return

	# -----------------------------------------------
	# 🐟 NORMAL FISH / STEAM PLAYER
	# -----------------------------------------------
	var full_fish_data: Dictionary = fish if is_steam else get_full_fish_data(fish.get("id", ""))

	if not is_steam and full_fish_data.is_empty():
		print("❌ Fisch nicht in FishDB gefunden:", fish.get("id", "UNKNOWN"))
		visible = false
		return

	# ICON
	if is_steam and full_fish_data.has("steam_avatar") and full_fish_data["steam_avatar"] is Texture2D:
		set_3d_fish(full_fish_data["steam_avatar"])
	else:
		set_3d_fish(FishDB.get_fish_icon(full_fish_data))

	# NAME
	if is_steam:
		fish_name_label.text = str(fish_data.get("name", "Unknown Player"))
	else:
		fish_name_label.text = FishDB.get_fish_name(full_fish_data)

	# RARITY
	var rarity: int = FishDB.get_rarity_safe(full_fish_data)
	var rarity_data = FishDB.RARITY_DATA.get(rarity, FishDB.RARITY_DATA[FishDB.RARITY.NORMAL])
	var rarity_color: Color = rarity_data["color"]

	rarity_label.text = "⭐ " + tr(rarity_data["name_key"])
	rarity_label.modulate = rarity_color
	update_border_color(rarity_color)

	# VALUE
	var base_value: int = int(full_fish_data.get("base_value", 0))
	var total_value: int = int(base_value * float(rarity_data.get("value", 1.0)))
	value_label.text = "💰 %d €  (x%.1f)" % [total_value, float(rarity_data.get("value", 1.0))]

	# WEIGHT / CAUGHT COUNT
	var fish_id: String = str(fish.get("id", ""))
	if fish_id != "":
		var max_weight = Player.get_max_caught_weight(fish_id)
		if max_weight > 0:
			weight_label.text = "⚖️ %.2f kg 🏆" % max_weight
		else:
			weight_label.text = get_text("not_caught_yet")

		var caught_count = Player.get_catch_count(fish_id)
		caught_count_label.text = get_text("caught_times") % caught_count
	else:
		weight_label.text = get_text("unknown")
		caught_count_label.text = get_text("unknown")

	# WEIGHT RANGE
	if full_fish_data.has("weight_min") and full_fish_data.has("weight_max"):
		weight_range_label.text = "%.2f - %.2f kg" % [full_fish_data["weight_min"], full_fish_data["weight_max"]]
	else:
		weight_range_label.text = get_text("unknown")

	# DESCRIPTION
	var description: String = ""
	if is_steam:
		description = str(full_fish_data.get("description", ""))
	else:
		description = FishDB.get_fish_description(full_fish_data)

	var science_fact: String = ""
	if is_steam:
		science_fact = str(full_fish_data.get("science", ""))
	else:
		science_fact = FishDB.get_fish_science(full_fish_data)

	if description == "":
		description = get_text("no_description")

	var full_description = "[color=#CCCCCC]%s[/color]" % description
	if science_fact != "":
		full_description += "\n\n[color=#AACCEE]%s[/color]" % science_fact

	description_text.text = full_description

	_play_open_animation()


# ============================================
# 📜 LORE FRAGMENT DISPLAY
# ============================================

func _is_lore_fragment(fish: Dictionary) -> bool:
	# Direkt per Flag (gesetzt von FishBookUI)
	if fish.get("is_lore", false):
		return true
	# Fallback: ID in LoreManager prüfen
	return LoreManager.NOTES.has(fish.get("id", ""))

func _show_lore_fragment(fish: Dictionary):
	var lang: String = Player.current_language
	
	var lore_name: String = fish.get("name_" + lang, fish.get("name_de", fish.get("name", "Fragment")))
	var lore_desc: String = fish.get("text_" + lang, fish.get("text_de", fish.get("text", "")))
	var digit: int        = fish.get("digit", -1)

	# ICON
	var lore_icon_path := "res://assets/fish/unknown.png"
	if ResourceLoader.exists("res://assets/fish/fragment.png"):
		lore_icon_path = "res://assets/fish/fragment.png"
	set_3d_fish(load(lore_icon_path) as Texture2D)

	# NAME
	fish_name_label.text = lore_name

	# RARITY → ANTIK
	var rarity_data = FishDB.RARITY_DATA[FishDB.RARITY.ANTIK]
	var rarity_color: Color = rarity_data["color"]
	rarity_label.text = "⭐ " + tr(rarity_data["name_key"])
	rarity_label.modulate = rarity_color
	update_border_color(rarity_color)

	# STATS
	value_label.text        = get_text("lore_value")
	weight_label.text       = get_text("lore_weight")
	weight_range_label.text = get_text("unknown")
	caught_count_label.text = get_text("lore_caught")

	# DESCRIPTION
	if lore_desc == "":
		lore_desc = get_text("no_description")

	var full_description := "[color=#CCCCCC]%s[/color]" % lore_desc
	if digit >= 0:
		full_description += "\n\n[color=#AACCEE]%s[/color]" % (get_text("lore_digit") % digit)

	description_text.text = full_description


# ============================================
# 🔍 FISH DB LOOKUP
# ============================================

func get_full_fish_data(fish_id: String) -> Dictionary:
	var all_lists = [
		FishDB.FISH_LAKE,
		FishDB.FISH_CITY,
		FishDB.FISH_SEWER,
		FishDB.FISH_FOREST,
		FishDB.FISH_DESERT,
		FishDB.FISH_ICELAND,
		FishDB.FISH_OCEAN
	]

	for fish_list in all_lists:
		for fish in fish_list:
			if fish.get("id", "") == fish_id:
				return fish

	return {}


# ============================================
# 🎨 BORDER COLOR
# ============================================

func update_border_color(color: Color):
	var style = popup_panel.get_theme_stylebox("panel").duplicate()
	if style is StyleBoxFlat:
		style.border_color = color
		popup_panel.add_theme_stylebox_override("panel", style)


# ============================================
# 🎬 ANIMATION
# ============================================

func _play_open_animation():
	popup_panel.modulate.a = 0
	popup_panel.scale = Vector2(0.8, 0.8)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(popup_panel, "modulate:a", 1.0, 0.3)
	tween.tween_property(popup_panel, "scale", Vector2(1.0, 1.0), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


# ============================================
# ❌ CLOSE LOGIC
# ============================================

func _on_close_pressed():
	click.play()
	hide_popup()

func _on_overlay_clicked(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		hide_popup()

func hide_popup():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(popup_panel, "modulate:a", 0.0, 0.2)
	tween.tween_property(popup_panel, "scale", Vector2(0.8, 0.8), 0.2)
	await tween.finished
	visible = false

func _input(event):
	if visible and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		hide_popup()
		get_viewport().set_input_as_handled()
