extends Control

# ─── Original button refs (unverändert) ───────────────────────────────────────
@onready var lake_btn    : Button = $layout/Locations/BeachButton
@onready var city_btn    : Button = $layout/Locations/CityButton
@onready var sewer_btn   : Button = $layout/Locations/SewerButton
@onready var forest_btn  : Button = $layout/Locations/ForestButton
@onready var desert_btn  : Button = $layout/Locations/DesertButton
@onready var iceland_btn : Button = $layout/Locations/IcelandButton
@onready var home_btn    : Button = $layout/Locations/HomeButton
@onready var van_btn     : Button = $layout/Locations/RestaurantButton
@onready var back_btn    : Button = $layout/BackButton
@onready var interact    : AudioStreamPlayer = $Audio/interact
@onready var password_field : TextEdit = $password

# ─── Neue Sidebar refs ────────────────────────────────────────────────────────
@onready var sidebar          : Panel         = $Sidebar
@onready var detail_icon      : Label         = $Sidebar/SidebarMargin/SidebarVBox/DetailIcon
@onready var detail_name      : Label         = $Sidebar/SidebarMargin/SidebarVBox/DetailName
@onready var detail_desc      : RichTextLabel = $Sidebar/SidebarMargin/SidebarVBox/DetailDesc
@onready var detail_price     : Label         = $Sidebar/SidebarMargin/SidebarVBox/DetailPrice
@onready var vendor_progress  : VBoxContainer = $Sidebar/SidebarMargin/SidebarVBox/VendorProgress
@onready var vendor_label     : Label         = $Sidebar/SidebarMargin/SidebarVBox/VendorProgress/VendorLabel
@onready var progress_fill    : Panel         = $Sidebar/SidebarMargin/SidebarVBox/VendorProgress/ProgressBG/ProgressFill
@onready var vendor_items_box : VBoxContainer = $Sidebar/SidebarMargin/SidebarVBox/VendorProgress/VendorItems
@onready var unlocked_count   : Label         = $Sidebar/SidebarMargin/SidebarVBox/UnlockedCount
@onready var global_fill      : Panel         = $Sidebar/SidebarMargin/SidebarVBox/GlobalProgressBG/GlobalProgressFill
@onready var btn_go           : Button        = $Sidebar/SidebarMargin/SidebarVBox/ActionContainer/BtnGo
@onready var btn_buy          : Button        = $Sidebar/SidebarMargin/SidebarVBox/ActionContainer/BtnBuy
@onready var btn_close        : Button        = $Sidebar/SidebarMargin/SidebarVBox/ActionContainer/BtnClose

var selected_spot := ""

const DEMO_UNLOCKED_SPOTS = ["lake"]
const DEMO_LOCKED_COLOR = Color(0.24, 0.24, 0.24, 0.85)


# ─── Location display names ───────────────────────────────────────────────────
var location_names := {
	"lake":    { "de": "Strand",  "en": "Beach"   },
	"city":    { "de": "Stadt",   "en": "City"     },
	"sewer":   { "de": "U-Bahn",  "en": "Subway"   },
	"forest":  { "de": "Wald",    "en": "Forest"   },
	"desert":  { "de": "Wüste",   "en": "Desert"   },
	"iceland": { "de": "Eisland", "en": "Iceland"  },
	"home":    { "de": "Zuhause", "en": "Home"     },
	"van":     { "de": "Imbiss",  "en": "Van"      },
}

