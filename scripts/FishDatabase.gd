extends Node

# ===========================
#  RARITIES
# ===========================
enum RARITY {
	NORMAL,
	UNGEWOEHNLICH,
	SELTEN,
	EPISCH,
	LEGENDAER,
	EXOTISCH
}

var RARITY_DATA = {
	RARITY.NORMAL:        {"name": "Normal",       "color": Color.WHITE,     "value": 1.0,  "spawn_chance": 40.0, "difficulty": 1.0},
	RARITY.UNGEWOEHNLICH: {"name": "Ungewöhnlich", "color": Color(0.3,1,0.3), "value": 1.5,  "spawn_chance": 30.0, "difficulty": 1.3},
	RARITY.SELTEN:        {"name": "Selten",       "color": Color(0.2,0.4,1), "value": 2.0,  "spawn_chance": 15.0, "difficulty": 1.6},
	RARITY.EPISCH:        {"name": "Episch",       "color": Color(0.7,0,1),   "value": 3.0,  "spawn_chance": 10.0, "difficulty": 2.0},
	RARITY.LEGENDAER:     {"name": "Legendär",     "color": Color(1,0.8,0.1), "value": 6.0,  "spawn_chance": 4.0,  "difficulty": 2.5},
	RARITY.EXOTISCH:      {"name": "Exotisch",     "color": Color(1,0,0.2),   "value": 12.0, "spawn_chance": 1.0,  "difficulty": 3.0}
}

# ===========================
#  FISH LISTS BY LOCATION
# ===========================
var FISH_LAKE = [
	{"name": "Seetang", "rarity": RARITY.NORMAL, "base_value": 1, "icon": "res://assets/fish/seetang.png",
	 "description": "Technisch gesehen kein Fisch. Aber mach erstmal weiter.", "weight_min": 0.1, "weight_max": 0.3},
	
	{"name": "Makrele", "rarity": RARITY.NORMAL, "base_value": 4, "icon": "res://assets/fish/makrele.png",
	 "description": "Der Toyota Corolla unter den Fischen. Zuverlässig langweilig.", "weight_min": 0.3, "weight_max": 0.8},
	
	{"name": "Rotauge", "rarity": RARITY.NORMAL, "base_value": 5, "icon": "res://assets/fish/fish1.png",
	 "description": "Starrt dich vorwurfsvoll an. Hat wahrscheinlich Recht damit.", "weight_min": 0.2, "weight_max": 0.6},
	
	{"name": "Barsch", "rarity": RARITY.UNGEWOEHNLICH, "base_value": 8, "icon": "res://assets/fish/fish2.png",
	 "description": "Etwas stacheliger als deine Ex, aber weniger giftig.", "weight_min": 0.5, "weight_max": 1.5},
	
	{"name": "Thunfisch", "rarity": RARITY.UNGEWOEHNLICH, "base_value": 10, "icon": "res://assets/fish/tuna.png",
	 "description": "Keine Ahnung wie der hier gelandet ist... Der ist viel zu fett.", "weight_min": 5.0, "weight_max": 15.0},
	
	{"name": "Hecht", "rarity": RARITY.SELTEN, "base_value": 15, "icon": "res://assets/fish/fish3.png",
	 "description": "Sieht aus wie ein Unterwasser-Torpedo mit Zahnarztphobie.", "weight_min": 2.0, "weight_max": 6.0},
	
	{"name": "Zander", "rarity": RARITY.EPISCH, "base_value": 25, "icon": "res://assets/fish/fish4.png",
	 "description": "Der Hipster-Fisch. War schon cool, bevor es mainstream wurde.", "weight_min": 1.5, "weight_max": 4.0},
	
	{"name": "Kaugummikarpfen", "rarity": RARITY.EPISCH, "base_value": 28, "icon": "res://assets/fish/Kaugummi.png",
	 "description": "Schmeckt nach Erdbeere und existenzieller Krise.", "weight_min": 3.0, "weight_max": 8.0},
	
	{"name": "Karpfenkönigin", "rarity": RARITY.LEGENDAER, "base_value": 40, "icon": "res://assets/fish/Prinzessinor.png",
	 "description": "Erwartet, dass du kniest. Und das zu Recht.", "weight_min": 8.0, "weight_max": 15.0},
	
	{"name": "Geisterforelle", "rarity": RARITY.EXOTISCH, "base_value": 100, "icon": "res://assets/fish/fish6.png",
	 "description": "Ist tot. Schwimmt trotzdem. Frag nicht.", "weight_min": 0.5, "weight_max": 2.0},
	
	{"name": "Plutonium", "rarity": RARITY.EXOTISCH, "base_value": 150, "icon": "res://assets/fish/Plutonium.png",
	 "description": "Leuchtet im Dunkeln. FDA-Zulassung ausstehend. Nicht essbar", "weight_min": 10.0, "weight_max": 25.0}
]

