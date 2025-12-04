extends Node3D

# Node-Referenzen
@onready var money_label: Label = $UI/ShopContainer/MainPanel/VBoxContainer/TopBar/MoneyLabel

@onready var grip_level_label: Label = $UI/ShopContainer/MainPanel/VBoxContainer/UpgradeCards/GripCard/CardContent/LevelLabel
@onready var grip_desc_label: Label = $UI/ShopContainer/MainPanel/VBoxContainer/UpgradeCards/GripCard/CardContent/DescLabel
@onready var grip_price_label: Label = $UI/ShopContainer/MainPanel/VBoxContainer/UpgradeCards/GripCard/CardContent/PriceLabel
@onready var grip_button: Button = $UI/ShopContainer/MainPanel/VBoxContainer/UpgradeCards/GripCard/CardContent/BuyButton

@onready var bait_level_label: Label = $UI/ShopContainer/MainPanel/VBoxContainer/UpgradeCards/BaitCard/CardContent/LevelLabel
@onready var bait_desc_label: Label = $UI/ShopContainer/MainPanel/VBoxContainer/UpgradeCards/BaitCard/CardContent/DescLabel
@onready var bait_price_label: Label = $UI/ShopContainer/MainPanel/VBoxContainer/UpgradeCards/BaitCard/CardContent/PriceLabel
@onready var bait_button: Button = $UI/ShopContainer/MainPanel/VBoxContainer/UpgradeCards/BaitCard/CardContent/BuyButton

@onready var line_level_label: Label = $UI/ShopContainer/MainPanel/VBoxContainer/UpgradeCards/LineCard/CardContent/LevelLabel
@onready var line_desc_label: Label = $UI/ShopContainer/MainPanel/VBoxContainer/UpgradeCards/LineCard/CardContent/DescLabel
@onready var line_price_label: Label = $UI/ShopContainer/MainPanel/VBoxContainer/UpgradeCards/LineCard/CardContent/PriceLabel
@onready var line_button: Button = $UI/ShopContainer/MainPanel/VBoxContainer/UpgradeCards/LineCard/CardContent/BuyButton

@onready var rod_preview: Node3D = $RodPreview
@onready var music: AudioStreamPlayer = $Audio/music
@onready var interact: AudioStreamPlayer = $Audio/interact
@onready var splash: GPUParticles3D = $RodPreview/Splash

var base_grip_cost := 50
var base_bait_cost := 75
var base_line_cost := 100

func _ready():
	update_ui()
	play_intro_animation()

func calculate_cost(base_cost: int, level: int) -> int:
	return int(base_cost * pow(1.3, level - 1))

func update_ui():
	# Geld anzeigen
	money_label.text = "💰 %d €" % Player.money
	
	# Grip Card
	var grip_cost = calculate_cost(base_grip_cost, Player.upgrade_grip)
	grip_level_label.text = "Level %d" % Player.upgrade_grip
	grip_desc_label.text = "+%d%% Sweetspot\nProgress" % (Player.upgrade_grip * 15)
	grip_price_label.text = "%d €" % grip_cost
	grip_button.disabled = (Player.money < grip_cost)
	
	# Bait Card
	var bait_cost = calculate_cost(base_bait_cost, Player.upgrade_bait)
	bait_level_label.text = "Level %d" % Player.upgrade_bait
	bait_desc_label.text = "+%d%% Seltene\nItems Chance" % (Player.upgrade_bait * 10)
	bait_price_label.text = "%d €" % bait_cost
	bait_button.disabled = (Player.money < bait_cost)
	
	# Line Card
	var line_cost = calculate_cost(base_line_cost, Player.upgrade_line)
	line_level_label.text = "Level %d" % Player.upgrade_line
	line_desc_label.text = "-%d%% Warte-\nzeit" % (Player.upgrade_line * 8)
	line_price_label.text = "%d €" % line_cost
	line_button.disabled = (Player.money < line_cost)

func play_intro_animation():
	var shop_container = $UI/ShopContainer
	shop_container.modulate.a = 0
	
	var tween = create_tween()
	tween.tween_property(shop_container, "modulate:a", 1.0, 0.3)
	
	# Cards nacheinander einblenden
	var cards = [
		$UI/ShopContainer/MainPanel/VBoxContainer/UpgradeCards/GripCard,
		$UI/ShopContainer/MainPanel/VBoxContainer/UpgradeCards/BaitCard,
		$UI/ShopContainer/MainPanel/VBoxContainer/UpgradeCards/LineCard
	]
	
	for i in range(cards.size()):
		var card = cards[i]
		card.modulate.a = 0
		card.scale = Vector2(0.85, 0.85)
		
		var card_tween = create_tween()
		card_tween.set_parallel(true)
		card_tween.tween_property(card, "modulate:a", 1.0, 0.4).set_delay(0.2 + i * 0.1)
		card_tween.tween_property(card, "scale", Vector2(1.0, 1.0), 0.4).set_delay(0.2 + i * 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func play_purchase_effect(card: PanelContainer):
	var original_color = card.modulate
	
	var tween = create_tween()
	tween.tween_property(card, "modulate", Color(0.3, 1.0, 0.4), 0.1)
	tween.tween_property(card, "modulate", original_color, 0.2)
	
	# Scale Bounce
	var scale_tween = create_tween()
	scale_tween.tween_property(card, "scale", Vector2(1.05, 1.05), 0.1)
	scale_tween.tween_property(card, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func _process(delta):
	# Leichte Rotation der Angel
	rod_preview.rotate_y(delta * 0.5)

func _on_GripButton_pressed():
	var grip_cost = calculate_cost(base_grip_cost, Player.upgrade_grip)
	if Player.money >= grip_cost:
		Player.money -= grip_cost
		Player.upgrade_grip += 1
		Player.save_game()
		interact.play()
		splash.restart()
		
		var card = $UI/ShopContainer/MainPanel/VBoxContainer/UpgradeCards/GripCard
		play_purchase_effect(card)
		
		update_ui()

func _on_BaitButton_pressed():
	var bait_cost = calculate_cost(base_bait_cost, Player.upgrade_bait)
	if Player.money >= bait_cost:
		Player.money -= bait_cost
		Player.upgrade_bait += 1
		Player.save_game()
		interact.play()
		splash.restart()
		
		var card = $UI/ShopContainer/MainPanel/VBoxContainer/UpgradeCards/BaitCard
		play_purchase_effect(card)
		
		update_ui()

func _on_LineButton_pressed():
	var line_cost = calculate_cost(base_line_cost, Player.upgrade_line)
	if Player.money >= line_cost:
		Player.money -= line_cost
		Player.upgrade_line += 1
		Player.save_game()
		interact.play()
		splash.restart()
		
		var card = $UI/ShopContainer/MainPanel/VBoxContainer/UpgradeCards/LineCard
		play_purchase_effect(card)
		
		update_ui()

func _on_BackButton_pressed():
	Player.go_to_last_scene()