var location_descs := {
	"lake":    { "de": "Küstenabschnitt. Hohe Fischdichte.",           "en": "Coastline. High fish density."          },
	"city":    { "de": "Städtisches Gebiet. Regnet seid Tagen.", "en": "Urban zone. Raining fro days."       },
	"sewer":   { "de": "Unterirdisches Netz. Unbekannte Entitäten.",   "en": "Underground network. Unknown entities." },
	"forest":  { "de": "Dichtes Blätterdach. Anomale Signale.",        "en": "Dense canopy. Strange signals."         },
	"desert":  { "de": "Ödland. Extreme UV. Strahlentaschen.",         "en": "Wasteland. Extreme UV. Radiation."      },
	"iceland": { "de": "Gletschergelände. Friert unter -30 °C.",       "en": "Glacial terrain. Freezes at -30°C."     },
	"home":    { "de": "Sicherheitszone. Ausruhen und aufwerten.",     "en": "Safe zone. Rest and upgrade."           },
	"van":     { "de": "Vendor-Einheit. Teile sammeln.",               "en": "Vendor unit. Collect all parts."        },
}

var location_icons := {
	"lake": "🏖", "city": "🏙", "sewer": "🚇", "forest": "🌲",
	"desert": "🏜", "iceland": "🧊", "home": "🏠", "van": "🚐",
}

var localized_texts := {
	"unlocked":      { "de": "◉ Freigeschaltet",                      "en": "◉ Unlocked"                        },
	"price":         { "de": "Preis: %d $",                           "en": "Price: %d $"                       },
	"buy_button":    { "de": "  KAUFEN (%d $)",                      "en": "  BUY (%d $)"                    },
	"no_money":      { "de": "✗  KEIN GELD",                          "en": "✗  INSUFFICIENT FUNDS"             },
	"vendor_locked": { "de": "Sammle alle Teile",                     "en": "Collect all parts"                 },
	"vendor_parts":  { "de": "TEILE: %d/%d",                         "en": "PARTS: %d/%d"                      },
	"unlocked_n":    { "de": "%d/8 freigeschaltet",                   "en": "%d/8 unlocked"                     },
	"vendor_items":  { "de": "Fehlende Teile:\n%s",                   "en": "Missing parts:\n%s"                },
	"end_demo":     { "de": "END OF DEMO",                         "en": "END OF DEMO"                       },
	"end_demo_desc": { "de": "Diese Karte ist in der Demo noch nicht verfügbar. Danke fürs Spielen!", "en": "This map is not available in the demo yet. Thanks for playing!" },
	"demo_unlocked_n": { "de": "1/1 Demo-Karte verfügbar",           "en": "1/1 demo map available"             },
}

var item_names := {
	"van":         { "de": "Food Truck Karosserie (Strand)", "en": "Food Truck Body (Beach)"  },
	"opensign":    { "de": "Geöffnet-Schild (Stadt)",        "en": "Open Sign (City)"         },
	"friteuse":    { "de": "Fritteuse (U-Bahn)",             "en": "Deep Fryer (Subway)"      },
	"sushimesser": { "de": "Sushi-Messer (Wald)",            "en": "Sushi Knife (Forest)"     },
}

# ─── Ready ────────────────────────────────────────────────────────────────────
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	assign_button(lake_btn,    "lake")
	assign_button(city_btn,    "city")
	assign_button(sewer_btn,   "sewer")
	assign_button(forest_btn,  "forest")
	assign_button(desert_btn,  "desert")
	assign_button(iceland_btn, "iceland")
	assign_button(home_btn,    "home")
	assign_button(van_btn,     "van")

	sidebar.visible = false
	btn_close.pressed.connect(hide_sidebar)
	back_btn.pressed.connect(go_back)

	if not Player.vendor_unlocked.is_connected(_on_vendor_unlocked):
		Player.vendor_unlocked.connect(_on_vendor_unlocked)

	_refresh_status()

# ─── Vendor unlocked signal ───────────────────────────────────────────────────
func _on_vendor_unlocked() -> void:
	assign_button(van_btn, "van")
	_refresh_status()
	if selected_spot == "van":
		show_spot_sidebar("van")

# ─── Localisation helpers ─────────────────────────────────────────────────────
func get_text(key: String) -> String:
	var lang := Player.current_language
	if localized_texts.has(key):
		var e = localized_texts[key]
		return e.get(lang, e.get("de", key))
	return key