var FISH_CITY = [
	{"name": "Sand-Aal", "rarity": RARITY.NORMAL, "base_value": 6, "icon": "res://assets/fish/Aal.png",
	 "description": "Schlüpfriger als ein Politiker im Wahlkampf.", "weight_min": 0.4, "weight_max": 1.2},
	
	{"name": "Signalfänger", "rarity": RARITY.NORMAL, "base_value": 7, "icon": "res://assets/fish/signal.png",
	 "description": "Hat besseren Empfang als dein Handy. Niemand mag den Bastard", "weight_min": 0.2, "weight_max": 0.5},
	
	{"name": "Trümmerkabel-Fisch", "rarity": RARITY.UNGEWOEHNLICH, "base_value": 10, "icon": "res://assets/fish/trümmer.png",
	 "description": "Ernährt sich von HDMI-Kabeln und zerbrochenen Träumen.", "weight_min": 1.0, "weight_max": 3.0},
	
	{"name": "Dorsch", "rarity": RARITY.UNGEWOEHNLICH, "base_value": 11, "icon": "res://assets/fish/dorsch.png",
	 "description": "Heißt auch Kabeljau. Hat eine Identitätskrise.", "weight_min": 2.0, "weight_max": 5.0},
	
	{"name": "Diskusfisch", "rarity": RARITY.SELTEN, "base_value": 18, "icon": "res://assets/fish/diskus.png",
	 "description": "Flach wie deine Ausreden, aber deutlich bunter.", "weight_min": 0.3, "weight_max": 1.0},
	
	{"name": "Barrakuda", "rarity": RARITY.SELTEN, "base_value": 25, "icon": "res://assets/fish/baracuda.png",
	 "description": "Schwimmt schneller als du vor Verantwortung fliehst.", "weight_min": 3.0, "weight_max": 10.0},
	
	{"name": "Neonflosser", "rarity": RARITY.EPISCH, "base_value": 30, "icon": "res://assets/fish/Eel.png",
	 "description": "Sieht aus wie ein Rave im Aquarium.", "weight_min": 1.0, "weight_max": 2.5},
	
	{"name": "Zigaretten", "rarity": RARITY.EPISCH, "base_value": 35, "icon": "res://assets/fish/Boro.png",
	 "description": "Marlboro Menthol. Seit 1987 im Wasser. Noch immer brennend aktuell.", "weight_min": 0.02, "weight_max": 0.05},
	
	{"name": "Altstadtgeist", "rarity": RARITY.LEGENDAER, "base_value": 55, "icon": "res://assets/fish/ghost.png",
	 "description": "Erzählt dir Geschichten von früher. Alle langweilig.", "weight_min": 0.1, "weight_max": 0.5},
	
	{"name": "Platzhalter", "rarity": RARITY.EXOTISCH, "base_value": 150, "icon": "res://assets/fish/unknown.png",
	 "description": "Existiert eigentlich nicht. Trotzdem gefangen. Paradox!", "weight_min": 0.0, "weight_max": 0.0},
	
	{"name": "Leiche", "rarity": RARITY.EXOTISCH, "base_value": 0, "icon": "res://assets/fish/corpse.png",
	 "description": "Markus?! Bitte nicht...", "weight_min": 60.0, "weight_max": 90.0},
	
	{"name": "Datenkrake", "rarity": RARITY.EXOTISCH, "base_value": 175, "icon": "res://assets/fish/krake.png",
	 "description": "Kennt deine Suchanfragen. Alle. Ja, auch die. Sicher das der Name richtig ist?", "weight_min": 10.0, "weight_max": 30.0}
]

