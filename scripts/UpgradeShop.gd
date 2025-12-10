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

# 🆕 Köder-Shop Toggle
@onready var shop_toggle_button: Button = $UI/ShopContainer/MainPanel/VBoxContainer/TopBar/ShopToggleButton
@onready var upgrade_panel: HBoxContainer = $UI/ShopContainer/MainPanel/VBoxContainer/UpgradeCards
@onready var bait_shop_panel: VBoxContainer = $UI/ShopContainer/MainPanel/VBoxContainer/BaitShop

# 🆕 Köder-Karten
@onready var uncommon_bait_card: PanelContainer = $UI/ShopContainer/MainPanel/VBoxContainer/BaitShop/Scroll/Cards/UngewöhnlichCard
@onready var rare_bait_card: PanelContainer = $UI/ShopContainer/MainPanel/VBoxContainer/BaitShop/Scroll/Cards/SeltenCard
@onready var epic_bait_card: PanelContainer = $UI/ShopContainer/MainPanel/VBoxContainer/BaitShop/Scroll/Cards/EpischCard
@onready var legendary_bait_card: PanelContainer = $UI/ShopContainer/MainPanel/VBoxContainer/BaitShop/Scroll/Cards/LegendärCard
@onready var exotic_bait_card: PanelContainer = $UI/ShopContainer/MainPanel/VBoxContainer/BaitShop/Scroll/Cards/ExotischCard

var showing_bait_shop: bool = false

var base_grip_cost := 50
var base_bait_cost := 75
var base_line_cost := 100

func _ready():
	update_ui()
	play_intro_animation()
	
	# 🆕 Shop-Wechsel
	shop_toggle_button.pressed.connect(_on_shop_toggle_pressed)
	
	# 🆕 Köder-Kaufbuttons verbinden
	setup_bait_buttons()
	
	# Start: Upgrade-Ansicht
	show_upgrade_shop()


# ============================================
# BUTTON CONNECTIONS
# ============================================

func setup_bait_buttons():
	uncommon_bait_card.get_node("CardContent/BuyButton").pressed.connect(func(): buy_bait("Uncommon"))
	rare_bait_card.get_node("CardContent/BuyButton").pressed.connect(func(): buy_bait("Rare"))
	epic_bait_card.get_node("CardContent/BuyButton").pressed.connect(func(): buy_bait("Epic"))
	legendary_bait_card.get_node("CardContent/BuyButton").pressed.connect(func(): buy_bait("Legendary"))
	exotic_bait_card.get_node("CardContent/BuyButton").pressed.connect(func(): buy_bait("Exotic"))


func _on_shop_toggle_pressed():
	interact.play()
	if showing_bait_shop:
		show_upgrade_shop()
	else:
		show_bait_shop()


# ============================================
# SHOP VIEW SWITCHING
# ============================================

func show_upgrade_shop():
	showing_bait_shop = false
	upgrade_panel.visible = true
	bait_shop_panel.visible = false
	shop_toggle_button.text = "🎣 Köder"


func show_bait_shop():
	showing_bait_shop = true
	upgrade_panel.visible = false
	bait_shop_panel.visible = true
	shop_toggle_button.text = "⚙️ Upgrades"
	update_bait_ui()


# ============================================
# KÖDER KAUFEN
# ============================================

func buy_bait(rarity: String):
	if Player.buy_bait(rarity, 1):
		interact.play()
		splash.restart()
		
		var card: PanelContainer
		match rarity:
			"Ungewöhnlich": card = uncommon_bait_card
			"Selten": card = rare_bait_card
			"Episch": card = epic_bait_card
			"Legendär": card = legendary_bait_card
			"Exotisch": card = exotic_bait_card
		
		#play_purchase_effect(card)
		update_ui()
		update_bait_ui()


# ============================================
# UPGRADES
# ============================================

func calculate_cost(base_cost: int, level: int) -> int:
	return int(base_cost * pow(1.3, level - 1))