func get_location_name(spot: String) -> String:
	var lang := Player.current_language
	if location_names.has(spot):
		return location_names[spot].get(lang, location_names[spot].get("de", spot))
	return spot.capitalize()

func get_location_desc(spot: String) -> String:
	var lang := Player.current_language
	if location_descs.has(spot):
		return location_descs[spot].get(lang, location_descs[spot].get("de", ""))
	return ""

func get_item_name(item_id: String) -> String:
	var lang := Player.current_language
	if item_names.has(item_id):
		return item_names[item_id].get(lang, item_names[item_id].get("de", item_id))
	return item_id.capitalize()

func is_demo_locked_spot(spot_name: String) -> bool:
	return not DEMO_UNLOCKED_SPOTS.has(spot_name)

# ─── Button assignment (unverändert, nur Popup → Sidebar) ────────────────────
func assign_button(btn: Button, spot_name: String) -> void:
	btn.pressed.connect(func(): show_spot_sidebar(spot_name))
	btn.disabled = false
	if is_demo_locked_spot(spot_name):
		btn.modulate = DEMO_LOCKED_COLOR
	elif Player.unlocked_spots.get(spot_name, false):
		btn.modulate = Color.WHITE
	else:
		btn.modulate = Color(0.4, 0.4, 0.4)

func hide_sidebar() -> void:
	sidebar.visible = false

func go_back() -> void:
	Player.go_to_last_scene()

# ─── Show sidebar ─────────────────────────────────────────────────────────────
func show_spot_sidebar(spot_name: String) -> void:
	interact.play()
	selected_spot = spot_name
	var price    : int  = Player.spot_prices[spot_name]
	var unlocked : bool = Player.unlocked_spots.get(spot_name, false)

	sidebar.visible = true

	detail_icon.text = location_icons.get(spot_name, "")
	detail_name.text = get_location_name(spot_name)
	detail_desc.bbcode_enabled = true
	detail_desc.text = "[color=#7aaa7a]" + get_location_desc(spot_name) + "[/color]"

	if is_demo_locked_spot(spot_name):
		detail_desc.text += "\n\n[color=#f59e0b]" + get_text("end_demo_desc") + "[/color]"
		detail_price.text = get_text("end_demo")
		detail_price.add_theme_color_override("font_color", Color(0.961, 0.620, 0.043, 1))
		vendor_progress.visible = false
		btn_go.visible = false
		btn_buy.visible = true
		btn_buy.text = get_text("end_demo")
		btn_buy.disabled = true
		_reconnect_buttons(spot_name, false)
		_refresh_status()
		return

	# ── Van special case ──
	if spot_name == "van":
		if unlocked:
			detail_price.text = get_text("unlocked")
			detail_price.add_theme_color_override("font_color", Color(0.290, 0.871, 0.502, 1))
			vendor_progress.visible = false
			btn_go.visible  = true
			btn_buy.visible = false
		else:
			var prog  = Player.get_story_item_progress()
			var found : int   = prog["found"]
			var total : int   = prog["total"]
			var pct   : float = float(found) / float(total) if total > 0 else 0.0

			detail_price.text = get_text("vendor_locked")
			detail_price.add_theme_color_override("font_color", Color(0.784, 0.847, 0.769, 0.7))

			vendor_label.text = get_text("vendor_parts") % [found, total]
			progress_fill.anchor_right = pct
			progress_fill.offset_right = 0

			for c in vendor_items_box.get_children():
				c.queue_free()
			for item_id in Player.REQUIRED_STORY_ITEMS:
				var has_it : bool = Player.used_story_items.has(item_id)
				var lbl := Label.new()
				lbl.add_theme_font_size_override("font_size", 9)
				lbl.text = ("%s  %s" % [("✓" if has_it else "—"), get_item_name(item_id)])
				if has_it:
					lbl.add_theme_color_override("font_color", Color(0.290, 0.871, 0.502, 1))
				else:
					lbl.add_theme_color_override("font_color", Color(0.353, 0.471, 0.353, 0.5))
				vendor_items_box.add_child(lbl)

			vendor_progress.visible = true
			btn_go.visible  = false
			btn_buy.visible = false

		_reconnect_buttons(spot_name, unlocked)
		_refresh_status()
		return

	# ── Normal spots ──
	vendor_progress.visible = false

	if unlocked:
		detail_price.text = get_text("unlocked")
		detail_price.add_theme_color_override("font_color", Color(0.290, 0.871, 0.502, 1))
		btn_go.visible  = true
		btn_buy.visible = false
	else:
		detail_price.text = get_text("price") % price
		detail_price.add_theme_color_override("font_color", Color(0.961, 0.620, 0.043, 1))
		btn_go.visible  = false
		btn_buy.visible = true
		if Player.money >= price:
			btn_buy.text     = get_text("buy_button") % price
			btn_buy.disabled = false
		else:
			btn_buy.text     = get_text("no_money")
			btn_buy.disabled = true

	_reconnect_buttons(spot_name, unlocked)
	_refresh_status()

