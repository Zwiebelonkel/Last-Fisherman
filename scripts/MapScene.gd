extends Control

const NumberFormat = preload("res://scripts/NumberFormat.gd")

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

# ─── Location display names ───────────────────────────────────────────────────
var location_names := {
	"lake":    { "de": "Strand",  "en": "Beach", "ru": "Пляж", "tr": "Sahil", "es": "Playa", "fr": "Plage", "pl": "Plaża"   },
	"city":    { "de": "Stadt",   "en": "City", "ru": "Город", "tr": "Şehir", "es": "Ciudad", "fr": "Ville", "pl": "Miasto"     },
	"sewer":   { "de": "U-Bahn",  "en": "Subway", "ru": "Метро", "tr": "Metro", "es": "Metro", "fr": "Métro", "pl": "Metro"   },
	"forest":  { "de": "Wald",    "en": "Forest", "ru": "Лес", "tr": "Orman", "es": "Bosque", "fr": "Forêt", "pl": "Las"   },
	"desert":  { "de": "Wüste",   "en": "Desert", "ru": "Пустыня", "tr": "Çöl", "es": "Desierto", "fr": "Désert", "pl": "Pustynia"   },
	"iceland": { "de": "Eisland", "en": "Iceland", "ru": "Ледяной край", "tr": "Buz Diyarı", "es": "Tierra helada", "fr": "Terre de glace", "pl": "Kraina lodu"  },
	"home":    { "de": "Zuhause", "en": "Home", "ru": "Дом", "tr": "Ev", "es": "Casa", "fr": "Maison", "pl": "Dom"     },
	"van":     { "de": "Imbiss",  "en": "Van", "ru": "Фургон", "tr": "Minibüs", "es": "Furgoneta", "fr": "Camion", "pl": "Furgonetka"      },
}

var location_descs := {
	"lake":    { "de": "Küstenabschnitt. Hohe Fischdichte.",           "en": "Coastline. High fish density.", "ru": "Побережье. Много рыбы.", "tr": "Kıyı şeridi. Yoğun balık nüfusu.", "es": "Costa. Alta densidad de peces.", "fr": "Littoral. Forte densité de poissons.", "pl": "Wybrzeże. Duże zagęszczenie ryb."          },
	"city":    { "de": "Städtisches Gebiet. Regnet seid Tagen.", "en": "Urban zone. Raining fro days.", "ru": "Городская зона. Дождь идёт уже несколько дней.", "tr": "Kentsel bölge. Günlerdir yağmur yağıyor.", "es": "Zona urbana. Lleva días lloviendo.", "fr": "Zone urbaine. Il pleut depuis des jours.", "pl": "Strefa miejska. Pada od wielu dni."       },
	"sewer":   { "de": "Unterirdisches Netz. Unbekannte Entitäten.",   "en": "Underground network. Unknown entities.", "ru": "Подземная сеть. Неизвестные сущности.", "tr": "Yer altı ağı. Bilinmeyen varlıklar.", "es": "Red subterránea. Entidades desconocidas.", "fr": "Réseau souterrain. Entités inconnues.", "pl": "Podziemna sieć. Nieznane istoty." },
	"forest":  { "de": "Dichtes Blätterdach. Anomale Signale.",        "en": "Dense canopy. Strange signals.", "ru": "Густой полог леса. Странные сигналы.", "tr": "Sık ağaç örtüsü. Garip sinyaller.", "es": "Copas densas. Señales extrañas.", "fr": "Canopée dense. Signaux étranges.", "pl": "Gęste korony drzew. Dziwne sygnały."         },
	"desert":  { "de": "Ödland. Extreme UV. Strahlentaschen.",         "en": "Wasteland. Extreme UV. Radiation.", "ru": "Пустошь. Сильный ультрафиолет. Радиация.", "tr": "Issız topraklar. Aşırı UV. Radyasyon.", "es": "Páramo. Radiación UV extrema. Radiactividad.", "fr": "Terre désolée. UV extrêmes. Radiations.", "pl": "Pustkowie. Skrajne UV. Promieniowanie."      },
	"iceland": { "de": "Gletschergelände. Friert unter -30 °C.",       "en": "Glacial terrain. Freezes at -30°C.", "ru": "Ледниковая местность. Мороз ниже −30 °C.", "tr": "Buzul arazisi. -30°C'de donar.", "es": "Terreno glaciar. Se congela a -30 °C.", "fr": "Terrain glaciaire. Gèle à -30 °C.", "pl": "Teren lodowcowy. Zamarza przy -30°C."     },
	"home":    { "de": "Sicherheitszone. Ausruhen und aufwerten.",     "en": "Safe zone. Rest and upgrade.", "ru": "Безопасная зона. Отдых и улучшения.", "tr": "Güvenli bölge. Dinlen ve yükselt.", "es": "Zona segura. Descansa y mejora.", "fr": "Zone sûre. Repos et améliorations.", "pl": "Bezpieczna strefa. Odpoczynek i ulepszenia."           },
	"van":     { "de": "Vendor-Einheit. Teile sammeln.",               "en": "Vendor unit. Collect all parts.", "ru": "Торговая точка. Собери все детали.", "tr": "Satıcı birimi. Tüm parçaları topla.", "es": "Puesto de venta. Reúne todas las piezas.", "fr": "Commerce ambulant. Récupère toutes les pièces.", "pl": "Punkt handlowy. Zbierz wszystkie części."        },
}

