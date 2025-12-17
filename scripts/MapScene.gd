extends Control
@onready var lake_btn = $layout/Locations/BeachButton
@onready var city_btn = $layout/Locations/CityButton
@onready var sewer_btn = $layout/Locations/SewerButton
@onready var forest_btn = $layout/Locations/ForestButton
@onready var desert_btn = $layout/Locations/DesertButton
@onready var iceland_btn = $layout/Locations/IcelandButton
@onready var home_btn = $layout/Locations/HomeButton
@onready var passwordField = $password

@onready var popup = $layout/Popup
@onready var popup_title = $layout/Popup/Title
@onready var popup_price = $layout/Popup/Price
@onready var popup_buy_button = $layout/Popup/BuyButton
@onready var popup_go_button = $layout/Popup/GoButton
@onready var popup_close_btn = $layout/Popup/CloseButton
@onready var back_btn = $layout/BackButton
@onready var interact = $Audio/interact
var selected_spot := ""

# 🌍 Location Display Names
var location_names := {
	"lake": {
		"de": "Strand",
		"en": "Beach"
	},
	"city": {
		"de": "Stadt",
		"en": "City"
	},
	"sewer": {
		"de": "U-Bahn",
		"en": "Subway"
	},
	"forest": {
		"de": "Wald",
		"en": "Forest"
	},
	"desert": {
		"de": "Wüste",
		"en": "Desert"
	},
	"iceland": {
		"de": "Eisland",
		"en": "Iceland"
	},
	"home": {
		"de": "Zuhause",
		"en": "Home"
	}
}

# 🌍 Localized Texts
var localized_texts := {
	"unlocked": {
		"de": "Freigeschaltet",
		"en": "Unlocked"
	},
	"price": {
		"de": "Preis: %d $",
		"en": "Price: %d $"
	},
	"buy_button": {
		"de": "Kaufen (%d$)",
		"en": "Buy (%d$)"
	}
}

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	assign_button(lake_btn, "lake")
	assign_button(city_btn, "city")
	assign_button(sewer_btn, "sewer")
	assign_button(forest_btn, "forest")
	assign_button(desert_btn, "desert")
	assign_button(iceland_btn, "iceland")
	assign_button(home_btn, "home")

	popup.visible = false
	popup_close_btn.pressed.connect(hide_popup)
	back_btn.pressed.connect(go_back)


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

func get_location_name(spot_name: String) -> String:
	var current_lang = Player.current_language
	if location_names.has(spot_name) and location_names[spot_name].has(current_lang):
		return location_names[spot_name][current_lang]
	elif location_names.has(spot_name) and location_names[spot_name].has("de"):
		return location_names[spot_name]["de"]
	return spot_name.capitalize()


func hide_popup():
	popup.visible = false

func go_back():
	Player.go_to_last_scene()

func assign_button(btn: Button, spot_name: String):
	# Button öffnet Popup
	btn.pressed.connect(func():
		show_spot_popup(spot_name)
	)
	# Button-Farbe abhängig von Unlock-Status
	if Player.unlocked_spots.get(spot_name, false):
		btn.modulate = Color.WHITE
	else:
		btn.modulate = Color(0.4, 0.4, 0.4)

func show_spot_popup(spot_name: String):
	interact.play()
	selected_spot = spot_name
	var price = Player.spot_prices[spot_name]
	var unlocked = Player.unlocked_spots.get(spot_name, false)
	
	popup.visible = true
	
	# 🌍 Lokalisierter Titel
	popup_title.text = get_location_name(spot_name)
	
	# 🌍 Lokalisierter Preis-Text
	if unlocked:
		popup_price.text = get_text("unlocked")
	else:
		popup_price.text = get_text("price") % price
	
	# Sichtbarkeit der Buttons
	popup_buy_button.visible = not unlocked
	popup_go_button.visible = unlocked
	
	# 🌍 Buy Button Text
	if not unlocked:
		popup_buy_button.text = get_text("buy_button") % price
		popup_buy_button.disabled = Player.money < price
	
	# Bestehende Signale trennen
	_disconnect_all(popup_buy_button)
	_disconnect_all(popup_go_button)
	
	# Neue Signale verbinden
	popup_buy_button.pressed.connect(func():
		buy_spot(selected_spot)
	)
	popup_go_button.pressed.connect(func():
		go_to_spot(selected_spot)
	)

func buy_spot(spot_name: String):
	var cost = Player.spot_prices[spot_name]
	if Player.money < cost:
		print("Nicht genug Geld!")
		return
	Player.money -= cost
	Player.unlocked_spots[spot_name] = true
	Player.save_game()
	interact.play()
	print("Ort gekauft:", spot_name)
	# Popup schließen
	hide_popup()
	# Buttons neu einfärben
	assign_button(lake_btn, "lake")
	assign_button(city_btn, "city")
	assign_button(sewer_btn, "sewer")
	assign_button(forest_btn, "forest")
	assign_button(desert_btn, "desert")
	assign_button(iceland_btn, "iceland")
	assign_button(home_btn, "home")

func go_to_spot(spot_name: String):
	interact.play()
	match spot_name:
		"lake":
			Player.update_last_scene("res://scenes/MainScene.tscn")
			Transition.change_scene("res://scenes/MainScene.tscn", 0.8)

		"city":
			Player.update_last_scene("res://scenes/city.tscn")
			Transition.change_scene("res://scenes/city.tscn", 0.8)
		"sewer":
			Player.update_last_scene("res://scenes/sewer.tscn")
			Transition.change_scene("res://scenes/sewer.tscn", 0.8)
		"forest":
			Player.update_last_scene("res://scenes/forest.tscn")
			Transition.change_scene("res://scenes/forest.tscn", 0.8)
		"desert":
			Player.update_last_scene("res://scenes/ödland.tscn")
			Transition.change_scene("res://scenes/ödland.tscn", 0.8)
		"iceland":
			Player.update_last_scene("res://scenes/iceland.tscn")
			Transition.change_scene("res://scenes/iceland.tscn", 0.8)
		"home":
			Player.update_last_scene("res://scenes/hub.tscn")
			Transition.change_scene("res://scenes/hub.tscn", 0.8)

# Helferfunktion zum sicheren Trennen der Signale
func _disconnect_all(btn: Button):
	for c in btn.pressed.get_connections():
		btn.pressed.disconnect(c.callable)


func _on_submit_pressed() -> void:
	var password
	password = passwordField.text
	passwordField.clear()
	
	if password == "money":
		Player.add_money(1000000000000000)
		password = ""
	elif password == "fish":
		Player._add_all_fish()
		password = ""
	elif password == "grip":
		Player.upgrade_grip = 500
		password = ""
	elif password == "bait":
		Player.upgrade_bait = 500
		password = ""
	elif password == "line":
		Player.upgrade_line = 500
		password = ""
	elif password == "*":
		Player.set_money(Player.money*100)
		password = ""
	else:
		return