func _reconnect_buttons(spot_name: String, unlocked: bool) -> void:
	_disconnect_all(btn_go)
	_disconnect_all(btn_buy)
	if is_demo_locked_spot(spot_name):
		return
	if unlocked:
		btn_go.pressed.connect(func(): go_to_spot(spot_name))
	else:
		btn_buy.pressed.connect(func(): buy_spot(spot_name))

# ─── Status panel ─────────────────────────────────────────────────────────────
func _refresh_status() -> void:
	var n := 0
	for spot in DEMO_UNLOCKED_SPOTS:
		if Player.unlocked_spots.get(spot, false):
			n += 1
	unlocked_count.text = get_text("demo_unlocked_n")
	var pct : float = 1.0 if n > 0 else 0.0
	global_fill.anchor_right = pct
	global_fill.offset_right = 0

# ─── Buy / travel (original logic) ───────────────────────────────────────────
func buy_spot(spot_name: String) -> void:
	if is_demo_locked_spot(spot_name):
		show_spot_sidebar(spot_name)
		return
	var cost : int = Player.spot_prices[spot_name]
	if Player.money < cost:
		return
	Player.money -= cost
	Player.unlocked_spots[spot_name] = true
	Player.save_game()
	interact.play()
	SteamAchievements.on_biome_bought(spot_name)
	hide_sidebar()
	assign_button(lake_btn,    "lake")
	assign_button(city_btn,    "city")
	assign_button(sewer_btn,   "sewer")
	assign_button(forest_btn,  "forest")
	assign_button(desert_btn,  "desert")
	assign_button(iceland_btn, "iceland")
	assign_button(home_btn,    "home")
	assign_button(van_btn,     "van")

func go_to_spot(spot_name: String) -> void:
	if is_demo_locked_spot(spot_name):
		show_spot_sidebar(spot_name)
		return
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
		"van":
			Player.update_last_scene("res://scenes/fischbude.tscn")
			Transition.change_scene("res://scenes/fischbude.tscn", 0.8)

# ─── Cheat console (unverändert) ─────────────────────────────────────────────
func _on_submit_pressed() -> void:
	var password : String = password_field.text
	password_field.clear()
	match password:
		"money": Player.add_money(1000000000000000)
		"fish":  Player._add_all_fish()
		"grip":  Player.upgrade_grip = 500
		"bait":  Player.upgrade_bait = 500
		"line":  Player.upgrade_line = 500
		"*":     Player.set_money(Player.money * 100)
		"vendor":
			for item_id in Player.REQUIRED_STORY_ITEMS:
				if not Player.used_story_items.has(item_id):
					Player.used_story_items.append(item_id)
			Player.check_vendor_unlock()
			assign_button(van_btn, "van")
		_: return

# ─── Util ─────────────────────────────────────────────────────────────────────
func _disconnect_all(btn: Button) -> void:
	for c in btn.pressed.get_connections():
		btn.pressed.disconnect(c.callable)
