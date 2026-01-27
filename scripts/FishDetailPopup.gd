extends Control

@onready var popup_panel: PanelContainer = $CenterContainer/PopupPanel
@onready var fish_icon: TextureRect = $CenterContainer/PopupPanel/MarginContainer/VBoxContainer/Header/IconContainer/FishIcon
@onready var fish_name_label: Label = $CenterContainer/PopupPanel/MarginContainer/VBoxContainer/Header/InfoContainer/FishName
@onready var rarity_label: Label = $CenterContainer/PopupPanel/MarginContainer/VBoxContainer/Header/InfoContainer/Rarity
@onready var value_label: Label = $CenterContainer/PopupPanel/MarginContainer/VBoxContainer/Header/InfoContainer/StatsGrid/Value
@onready var weight_label: Label = $CenterContainer/PopupPanel/MarginContainer/VBoxContainer/Header/InfoContainer/StatsGrid/Weight
@onready var weight_range_label: Label = $CenterContainer/PopupPanel/MarginContainer/VBoxContainer/Header/InfoContainer/StatsGrid/WeightRange
@onready var caught_count_label: Label = $CenterContainer/PopupPanel/MarginContainer/VBoxContainer/Header/InfoContainer/StatsGrid/CaughtCount
@onready var description_text: RichTextLabel = $CenterContainer/PopupPanel/MarginContainer/VBoxContainer/Description
@onready var close_button: Button = $CenterContainer/PopupPanel/MarginContainer/VBoxContainer/ButtonContainer/CloseButton
@onready var overlay: Panel = $Overlay

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
	}
}

func _ready():
	visible = false
	close_button.pressed.connect(_on_close_pressed)
	overlay.gui_input.connect(_on_overlay_clicked)


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


func show_fish_details(fish: Dictionary):
	fish_data = fish
	visible = true

	var is_steam: bool = fish.get("is_steam_player", false)
	var full_fish_data: Dictionary = fish if is_steam else get_full_fish_data(fish.get("id", ""))

	if not is_steam and full_fish_data.is_empty():
		print("❌ Fisch nicht in FishDB gefunden:", fish.get("id", "UNKNOWN"))
		return

	# ✅ ICON: Steam -> steam_avatar direkt nutzen, sonst FishDB
	if is_steam and full_fish_data.has("steam_avatar") and full_fish_data["steam_avatar"] is Texture2D:
		fish_icon.texture = full_fish_data["steam_avatar"]
	else:
		fish_icon.texture = FishDB.get_fish_icon(full_fish_data)

	# ✅ NAME: Steam-Spielername hat absolute Priorität
	if is_steam:
		var steam_name: String = str(fish_data.get("name", "Unknown Player"))
		fish_name_label.text = steam_name
	else:
		fish_name_label.text = FishDB.get_fish_name(full_fish_data)

	# ✅ RARITY safe
	var rarity: int = FishDB.get_rarity_safe(full_fish_data)
	var rarity_data = FishDB.RARITY_DATA.get(rarity, FishDB.RARITY_DATA[FishDB.RARITY.NORMAL])
	var rarity_color: Color = rarity_data["color"]

	rarity_label.text = "⭐ " + tr(rarity_data["name_key"])
	rarity_label.modulate = rarity_color
	update_border_color(rarity_color)

	# ✅ VALUE safe (Steam-Fish hat oft kein base_value)
	var base_value: int = int(full_fish_data.get("base_value", 0))
	var total_value: int = int(base_value * float(rarity_data.get("value", 1.0)))
	value_label.text = "💰 %d €  (x%.1f)" % [total_value, float(rarity_data.get("value", 1.0))]

	# ✅ WEIGHT / CAUGHT COUNT: nur wenn es eine echte Fish-ID gibt
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

	# ✅ Weight range
	if full_fish_data.has("weight_min") and full_fish_data.has("weight_max"):
		weight_range_label.text = "%.2f - %.2f kg" % [full_fish_data["weight_min"], full_fish_data["weight_max"]]
	else:
		weight_range_label.text = get_text("unknown")

	# ✅ Beschreibung safe
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

	# Animation wie gehabt...
	popup_panel.modulate.a = 0
	popup_panel.scale = Vector2(0.8, 0.8)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(popup_panel, "modulate:a", 1.0, 0.3)
	tween.tween_property(popup_panel, "scale", Vector2(1.0, 1.0), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

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


func update_border_color(color: Color):
	var style = popup_panel.get_theme_stylebox("panel").duplicate()
	if style is StyleBoxFlat:
		style.border_color = color
		popup_panel.add_theme_stylebox_override("panel", style)

func _on_close_pressed():
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
