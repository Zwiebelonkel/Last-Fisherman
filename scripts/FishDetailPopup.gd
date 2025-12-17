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
	
	# Hole vollständige Fischdaten aus FishDB
	var full_fish_data = get_full_fish_data(fish["original_name"])
	
	if full_fish_data.is_empty():
		print("❌ Fisch nicht in FishDB gefunden:", fish["original_name"])
		return
	
	# 🐟 Icon
	if full_fish_data.has("icon"):
		fish_icon.texture = load(full_fish_data["icon"])
	
	# 📝 Name
	fish_name_label.text = fish["name"]
	
	# 🎨 Seltenheit (🌍 Übersetzt)
	var rarity = full_fish_data["rarity"]
	var rarity_data = FishDB.RARITY_DATA[rarity]
	var rarity_color = rarity_data["color"]
	
	# 🌍 Rarity Name übersetzen
	var rarity_name = rarity_data["name"]
	var rarity_key = rarity_name.to_upper()
	
	# Konvertiere deutsche Namen zu Translation Keys
	match rarity_name:
		"Normal":
			rarity_key = "NORMAL"
		"Ungewöhnlich":
			rarity_key = "UNCOMMON"
		"Selten":
			rarity_key = "RARE"
		"Episch":
			rarity_key = "EPIC"
		"Legendär":
			rarity_key = "LEGENDARY"
		"Exotisch":
			rarity_key = "EXOTIC"
		"Antik":
			rarity_key = "ANTIQUE"
	
	rarity_label.text = "⭐ " + tr(rarity_key)
	rarity_label.modulate = rarity_color
	
	# Rahmen in Seltenheitsfarbe
	update_border_color(rarity_color)
	
	# 💰 Wert
	var base_value = full_fish_data["base_value"]
	var total_value = int(base_value * rarity_data["value"])
	value_label.text = "💰 %d €  (x%.1f)" % [total_value, rarity_data["value"]]
	
	# ⚖️ Gewicht (Rekord) (🌍 Übersetzt)
	var max_weight = Player.get_max_caught_weight(fish["original_name"])
	if max_weight > 0:
		weight_label.text = "⚖️ %.2f kg 🏆" % max_weight
	else:
		weight_label.text = get_text("not_caught_yet")
	
	# 📊 Gewichtsbereich (🌍 Übersetzt)
	if full_fish_data.has("weight_min") and full_fish_data.has("weight_max"):
		weight_range_label.text = "%.2f - %.2f kg" % [full_fish_data["weight_min"], full_fish_data["weight_max"]]
	else:
		weight_range_label.text = get_text("unknown")
	
	# 🎣 Wie oft gefangen (🌍 Übersetzt)
	var caught_count = Player.get_catch_count(fish["original_name"])
	caught_count_label.text = get_text("caught_times") % caught_count
	
	# 📖 Beschreibung + Wissenschaftlicher Fakt
	var description = full_fish_data.get("description", get_text("no_description"))
	var science_fact = full_fish_data.get("science_fact", "")
	
	var full_description = "[color=#CCCCCC]%s[/color]" % description
	
	if science_fact != "":
		full_description += "\n\n[color=#88DDFF][/color]\n[color=#AACCEE]%s[/color]" % science_fact
	
	description_text.text = full_description
	
	# ✨ Animation
	popup_panel.modulate.a = 0
	popup_panel.scale = Vector2(0.8, 0.8)
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(popup_panel, "modulate:a", 1.0, 0.3)
	tween.tween_property(popup_panel, "scale", Vector2(1.0, 1.0), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func get_full_fish_data(fish_name: String) -> Dictionary:
	# Durchsuche alle Fischlisten
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