var FISH_SEWER = [
	{"name": "Kackwurst", "rarity": RARITY.NORMAL, "base_value": 8, "icon": "res://assets/fish/kackwurst.png",
	 "description": "Exakt das, wonach es aussieht. Verkauf es schnell.", "weight_min": 0.1, "weight_max": 0.4},
	
	{"name": "Sardine", "rarity": RARITY.NORMAL, "base_value": 9, "icon": "res://assets/fish/sardine.png",
	 "description": "Möchte intensiv in eine Dose gepresst werden.", "weight_min": 0.05, "weight_max": 0.2},
	
	{"name": "Forelle", "rarity": RARITY.NORMAL, "base_value": 10, "icon": "res://assets/fish/forelle.png",
	 "description": "Hat schon bessere Tage gesehen. Und bessere Gewässer.", "weight_min": 0.3, "weight_max": 1.5},
	
	{"name": "Wels", "rarity": RARITY.UNGEWOEHNLICH, "base_value": 12, "icon": "res://assets/fish/Wels.png",
	 "description": "Sieht aus wie dein Schnurrbart nach drei Wochen Quarantäne.", "weight_min": 5.0, "weight_max": 20.0},
	
	{"name": "Teerfisch", "rarity": RARITY.SELTEN, "base_value": 20, "icon": "res://assets/fish/teerfisch.png",
	 "description": "50% Fisch, 50% Industrieabfall, 100% unverdaulich.", "weight_min": 2.0, "weight_max": 6.0},
	
	{"name": "Mondfisch", "rarity": RARITY.EPISCH, "base_value": 36, "icon": "res://assets/fish/mond.png",
	 "description": "Hat die Form einer Vollmondnacht und den IQ eines Kieselsteins.", "weight_min": 200.0, "weight_max": 600.0},
	
	{"name": "Katzenhai", "rarity": RARITY.EPISCH, "base_value": 40, "icon": "res://assets/fish/Boro.png",
	 "description": "Miaut unter Wasser. Wissenschaft kann es nicht erklären.", "weight_min": 3.0, "weight_max": 8.0},
	
	{"name": "Führerschein", "rarity": RARITY.LEGENDAER, "base_value": 80, "icon": "res://assets/fish/führerschein.png",
	 "description": "Abgelaufen seit 2003. Gehörte vermutlich Rainer, 52.", "weight_min": 0.005, "weight_max": 0.01},
	
	{"name": "Wütende Scholle", "rarity": RARITY.EXOTISCH, "base_value": 200, "icon": "res://assets/fish/scholle.png",
	 "description": "Hat valide Gründe für ihre Wut. Glaub mir.", "weight_min": 1.0, "weight_max": 3.0},
	
	{"name": "Kondom", "rarity": RARITY.EXOTISCH, "base_value": 8, "icon": "res://assets/fish/Kondom.png",
	 "description": "Gebraucht. Wirf es zurück. WIRF. ES. ZURÜCK.", "weight_min": 0.005, "weight_max": 0.02}
]

var FISH_FOREST = [
	{"name": "Karpfen", "rarity": RARITY.NORMAL, "base_value": 10, "icon": "res://assets/fish/Karpfen.png",
	 "description": "Meditiert unter Wasser. Unc ist vegatarisch.", "weight_min": 3.0, "weight_max": 10.0},
	
	{"name": "Wels", "rarity": RARITY.NORMAL, "base_value": 15, "icon": "res://assets/fish/Wels.png",
	 "description": "Der Bartwuchs ist legendär. Der Rest? Naja.", "weight_min": 5.0, "weight_max": 25.0},
	
	{"name": "Koi", "rarity": RARITY.UNGEWOEHNLICH, "base_value": 19, "icon": "res://assets/fish/fish1.png",
	 "description": "Kostet in Japan ein Vermögen. Hier? Mittwochsangebot.", "weight_min": 2.0, "weight_max": 8.0},
	
	{"name": "Rohrschatten", "rarity": RARITY.SELTEN, "base_value": 27, "icon": "res://assets/fish/fish1.png",
	 "description": "Versteckt sich zwischen Schilf. Stealth Level 100.", "weight_min": 0.5, "weight_max": 2.0},
	
	{"name": "Neonflosser", "rarity": RARITY.EPISCH, "base_value": 45, "icon": "res://assets/fish/fish1.png",
	 "description": "Elektrisierend. Wörtlich.", "weight_min": 1.0, "weight_max": 3.0},
	
	{"name": "Waldfresser", "rarity": RARITY.EPISCH, "base_value": 70, "icon": "res://assets/fish/Gutter.png",
	 "description": "Vegetarier. Frisst buchstäblich den Wald. Irgendwie ironisch.", "weight_min": 10.0, "weight_max": 30.0},
	
	{"name": "Bambushai", "rarity": RARITY.LEGENDAER, "base_value": 100, "icon": "res://assets/fish/fish1.png",
	 "description": "Ernährt sich von Bambus und innerer Ruhe.", "weight_min": 5.0, "weight_max": 15.0},
	
	{"name": "Wurzelfisch", "rarity": RARITY.EXOTISCH, "base_value": 250, "icon": "res://assets/fish/fish1.png",
	 "description": "Halb Fisch, halb Baum, komplett verstörend.", "weight_min": 20.0, "weight_max": 50.0},
	
	{"name": "Leiche", "rarity": RARITY.EXOTISCH, "base_value": 0, "icon": "res://assets/fish/corpse.png",
	 "description": "Schon wieder? Ernsthaft?", "weight_min": 60.0, "weight_max": 90.0}
]