var location_icons := {
	"lake": "🏖", "city": "🏙", "sewer": "🚇", "forest": "🌲",
	"desert": "🏜", "iceland": "🧊", "home": "🏠", "van": "🚐",
}

var localized_texts := {
	"unlocked":      { "de": "◉ Freigeschaltet",                      "en": "◉ Unlocked", "ru": "◉ Открыто", "tr": "◉ Açıldı", "es": "◉ Desbloqueado", "fr": "◉ Débloqué", "pl": "◉ Odblokowano"                        },
	"price":         { "de": "Preis: %s $",                           "en": "Price: %s $", "ru": "Цена: %s $", "tr": "Fiyat: %s $", "es": "Precio: %s $", "fr": "Prix : %s $", "pl": "Cena: %s $"                       },
	"buy_button":    { "de": "  KAUFEN (%s $)",                      "en": "  BUY (%s $)", "ru": "  КУПИТЬ (%s $)", "tr": "  SATIN AL (%s $)", "es": "  COMPRAR (%s $)", "fr": "  ACHETER (%s $)", "pl": "  KUP (%s $)"                    },
	"no_money":      { "de": "✗  KEIN GELD",                          "en": "✗  INSUFFICIENT FUNDS", "ru": "✗  НЕ ХВАТАЕТ ДЕНЕГ", "tr": "✗  YETERSİZ PARA", "es": "✗  FONDOS INSUFICIENTES", "fr": "✗  FONDS INSUFFISANTS", "pl": "✗  ZA MAŁO PIENIĘDZY"             },
	"vendor_locked": { "de": "Sammle alle Teile",                     "en": "Collect all parts", "ru": "Собери все детали", "tr": "Tüm parçaları topla", "es": "Reúne todas las piezas", "fr": "Récupère toutes les pièces", "pl": "Zbierz wszystkie części"                 },
	"vendor_parts":  { "de": "TEILE: %d/%d",                         "en": "PARTS: %d/%d", "ru": "ДЕТАЛИ: %d/%d", "tr": "PARÇALAR: %d/%d", "es": "PIEZAS: %d/%d", "fr": "PIÈCES : %d/%d", "pl": "CZĘŚCI: %d/%d"                      },
	"unlocked_n":    { "de": "%d/8 freigeschaltet",                   "en": "%d/8 unlocked", "ru": "Открыто: %d/8", "tr": "%d/8 açıldı", "es": "%d/8 desbloqueados", "fr": "%d/8 débloqués", "pl": "Odblokowano: %d/8"                     },
	"vendor_items":  { "de": "Fehlende Teile:\n%s",                   "en": "Missing parts:\n%s", "ru": "Недостающие детали:\n%s", "tr": "Eksik parçalar:\n%s", "es": "Piezas que faltan:\n%s", "fr": "Pièces manquantes :\n%s", "pl": "Brakujące części:\n%s"                },
}

