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
	 "description": "Technisch gesehen kein Fisch. Aber mach erstmal weiter."},
	
	{"name": "Makrele", "rarity": RARITY.NORMAL, "base_value": 4, "icon": "res://assets/fish/fish1.png",
	 "description": "Der Toyota Corolla unter den Fischen. Zuverlässig langweilig."},
	
	{"name": "Rotauge", "rarity": RARITY.NORMAL, "base_value": 5, "icon": "res://assets/fish/fish1.png",
	 "description": "Starrt dich vorwurfsvoll an. Hat wahrscheinlich Recht damit."},
	
	{"name": "Barsch", "rarity": RARITY.UNGEWOEHNLICH, "base_value": 8, "icon": "res://assets/fish/fish2.png",
	 "description": "Etwas stacheliger als deine Ex, aber weniger giftig."},
	
	{"name": "Thunfisch", "rarity": RARITY.UNGEWOEHNLICH, "base_value": 10, "icon": "res://assets/fish/fish2.png",
	 "description": "Keine Ahnung wie der hier gelandet ist... Der ist viel zu fett."},
	
	{"name": "Hecht", "rarity": RARITY.SELTEN, "base_value": 15, "icon": "res://assets/fish/fish3.png",
	 "description": "Sieht aus wie ein Unterwasser-Torpedo mit Zahnarztphobie."},
	
	{"name": "Zander", "rarity": RARITY.EPISCH, "base_value": 25, "icon": "res://assets/fish/fish4.png",
	 "description": "Der Hipster-Fisch. War schon cool, bevor es mainstream wurde."},
	
	{"name": "Kaugummikarpfen", "rarity": RARITY.EPISCH, "base_value": 28, "icon": "res://assets/fish/Kaugummi.png",
	 "description": "Schmeckt nach Erdbeere und existenzieller Krise."},
	
	{"name": "Karpfenkönigin", "rarity": RARITY.LEGENDAER, "base_value": 40, "icon": "res://assets/fish/Prinzessinor.png",
	 "description": "Erwartet, dass du kniest. Und das zu Recht."},
	
	{"name": "Geisterforelle", "rarity": RARITY.EXOTISCH, "base_value": 100, "icon": "res://assets/fish/fish6.png",
	 "description": "Ist tot. Schwimmt trotzdem. Frag nicht."},
	
	{"name": "Plutonium", "rarity": RARITY.EXOTISCH, "base_value": 150, "icon": "res://assets/fish/Plutonium.png",
	 "description": "Leuchtet im Dunkeln. FDA-Zulassung ausstehend. Nicht essbar"}
]

var FISH_CITY = [
	{"name": "Sand-Aal", "rarity": RARITY.NORMAL, "base_value": 6, "icon": "res://assets/fish/Aal.png",
	 "description": "Schlüpfriger als ein Politiker im Wahlkampf."},
	
	{"name": "Signalfänger", "rarity": RARITY.NORMAL, "base_value": 7, "icon": "res://assets/fish/signal.png",
	 "description": "Hat besseren Empfang als dein Handy. Niemand mag den Bastard"},
	
	{"name": "Trümmerkabel-Fisch", "rarity": RARITY.UNGEWOEHNLICH, "base_value": 10, "icon": "res://assets/fish/trümmer.png",
	 "description": "Ernährt sich von HDMI-Kabeln und zerbrochenen Träumen."},
	
	{"name": "Dorsch", "rarity": RARITY.UNGEWOEHNLICH, "base_value": 11, "icon": "res://assets/fish/trümmer.png",
	 "description": "Heißt auch Kabeljau. Hat eine Identitätskrise."},
	
	{"name": "Diskusfisch", "rarity": RARITY.SELTEN, "base_value": 18, "icon": "res://assets/fish/diskus.png",
	 "description": "Flach wie deine Ausreden, aber deutlich bunter."},
	
	{"name": "Barrakuda", "rarity": RARITY.SELTEN, "base_value": 25, "icon": "res://assets/fish/baracuda.png",
	 "description": "Schwimmt schneller als du vor Verantwortung fliehst."},
	
	{"name": "Neonflosser", "rarity": RARITY.EPISCH, "base_value": 30, "icon": "res://assets/fish/Eel.png",
	 "description": "Sieht aus wie ein Rave im Aquarium."},
	
	{"name": "Zigaretten", "rarity": RARITY.EPISCH, "base_value": 35, "icon": "res://assets/fish/Boro.png",
	 "description": "Marlboro Menthol. Seit 1987 im Wasser. Noch immer brennend aktuell."},
	
	{"name": "Altstadtgeist", "rarity": RARITY.LEGENDAER, "base_value": 55, "icon": "res://assets/fish/fish1.png",
	 "description": "Erzählt dir Geschichten von früher. Alle langweilig."},
	
	{"name": "Stadtmythos", "rarity": RARITY.EXOTISCH, "base_value": 150, "icon": "res://assets/fish/fish1.png",
	 "description": "Existiert eigentlich nicht. Trotzdem gefangen. Paradox!"},
	
	{"name": "Leiche", "rarity": RARITY.EXOTISCH, "base_value": 0, "icon": "res://assets/fish/corpse.png",
	 "description": "Markus?! Bitte nicht..."},
	
	{"name": "Datenkrake", "rarity": RARITY.EXOTISCH, "base_value": 175, "icon": "res://assets/fish/corpse.png",
	 "description": "Kennt deine Suchanfragen. Alle. Ja, auch die."}
]

