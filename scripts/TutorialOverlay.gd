extends CanvasLayer
# TutorialOverlay.gd
# Zeigt beim ersten Spielstart die Steuerung

@onready var panel: Panel = $Panel
@onready var title: Label = $Panel/VBox/Title
@onready var content: VBoxContainer = $Panel/VBox/Content
@onready var close_button: Button = $Panel/VBox/CloseButton
@onready var page_indicator: Label = $Panel/VBox/PageIndicator
@onready var welcome: AudioStreamPlayer = $welcome


const VCR_FONT := preload("res://fonts/VCR_OSD_MONO_1.001.ttf")
var current_page: int = 0
var total_pages: int = 3

# Tutorial-Texte (DE/EN)
var tutorial_pages = {
	"de": [
		{
			"title": "Angeln - Die Basics",
			"controls": [
				"LINKSKLICK / Leertaste HALTEN = Angel aufladen",
				"LOSLASSEN = Auswerfen!",
				"",
				"Warte bis ein Fisch anbeißt...",
				"Der Indikator blinkt wenn ein Fisch da ist!",
				"",
				"LINKSKLICK / Leertaste bei Biss = Einholen starten",
				"LINKSKLICK / Leertaste HALTEN = Marker bremsen",
				"Marker muss im farbigen Bereich sein!",
				"Außerhalb = Fortschritt geht verloren"
			]
		},
		{
			"title": "Kamera & Menüs",
			"controls": [
				"LINKS / A = Kamera nach links drehen",
				"RECHTS / D = Kamera nach rechts drehen",
				"LINKSKLICK / Leertaste beim Shop = Betreten",
				"",
				"Menüs:",
				"M = Weltkarte öffnen",
				"J = Fischlexikon öffnen",
				"I = Inventar öffnen",
				"ESC = Einstellungen/Pause"
			]
		},
		{
			"title": "Tipps & Geheimnisse",
			"controls": [
				"Je länger du hältst, desto weiter wirfst du!",
				"Bessere Köder = seltenere Fische",
				"Shop-Upgrades verbessern:",
				"   • Grip = Einfacher zu fangen",
				"   • Köder = Bessere Fische spawnen",
				"   • Leine = Schnellere Bisse",
				"",
				"GEHEIMNIS: Finde 4 leuchtende Teile!",
				"100 $ für jeden neuen Fisch",
				"Schaltet den Imbiss frei!"
			]
		}
	],
	"en": [
		{
			"title": "Fishing - The Basics",
			"controls": [
				"HOLD LEFT CLICK / Space = Charge cast",
				"RELEASE = Cast!",
				"",
				"Wait for a fish to bite...",
				"Indicator blinks when fish bites!",
				"",
				"LEFT CLICK / Space on bite = Start reeling",
				"HOLD LEFT CLICK / Space = Slow the marker",
				"Marker must be in marked area!",
				"Outside = Progress lost"
			]
		},
		{
			"title": "Camera & Menus",
			"controls": [
				"LEFT / A = Rotate camera left",
				"RIGHT / D = Rotate camera right",
				"LEFT CLICK / Space at shop = Enter",
				"",
				"Menus:",
				"M = Open world map",
				"J = Open fish journal",
				"I = Open inventory",
				"ESC = Settings/Pause"
			]
		},
		{
			"title": "Tips & Secrets",
			"controls": [
				"Longer charge = farther cast!",
				"Better bait = rarer fish",
				"Shop upgrades improve:",
				"   • Grip = Easier to catch",
				"   • Bait = Better fish spawn",
				"   • Line = Faster bites",
				"",
				"SECRET: Find 4 glowing parts!",
				"100 $ for every new fish",
				"Unlocks the food truck!"
			]
		}
	],
	"ru": [
		{
			"title": "Основы рыбалки",
			"controls": [
				"УДЕРЖИВАЙ ЛКМ / пробел = зарядить заброс",
				"ОТПУСТИ = заброс!",
				"",
				"Дождись, когда рыба клюнет...",
				"При поклёвке индикатор мигает!",
				"",
				"ЛКМ / пробел при поклёвке = начать вываживание",
				"УДЕРЖИВАЙ ЛКМ / пробел = замедлить маркер",
				"Держи маркер в отмеченной зоне!",
				"Вне зоны = потеря прогресса"
			]
		},
		{
			"title": "Камера и меню",
			"controls": [
				"ВЛЕВО / A = повернуть камеру влево",
				"ВПРАВО / D = повернуть камеру вправо",
				"ЛКМ / пробел у магазина = войти",
				"",
				"Меню:",
				"M = открыть карту мира",
				"J = открыть книгу рыб",
				"I = открыть инвентарь",
				"ESC = настройки/пауза"
			]
		},
		{
			"title": "Советы и секреты",
			"controls": [
				"Дольше заряжаешь — дальше забрасываешь!",
				"Лучше наживка — более редкая рыба",
				"Улучшения в магазине:",
				"   • Рукоять = легче ловить",
				"   • Наживка = лучше рыбы",
				"   • Леска = быстрее клюёт",
				"",
				"СЕКРЕТ: найди 4 светящиеся детали!",
				"100 $ за каждую новую рыбу",
				"Откроет фургон с едой!"
			]
		}
	],
	"tr": [
		{
			"title": "Balık Tutmanın Temelleri",
			"controls": [
				"SOL TIK / Boşluk BASILI TUT = Atışı şarj et",
				"BIRAK = Oltayı at!",
				"",
				"Bir balığın yemi ısırmasını bekle...",
				"Balık ısırınca gösterge yanıp söner!",
				"",
				"Isırınca SOL TIK / Boşluk = Sarmaya başla",
				"SOL TIK / Boşluk BASILI TUT = İşaretçiyi yavaşlat",
				"İşaretçi işaretli bölgede olmalı!",
				"Dışarıda = İlerleme kaybı"
			]
		},
		{
			"title": "Kamera ve Menüler",
			"controls": [
				"SOL / A = Kamerayı sola döndür",
				"SAĞ / D = Kamerayı sağa döndür",
				"Dükkânda SOL TIK / Boşluk = Gir",
				"",
				"Menüler:",
				"M = Dünya haritasını aç",
				"J = Balık günlüğünü aç",
				"I = Envanteri aç",
				"ESC = Ayarlar/Duraklat"
			]
		},
		{
			"title": "İpuçları ve Sırlar",
			"controls": [
				"Daha uzun şarj = Daha uzak atış!",
				"Daha iyi yem = Daha nadir balık",
				"Dükkân yükseltmeleri:",
				"   • Sap = Daha kolay yakalama",
				"   • Yem = Daha iyi balıklar çıkar",
				"   • Misina = Daha hızlı ısırık",
				"",
				"SIR: 4 parlayan parça bul!",
				"Her yeni balık için 100 $",
				"Yemek kamyonunun kilidini açar!"
			]
		}
	],
	"es": [
		{
			"title": "Pesca: lo básico",
			"controls": [
				"MANTÉN CLIC IZQUIERDO / Espacio = Cargar lance",
				"SUELTA = ¡Lanzar!",
				"",
				"Espera a que pique un pez...",
				"¡El indicador parpadea cuando pica un pez!",
				"",
				"CLIC IZQUIERDO / Espacio al picar = Recoger",
				"MANTÉN CLIC IZQUIERDO / Espacio = Frenar marcador",
				"¡El marcador debe estar en la zona marcada!",
				"Fuera = Pérdida de progreso"
			]
		},
		{
			"title": "Cámara y menús",
			"controls": [
				"IZQUIERDA / A = Girar cámara a la izquierda",
				"DERECHA / D = Girar cámara a la derecha",
				"CLIC IZQUIERDO / Espacio en la tienda = Entrar",
				"",
				"Menús:",
				"M = Abrir mapa del mundo",
				"J = Abrir diario de peces",
				"I = Abrir inventario",
				"ESC = Ajustes/Pausa"
			]
		},
		{
			"title": "Consejos y secretos",
			"controls": [
				"¡Más carga = Lance más lejano!",
				"Mejor cebo = Peces más raros",
				"Las mejoras de la tienda:",
				"   • Empuñadura = Capturas más fáciles",
				"   • Cebo = Aparecen mejores peces",
				"   • Sedal = Picadas más rápidas",
				"",
				"SECRETO: ¡Encuentra 4 piezas brillantes!",
				"100 $ por cada pez nuevo",
				"¡Desbloquea el puesto de comida!"
			]
		}
	],
	"fr": [
		{
			"title": "Les bases de la pêche",
			"controls": [
				"MAINTENIR CLIC GAUCHE / Espace = Charger le lancer",
				"RELÂCHER = Lancer !",
				"",
				"Attends qu'un poisson morde…",
				"L'indicateur clignote quand ça mord !",
				"",
				"CLIC GAUCHE / Espace à la touche = Ferrer",
				"MAINTENIR CLIC GAUCHE / Espace = Freiner le marqueur",
				"Garde le marqueur dans la zone colorée !",
				"En dehors = Perte de progression"
			]
		},
		{
			"title": "Caméra et menus",
			"controls": [
				"GAUCHE / A = Tourner la caméra à gauche",
				"DROITE / D = Tourner la caméra à droite",
				"CLIC GAUCHE / Espace à la boutique = Entrer",
				"",
				"Menus :",
				"M = Ouvrir la carte du monde",
				"J = Ouvrir le guide des poissons",
				"I = Ouvrir l'inventaire",
				"ÉCHAP = Paramètres/Pause"
			]
		},
		{
			"title": "Conseils et secrets",
			"controls": [
				"Charge plus longtemps pour lancer plus loin !",
				"Meilleurs appâts = Poissons plus rares",
				"Les améliorations de la boutique :",
				"   • Poignée = Captures plus faciles",
				"   • Appât = Apparition de meilleurs poissons",
				"   • Ligne = Touches plus rapides",
				"",
				"SECRET : Trouve 4 pièces lumineuses !",
				"100 $ pour chaque nouveau poisson",
				"Débloque le food truck !"
			]
		}
	],
	"pl": [
		{
			"title": "Podstawy wędkowania",
			"controls": [
				"PRZYTRZYMAJ LPM / Spację = Przygotuj rzut",
				"PUŚĆ = Zarzuć!",
				"",
				"Poczekaj, aż ryba weźmie…",
				"Wskaźnik miga, gdy ryba bierze!",
				"",
				"LPM / Spacja przy braniu = Zacznij holować",
				"PRZYTRZYMAJ LPM / Spację = Spowolnij znacznik",
				"Znacznik musi być w zaznaczonej strefie!",
				"Poza strefą = Utrata postępu"
			]
		},
		{
			"title": "Kamera i menu",
			"controls": [
				"LEWO / A = Obróć kamerę w lewo",
				"PRAWO / D = Obróć kamerę w prawo",
				"LPM / Spacja przy sklepie = Wejdź",
				"",
				"Menu:",
				"M = Otwórz mapę świata",
				"J = Otwórz atlas ryb",
				"I = Otwórz ekwipunek",
				"ESC = Ustawienia/Pauza"
			]
		},
		{
			"title": "Porady i sekrety",
			"controls": [
				"Dłuższe przytrzymanie = Dalszy rzut!",
				"Lepsza przynęta = Rzadsze ryby",
				"Ulepszenia w sklepie:",
				"   • Uchwyt = Łatwiejsze łowienie",
				"   • Przynęta = Lepsze ryby",
				"   • Żyłka = Szybsze brania",
				"",
				"SEKRET: Znajdź 4 świecące części!",
				"100 $ za każdą nową rybę",
				"Odblokowuje food trucka!"
			]
		}
	]
}