func update_ui():
	# Geld
	money_label.text = "💰 %d €" % Player.money
	
	# Grip
	var grip_cost = calculate_cost(base_grip_cost, Player.upgrade_grip)
	grip_level_label.text = "Level %d" % Player.upgrade_grip
	grip_desc_label.text = "+%d%% Sweetspot\nProgress" % (Player.upgrade_grip * 15)
	grip_price_label.text = "%d €" % grip_cost
	grip_button.disabled = (Player.money < grip_cost)
	
	# Bait
	var bait_cost = calculate_cost(base_bait_cost, Player.upgrade_bait)
	bait_level_label.text = "Level %d" % Player.upgrade_bait
	bait_desc_label.text = "+%d%% Seltene\nItems Chance" % (Player.upgrade_bait * 10)
	bait_price_label.text = "%d €" % bait_cost
	bait_button.disabled = (Player.money < bait_cost)
	
	# Line
	var line_cost = calculate_cost(base_line_cost, Player.upgrade_line)
	line_level_label.text = "Level %d" % Player.upgrade_line
	line_desc_label.text = "-%d%% Warte-\nzeit" % (Player.upgrade_line * 8)
	line_price_label.text = "%d €" % line_cost
	line_button.disabled = (Player.money < line_cost)
	
	update_bait_ui()


# ============================================
# KÖDER SHOP UI UPDATE
# ============================================

func update_bait_ui():
	update_bait_card(uncommon_bait_card, "Uncommon", Color(0.4, 0.8, 0.4))
	update_bait_card(rare_bait_card, "Rare", Color(0.3, 0.5, 1.0))
	update_bait_card(epic_bait_card, "Epic", Color(0.7, 0.3, 1.0))
	update_bait_card(legendary_bait_card, "Legendary", Color(1.0, 0.6, 0.0))
	update_bait_card(exotic_bait_card, "Exotic", Color(1.0, 0.2, 0.5))


func update_bait_card(card: PanelContainer, rarity: String, color: Color):
	var content = card.get_node("CardContent")
	var title_label = content.get_node("TitleLabel")
	var stock_label = content.get_node("StockLabel")
	var desc_label = content.get_node("DescLabel")
	var price_label = content.get_node("PriceLabel")
	var buy_button = content.get_node("BuyButton")
	
	title_label.text = "%s-Köder" % rarity
	title_label.modulate = color
	
	var stock = Player.bait_inventory.get(rarity, 0)
	stock_label.text = "Vorrat: %d" % stock
	
	desc_label.text = "Garantiert %s\nFisch!" % rarity
	
	var price = Player.BAIT_PRICES[rarity]
	price_label.text = "%d €" % price
	
	buy_button.disabled = (Player.money < price)


# ============================================
# FX
# ============================================

func play_intro_animation():
	var shop_container = $UI/ShopContainer
	shop_container.modulate.a = 0
	
	var tween = create_tween()
	tween.tween_property(shop_container, "modulate:a", 1.0, 0.3)
	
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
	
	var scale_tween = create_tween()
	scale_tween.tween_property(card, "scale", Vector2(1.05, 1.05), 0.1)
	scale_tween.tween_property(card, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)


# ============================================
# Kleine Rotation des Rod-Preview
# ============================================

func _process(delta):
	rod_preview.rotate_y(delta * 0.5)


# ============================================
# Upgrade Buttons
# ============================================

func _on_GripButton_pressed():
	var grip_cost = calculate_cost(base_grip_cost, Player.upgrade_grip)
	if Player.money >= grip_cost:
		Player.money -= grip_cost
		Player.upgrade_grip += 1
		Player.save_game()
		interact.play()
		splash.restart()
		play_purchase_effect($UI/ShopContainer/MainPanel/VBoxContainer/UpgradeCards/GripCard)
		update_ui()


func _on_BaitButton_pressed():
	var bait_cost = calculate_cost(base_bait_cost, Player.upgrade_bait)
	if Player.money >= bait_cost:
		Player.money -= bait_cost
		Player.upgrade_bait += 1
		Player.save_game()
		interact.play()
		splash.restart()
		play_purchase_effect($UI/ShopContainer/MainPanel/VBoxContainer/UpgradeCards/BaitCard)
		update_ui()


func _on_LineButton_pressed():
	var line_cost = calculate_cost(base_line_cost, Player.upgrade_line)
	if Player.money >= line_cost:
		Player.money -= line_cost
		Player.upgrade_line += 1
		Player.save_game()
		interact.play()
		splash.restart()
		play_purchase_effect($UI/ShopContainer/MainPanel/VBoxContainer/UpgradeCards/LineCard)
		update_ui()


func _on_BackButton_pressed():
	Player.go_to_last_scene()