var FISH_SEWER = [
	{"name": "Kackwurst", "rarity": RARITY.NORMAL, "base_value": 8, "icon": "res://assets/fish/kackwurst.png",
	 "description": "Exakt das, wonach es aussieht. Verkauf es schnell."},
	
	{"name": "Forelle", "rarity": RARITY.NORMAL, "base_value": 10, "icon": "res://assets/fish/signal.png",
	 "description": "Hat schon bessere Tage gesehen. Und bessere Gewässer."},
	
	{"name": "Wels", "rarity": RARITY.UNGEWOEHNLICH, "base_value": 12, "icon": "res://assets/fish/fish1.png",
	 "description": "Sieht aus wie dein Schnurrbart nach drei Wochen Quarantäne."},
	
	{"name": "Teerfisch", "rarity": RARITY.SELTEN, "base_value": 20, "icon": "res://assets/fish/fish1.png",
	 "description": "50% Fisch, 50% Industrieabfall, 100% unverdaulich."},
	
	{"name": "Mondfisch", "rarity": RARITY.EPISCH, "base_value": 36, "icon": "res://assets/fish/fish1.png",
	 "description": "Hat die Form einer Vollmondnacht und den IQ eines Kieselsteins."},
	
	{"name": "Katzenhai", "rarity": RARITY.EPISCH, "base_value": 40, "icon": "res://assets/fish/Boro.png",
	 "description": "Miaut unter Wasser. Wissenschaft kann es nicht erklären."},
	
	{"name": "Führerschein", "rarity": RARITY.LEGENDAER, "base_value": 80, "icon": "res://assets/fish/führerschein.png",
	 "description": "Abgelaufen seit 2003. Gehörte vermutlich Rainer, 52."},
	
	{"name": "Wütende Scholle", "rarity": RARITY.EXOTISCH, "base_value": 200, "icon": "res://assets/fish/fish1.png",
	 "description": "Hat valide Gründe für ihre Wut. Glaub mir."},
	
	{"name": "Kondom", "rarity": RARITY.EXOTISCH, "base_value": 8, "icon": "res://assets/fish/corpse.png",
	 "description": "Gebraucht. Wirf es zurück. WIRF. ES. ZURÜCK."}
]