func _ready() -> void:
	print("🔍 DEBUG: TutorialOverlay _ready() gestartet")
	print("🔍 DEBUG: Player.tutorial_seen =", Player.tutorial_seen)
	
	# Prüfe ob Tutorial bereits gesehen
	if Player.tutorial_seen:
		print("⚠️ Tutorial bereits gesehen - wird übersprungen")
		queue_free()
		return
	
	print("🔍 DEBUG: Prüfe Nodes...")
	print("  - panel:", panel)
	print("  - title:", title)
	print("  - content:", content)
	print("  - close_button:", close_button)
	print("  - page_indicator:", page_indicator)
	
	# Setup UI
	print("🔍 DEBUG: _setup_ui() wird aufgerufen")
	_setup_ui()
	
	print("🔍 DEBUG: _show_page(0) wird aufgerufen")
	_show_page(0)

	
	# Sichtbarkeit prüfen
	print("🔍 DEBUG: Panel visible =", panel.visible)
	print("🔍 DEBUG: CanvasLayer visible =", visible)
	
	print("✅ Tutorial-Overlay gestartet")
	welcome.play()


func _setup_ui() -> void:
	print("🔍 DEBUG: _setup_ui() startet...")
	
	# Panel Setup
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -400
	panel.offset_top = -300
	panel.offset_right = 400
	panel.offset_bottom = 300
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.08, 0.98)
	style.border_color = Color(1.0, 0.9, 0.3)
	style.border_width_left = 4
	style.border_width_right = 4
	style.border_width_top = 4
	style.border_width_bottom = 4
	style.corner_radius_top_left = 15
	style.corner_radius_top_right = 15
	style.corner_radius_bottom_left = 15
	style.corner_radius_bottom_right = 15
	style.shadow_color = Color(0, 0, 0, 0.5)
	style.shadow_size = 20
	panel.add_theme_stylebox_override("panel", style)
	
	# Title Setup
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Page Indicator Setup
	page_indicator.add_theme_font_size_override("font_size", 18)
	page_indicator.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	page_indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Close Button Setup
	close_button.text = tr("TUTORIAL_NEXT")
	close_button.custom_minimum_size = Vector2(0, 60)
	
	# Button Style
	var btn_normal = StyleBoxFlat.new()
	btn_normal.bg_color = Color(1.0, 0.9, 0.3)
	btn_normal.corner_radius_top_left = 8
	btn_normal.corner_radius_top_right = 8
	btn_normal.corner_radius_bottom_left = 8
	btn_normal.corner_radius_bottom_right = 8
	
	var btn_hover = StyleBoxFlat.new()
	#btn_hover.bg_color = Color(1.0, 1.0, 0.5)
	btn_hover.corner_radius_top_left = 8
	btn_hover.corner_radius_top_right = 8
	btn_hover.corner_radius_bottom_left = 8
	btn_hover.corner_radius_bottom_right = 8
	
	close_button.add_theme_stylebox_override("normal", btn_normal)
	close_button.add_theme_stylebox_override("hover", btn_hover)
	close_button.add_theme_stylebox_override("pressed", btn_hover)
	close_button.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))
	close_button.add_theme_font_size_override("font_size", 24)
	
	close_button.pressed.connect(_on_next_pressed)
	
	print("✅ _setup_ui() abgeschlossen")