var item_names := {
	"van":         { "de": "Food Truck Karosserie (Strand)", "en": "Food Truck Body (Beach)", "ru": "Кузов фургона (пляж)", "tr": "Yemek Kamyonu Gövdesi (Sahil)", "es": "Carrocería del puesto de comida (playa)", "fr": "Carrosserie du food truck (plage)", "pl": "Karoseria food trucka (plaża)"  },
	"opensign":    { "de": "Geöffnet-Schild (Stadt)",        "en": "Open Sign (City)", "ru": "Вывеска «Открыто» (город)", "tr": "Açık Tabelası (Şehir)", "es": "Cartel de abierto (ciudad)", "fr": "Enseigne « Ouvert » (ville)", "pl": "Szyld „Otwarte” (miasto)"         },
	"friteuse":    { "de": "Fritteuse (U-Bahn)",             "en": "Deep Fryer (Subway)", "ru": "Фритюрница (метро)", "tr": "Fritöz (Metro)", "es": "Freidora (metro)", "fr": "Friteuse (métro)", "pl": "Frytownica (metro)"      },
	"sushimesser": { "de": "Sushi-Messer (Wald)",            "en": "Sushi Knife (Forest)", "ru": "Нож для суши (лес)", "tr": "Suşi Bıçağı (Orman)", "es": "Cuchillo de sushi (bosque)", "fr": "Couteau à sushi (forêt)", "pl": "Nóż do sushi (las)"     },
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
	$DebugMenu.values_changed.connect(_on_debug_values_changed)

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

# ─── Button assignment (unverändert, nur Popup → Sidebar) ────────────────────
func assign_button(btn: Button, spot_name: String) -> void:
	btn.pressed.connect(func(): show_spot_sidebar(spot_name))
	if Player.unlocked_spots.get(spot_name, false):
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
	ScenePreloader.prefetch_destination(ScenePreloader.LOCATION_SCENES[spot_name])
	var price    : int  = Player.spot_prices[spot_name]
	var unlocked : bool = Player.unlocked_spots.get(spot_name, false)

	sidebar.visible = true

	detail_icon.text = location_icons.get(spot_name, "")
	detail_name.text = get_location_name(spot_name)
	detail_desc.bbcode_enabled = true
	detail_desc.text = "[color=#7aaa7a]" + get_location_desc(spot_name) + "[/color]"

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
		detail_price.text = get_text("price") % NumberFormat.compact(price)
		detail_price.add_theme_color_override("font_color", Color(0.961, 0.620, 0.043, 1))
		btn_go.visible  = false
		btn_buy.visible = true
		if Player.money >= price:
			btn_buy.text     = get_text("buy_button") % NumberFormat.compact(price)
			btn_buy.disabled = false
		else:
			btn_buy.text     = get_text("no_money")
			btn_buy.disabled = true

	_reconnect_buttons(spot_name, unlocked)
	_refresh_status()

func _reconnect_buttons(spot_name: String, unlocked: bool) -> void:
	_disconnect_all(btn_go)
	_disconnect_all(btn_buy)
	if unlocked:
		btn_go.pressed.connect(func(): go_to_spot(spot_name))
	else:
		btn_buy.pressed.connect(func(): buy_spot(spot_name))

# ─── Status panel ─────────────────────────────────────────────────────────────
func _refresh_status() -> void:
	var n := 0
	for spot in Player.unlocked_spots:
		if Player.unlocked_spots[spot]:
			n += 1
	unlocked_count.text = get_text("unlocked_n") % n
	var pct : float = float(n) / 8.0
	global_fill.anchor_right = pct
	global_fill.offset_right = 0

# ─── Buy / travel (original logic) ───────────────────────────────────────────
func buy_spot(spot_name: String) -> void:
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
	interact.play()
	var target: String = ScenePreloader.LOCATION_SCENES.get(spot_name, "")
	if target.is_empty():
		return
	Player.update_last_scene(target)
	Transition.change_scene(target, 0.8)

# Refresh the selected location after changing money in the debug menu.
func _on_debug_values_changed() -> void:
	_refresh_status()
	if sidebar.visible and not selected_spot.is_empty():
		show_spot_sidebar(selected_spot)

# ─── Util ─────────────────────────────────────────────────────────────────────
func _disconnect_all(btn: Button) -> void:
	for c in btn.pressed.get_connections():
		btn.pressed.disconnect(c.callable)
