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
	popup_title.text = spot_name.capitalize()
	if unlocked:
		popup_price.text = "Freigeschaltet"
	else:
		popup_price.text = "Preis: %d $" % price
	# Sichtbarkeit der Buttons
	popup_buy_button.visible = not unlocked
	popup_go_button.visible = unlocked
	# Buy Button text + disabled state
	if not unlocked:
		popup_buy_button.text = "Kaufen (%d$)" % price
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