func _show_page(page: int) -> void:
	print("🔍 DEBUG: _show_page(", page, ") gestartet")
	current_page = page
	
	# Clear content
	for child in content.get_children():
		child.queue_free()
	
	# Get current language
	var lang = Player.current_language
	if not tutorial_pages.has(lang):
		lang = "de"  # Fallback
	
	print("🔍 DEBUG: Sprache =", lang)
	
	var page_data = tutorial_pages[lang][page]
	
	# Set title
	title.text = page_data["title"]
	print("🔍 DEBUG: Titel =", title.text)
	
	# Update page indicator
	page_indicator.text = tr("TUTORIAL_PAGE") % [page + 1, total_pages]
	
	# Add controls
	var control_count = 0
	for control_text in page_data["controls"]:
		if control_text == "":
			# Leerzeile für Spacing
			var spacer = Control.new()
			spacer.custom_minimum_size = Vector2(0, 10)
			content.add_child(spacer)
			continue
		
		var label = Label.new()
		label.add_theme_font_override("font", VCR_FONT)
		label.text = control_text
		
		# Größere Schrift für Hauptpunkte, kleinere für Sub-Items
		if control_text.begins_with("   "):
			label.add_theme_font_size_override("font_size", 18)
			label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
		else:
			label.add_theme_font_size_override("font_size", 22)
			label.add_theme_color_override("font_color", Color(0.95, 0.95, 0.95))
		
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.custom_minimum_size = Vector2(720, 0)
		content.add_child(label)
		control_count += 1
	
	print("🔍 DEBUG: ", control_count, " Controls hinzugefügt")
	
	# Update button text
	if current_page >= total_pages - 1:
		close_button.text = tr("TUTORIAL_START")
	else:
		close_button.text = tr("TUTORIAL_NEXT")
	
	print("✅ _show_page() abgeschlossen")


func _on_next_pressed() -> void:
	print("🔍 DEBUG: Button gedrückt, current_page =", current_page)
	if current_page >= total_pages - 1:
		_close_tutorial()
	else:
		_show_page(current_page + 1)


func _close_tutorial() -> void:
	print("🔍 DEBUG: Tutorial wird geschlossen...")
	
	# Markiere Tutorial als gesehen
	Player.tutorial_seen = true
	Player.save_game()
	print("🔍 DEBUG: tutorial_seen gesetzt und gespeichert")
	
	print("✅ Tutorial abgeschlossen")
	queue_free()


# Skip mit ESC
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause"):
		print("🔍 DEBUG: ESC gedrückt - Tutorial wird übersprungen")
		_close_tutorial()
		get_viewport().set_input_as_handled()