var FISH_FOREST = [
	{"name": "Karpfen", "rarity": RARITY.NORMAL, "base_value": 10, "icon": "res://assets/fish/fish1.png",
	 "description": "Meditiert unter Wasser. Unc ist vegatarisch."},
	
	{"name": "Wels", "rarity": RARITY.NORMAL, "base_value": 15, "icon": "res://assets/fish/signal.png",
	 "description": "Der Bartwuchs ist legendär. Der Rest? Naja."},
	
	{"name": "Koi", "rarity": RARITY.UNGEWOEHNLICH, "base_value": 19, "icon": "res://assets/fish/fish1.png",
	 "description": "Kostet in Japan ein Vermögen. Hier? Mittwochsangebot."},
	
	{"name": "Rohrschatten", "rarity": RARITY.SELTEN, "base_value": 27, "icon": "res://assets/fish/fish1.png",
	 "description": "Versteckt sich zwischen Schilf. Stealth Level 100."},
	
	{"name": "Neonflosser", "rarity": RARITY.EPISCH, "base_value": 45, "icon": "res://assets/fish/fish1.png",
	 "description": "Elektrisierend. Wörtlich."},
	
	{"name": "Waldfresser", "rarity": RARITY.EPISCH, "base_value": 70, "icon": "res://assets/fish/Boro.png",
	 "description": "Vegetarier. Frisst buchstäblich den Wald. Irgendwie ironisch."},
	
	{"name": "Bambushai", "rarity": RARITY.LEGENDAER, "base_value": 100, "icon": "res://assets/fish/fish1.png",
	 "description": "Ernährt sich von Bambus und innerer Ruhe."},
	
	{"name": "Wurzelfisch", "rarity": RARITY.EXOTISCH, "base_value": 250, "icon": "res://assets/fish/fish1.png",
	 "description": "Halb Fisch, halb Baum, komplett verstörend."},
	
	{"name": "Leiche", "rarity": RARITY.EXOTISCH, "base_value": 0, "icon": "res://assets/fish/corpse.png",
	 "description": "Schon wieder? Ernsthaft?"}
]

var FISH_DESERT = [
	{"name": "Schmutzgrundel", "rarity": RARITY.NORMAL, "base_value": 15, "icon": "res://assets/fish/fish1.png",
	 "description": "Lebt im Dreck. Buchstäblich. Wie deine Ernährungsgewohnheiten."},
	
	{"name": "Solarfänger", "rarity": RARITY.NORMAL, "base_value": 16, "icon": "res://assets/fish/signal.png",
	 "description": "Lädt sich über Sonnenlicht auf. Tesla wäre neidisch."},
	
	{"name": "Rostflosser", "rarity": RARITY.UNGEWOEHNLICH, "base_value": 25, "icon": "res://assets/fish/fish1.png",
	 "description": "Braucht dringend eine Tetanus-Impfung."},
	
	{"name": "Sandstreifer", "rarity": RARITY.SELTEN, "base_value": 30, "icon": "res://assets/fish/fish1.png",
	 "description": "Getarnt wie ein Sandsturm. Mit Flossen."},
	
	{"name": "Aggresive Garnele", "rarity": RARITY.EPISCH, "base_value": 55, "icon": "res://assets/fish/fish1.png",
	 "description": "Winzig, aber verdammt wütend. Wie ein Chihuahua."},
	
	{"name": "Staubhai", "rarity": RARITY.EPISCH, "base_value": 80, "icon": "res://assets/fish/Boro.png",
	 "description": "Schwimmt durch Sand. Physik hat aufgegeben."},
	
	{"name": "Wasserfisch", "rarity": RARITY.LEGENDAER, "base_value": 120, "icon": "res://assets/fish/fish1.png",
	 "description": "Der einzige Fisch mit Wasser in der Wüste. Ein Held."},
	
	{"name": "Sonnenfragment", "rarity": RARITY.EXOTISCH, "base_value": 300, "icon": "res://assets/fish/fish1.png",
	 "description": "Ein Stück Sonne. Anfassen nicht empfohlen."},
	
	{"name": "Goldhai", "rarity": RARITY.EXOTISCH, "base_value": 500, "icon": "res://assets/fish/corpse.png",
	 "description": "Aus echtem Gold. Oder Messing. Vermutlich Messing."}
]

# ===========================
#  RANDOM FISH (BAIT UPGRADE)
# ===========================
func get_random_from_list(list: Array, bait_level := 1) -> Dictionary:
	var weighted_list = []
	
	for fish in list:
		var rarity = fish["rarity"]
		var base_spawn: float = RARITY_DATA[rarity]["spawn_chance"]

		# Bait-Level → erhöht Spawns um +5% pro Level
		var spawn: float = base_spawn * (1.0 + bait_level * 0.10)

		for i in range(int(spawn)):
			weighted_list.append(fish)
	
	return weighted_list.pick_random()

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