var FISH_DESERT = [
	{"name": "Schmutzgrundel", "rarity": RARITY.NORMAL, "base_value": 15, "icon": "res://assets/fish/fish1.png",
	 "description": "Lebt im Dreck. Buchstäblich. Wie deine Ernährungsgewohnheiten.", "weight_min": 0.2, "weight_max": 0.8},
	
	{"name": "Solarfänger", "rarity": RARITY.NORMAL, "base_value": 16, "icon": "res://assets/fish/signal.png",
	 "description": "Lädt sich über Sonnenlicht auf. Tesla wäre neidisch.", "weight_min": 0.5, "weight_max": 1.5},
	
	{"name": "Rostflosser", "rarity": RARITY.UNGEWOEHNLICH, "base_value": 25, "icon": "res://assets/fish/fish1.png",
	 "description": "Braucht dringend eine Tetanus-Impfung.", "weight_min": 1.0, "weight_max": 3.0},
	
	{"name": "Sandstreifer", "rarity": RARITY.SELTEN, "base_value": 30, "icon": "res://assets/fish/fish1.png",
	 "description": "Getarnt wie ein Sandsturm. Mit Flossen.", "weight_min": 2.0, "weight_max": 6.0},
	
	{"name": "Aggresive Garnele", "rarity": RARITY.EPISCH, "base_value": 55, "icon": "res://assets/fish/fish1.png",
	 "description": "Winzig, aber verdammt wütend. Wie ein Chihuahua.", "weight_min": 0.1, "weight_max": 0.3},
	
	{"name": "Staubhai", "rarity": RARITY.EPISCH, "base_value": 80, "icon": "res://assets/fish/Boro.png",
	 "description": "Schwimmt durch Sand. Physik hat aufgegeben.", "weight_min": 10.0, "weight_max": 40.0},
	
	{"name": "Wasserfisch", "rarity": RARITY.LEGENDAER, "base_value": 120, "icon": "res://assets/fish/fish1.png",
	 "description": "Der einzige Fisch mit Wasser in der Wüste. Ein Held.", "weight_min": 1.0, "weight_max": 4.0},
	
	{"name": "Sonnenfragment", "rarity": RARITY.EXOTISCH, "base_value": 300, "icon": "res://assets/fish/fish1.png",
	 "description": "Ein Stück Sonne. Anfassen nicht empfohlen.", "weight_min": 50.0, "weight_max": 100.0},
	
	{"name": "Goldhai", "rarity": RARITY.EXOTISCH, "base_value": 500, "icon": "res://assets/fish/corpse.png",
	 "description": "Aus echtem Gold. Oder Messing. Vermutlich Messing.", "weight_min": 20.0, "weight_max": 80.0}
]

# ===========================
#  RANDOM FISH (BAIT UPGRADE)
# ===========================
func get_random_from_list(list: Array, bait_level := 1) -> Dictionary:
	var weighted_list = []
	
	for fish in list:
		var rarity = fish["rarity"]
		var base_spawn: float = RARITY_DATA[rarity]["spawn_chance"]
		var spawn: float = base_spawn * (1.0 + bait_level * 0.10)

		for i in range(int(spawn)):
			weighted_list.append(fish)
	
	var selected_fish = weighted_list.pick_random().duplicate(true)
	
	# Generiere zufälliges Gewicht
	if selected_fish.has("weight_min") and selected_fish.has("weight_max"):
		var weight = randf_range(selected_fish["weight_min"], selected_fish["weight_max"])
		selected_fish["weight"] = snappedf(weight, 0.01)  # Auf 2 Dezimalstellen runden
	else:
		selected_fish["weight"] = 1.0
	
	# Prüfe ob Fisch neu ist und speichere es im Dictionary
	selected_fish["is_new_catch"] = not Player.caught_fish_species.has(selected_fish["name"])
	
	return selected_fish

# ===========================
#  MINIGAME ADJUSTMENTS
# ===========================
func get_fish_difficulty(fish: Dictionary) -> float:
	return RARITY_DATA[fish["rarity"]]["difficulty"]

func get_marker_speed_for_fish(fish: Dictionary, base_speed: float = 350.0) -> float:
	return base_speed * get_fish_difficulty(fish)

# ===========================
#  ICON ACCESS
# ===========================
func get_fish_icon(fish: Dictionary) -> Texture2D:
	return fish.get("icon", null)
