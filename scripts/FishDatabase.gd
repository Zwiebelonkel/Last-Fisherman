extends Node

enum TAG {
	PACIFIC,
	ATLANTIC,
	SPECIAL,
	INDIA
}

const TAG_NAMES := {
	TAG.PACIFIC: "Pacifik",
	TAG.ATLANTIC: "Atlantik",
	TAG.SPECIAL: "Special",
	TAG.INDIA: "India"
}

func _ready() -> void:
	_assign_origin_tags()

func _assign_origin_tags() -> void:
	_assign_tags_to_location(FISH_LAKE, "LAKE", {
		"SEETANG": TAG.PACIFIC, "MAKRELE": TAG.PACIFIC, "ROTAUGE": TAG.PACIFIC, "BARSCH": TAG.PACIFIC,
		"THUNFISCH": TAG.PACIFIC, "HECHT": TAG.PACIFIC, "EINSIEDLER": TAG.PACIFIC, "MANTA": TAG.PACIFIC,
		"ZANDER": TAG.PACIFIC, "KAUGUMIKARPFEN": TAG.PACIFIC, "GLUBSCHI": TAG.PACIFIC, "KARPFENKOENIGIN": TAG.PACIFIC,
		"GEISTERFORELLE": TAG.SPECIAL, "PLUTONIUM": TAG.SPECIAL, "ROTER_KNOPF": TAG.SPECIAL
	})
	_assign_tags_to_location(FISH_CITY, "CITY", {
		"SAND_AAL": TAG.ATLANTIC, "SIGNALFAENGER": TAG.ATLANTIC, "TRUEMMERKABEL_FISCH": TAG.ATLANTIC, "DORSCH": TAG.ATLANTIC,
		"DISKUSFISCH": TAG.ATLANTIC, "BARRAKUDA": TAG.ATLANTIC, "LOAF_FISH": TAG.ATLANTIC, "NEONFLOSSER": TAG.ATLANTIC,
		"ZIGARETTEN": TAG.SPECIAL, "ALTSTADTGEIST": TAG.SPECIAL, "BULLENHAI": TAG.ATLANTIC, "PLATZHALTER": TAG.SPECIAL,
		"LEICHE": TAG.SPECIAL, "DATENKRAKE": TAG.SPECIAL, "STOEPSEL": TAG.SPECIAL
	})
	_assign_tags_to_location(FISH_SEWER, "SEWER", {
		"KACKWURST": TAG.SPECIAL, "SARDINE": TAG.SPECIAL, "FORELLE": TAG.SPECIAL, "WELS": TAG.SPECIAL,
		"TEERFISCH": TAG.SPECIAL, "KARTOFFEL": TAG.SPECIAL, "MONDFISCH": TAG.SPECIAL, "KATZENHAI": TAG.SPECIAL,
		"FUEHRERSCHEIN": TAG.SPECIAL, "GIFT_MANTA": TAG.SPECIAL, "BILDERBUCHFISCH": TAG.SPECIAL, "WUETENDE_SCHOLLE": TAG.SPECIAL,
		"KONDOM": TAG.SPECIAL, "BAHNKARTE": TAG.SPECIAL
	})
	_assign_tags_to_location(FISH_FOREST, "FOREST", {
		"KARPFEN": TAG.INDIA, "WELS": TAG.INDIA, "KOI": TAG.INDIA, "ROHRSCHATTEN": TAG.INDIA,
		"ANGEL": TAG.INDIA, "WALDAAL": TAG.INDIA, "WALDFRESSER": TAG.INDIA, "BAMBUSHAI": TAG.INDIA,
		"ANGEPISSTE_MAKRELE": TAG.INDIA, "WURZELFISCH": TAG.INDIA, "MARKUS": TAG.SPECIAL, "HAIZAHN": TAG.SPECIAL
	})
	_assign_tags_to_location(FISH_DESERT, "DESERT", {
		"SCHMUTZGRUNDEL": TAG.INDIA, "SOLARFAENGER": TAG.INDIA, "ROSTFLOSSER": TAG.INDIA, "SANDSTREIFER": TAG.INDIA,
		"AGGRESIVE_GARNELE": TAG.INDIA, "STAUBHAI": TAG.INDIA, "WASSERFISCH": TAG.INDIA, "FEUER_MANTA": TAG.SPECIAL,
		"SONNENFRAGMENT": TAG.SPECIAL, "GOLDHAI": TAG.SPECIAL, "BENZIN": TAG.SPECIAL
	})
	_assign_tags_to_location(FISH_ICELAND, "ICELAND", {
		"POLARDORSCH": TAG.ATLANTIC, "SCHNEEKRABBE": TAG.ATLANTIC, "ZAPFENQUALLE": TAG.ATLANTIC, "FROSTBARSCH": TAG.ATLANTIC,
		"GLETSCHER_LACHS": TAG.ATLANTIC, "ARKTIS_TINTENFISCH": TAG.ATLANTIC, "EISFISCH": TAG.ATLANTIC, "PINGUIN": TAG.ATLANTIC,
		"SCHNEEFLOCKEN_ROCHEN": TAG.ATLANTIC, "KRISTALLHECHT": TAG.ATLANTIC, "ANGLERFISCH": TAG.ATLANTIC, "BLOBFISCH": TAG.ATLANTIC,
		"BLAUER_MARLIN": TAG.ATLANTIC, "SCHWARZER_MARLIN": TAG.ATLANTIC, "MEGALODON": TAG.SPECIAL, "UNKNOWN": TAG.SPECIAL
	})

func _assign_tags_to_location(fish_list: Array, location_id: String, tags_by_local_id: Dictionary) -> void:
	for fish in fish_list:
		var local_id = _to_local_id(str(fish.get("name", "UNKNOWN")))
		var full_id = "FISH_%s_%s" % [location_id, local_id]
		fish["id"] = full_id
		var tag_enum = tags_by_local_id.get(local_id, TAG.SPECIAL)
		fish["tag"] = tag_enum
		fish["origin_tag"] = get_tag_name(tag_enum)

func _to_local_id(value: String) -> String:
	var text := value.to_upper()
	var repl := {
		"Ä":"AE","Ö":"OE","Ü":"UE","ß":"SS","-":" ","/":" ",".":" ",",":" ","?":" ","!":" "
	}
	for key in repl.keys():
		text = text.replace(key, repl[key])
	var parts = text.split(" ", false)
	return "_".join(parts)

static func get_tag_name(tag_enum: int) -> String:
	return TAG_NAMES.get(tag_enum, "Special")

# ===========================
#  RARITIES
# ===========================
enum RARITY {
	NORMAL,
	UNGEWOEHNLICH,
	SELTEN,
	EPISCH,
	LEGENDAER,
	EXOTISCH,
	ANTIK
}

static var RARITY_DATA = {
	RARITY.NORMAL:        {"name": "Normal",       "color": Color.WHITE,      "value": 1.0,  "spawn_chance": 45.0, "difficulty": 1.0},
	RARITY.UNGEWOEHNLICH: {"name": "Ungewöhnlich", "color": Color(0.3,1,0.3), "value": 1.5,  "spawn_chance": 33.0, "difficulty": 1.3},
	RARITY.SELTEN:        {"name": "Selten",       "color": Color(0.2,0.4,1), "value": 2.0,  "spawn_chance": 12.0, "difficulty": 1.6},
	RARITY.EPISCH:        {"name": "Episch",       "color": Color(0.7,0,1),   "value": 3.0,  "spawn_chance": 7.0,  "difficulty": 2.0},
	RARITY.LEGENDAER:     {"name": "Legendär",     "color": Color(1,0.8,0.1), "value": 6.0,  "spawn_chance": 2.5, "difficulty": 2.5},
	RARITY.EXOTISCH:      {"name": "Exotisch",     "color": Color(1,0,0.2),   "value": 12.0, "spawn_chance": 0.5, "difficulty": 3.0},
	RARITY.ANTIK:         {"name": "Antik",        "color": Color(0.4,0.8,0.9), "value": 0.0, "spawn_chance": 0.4, "difficulty": 1.0}
}

# ===========================
#  FISH LISTS BY LOCATION
# ===========================
var FISH_LAKE = [
	{
		"name": "Seetang",
		"rarity": RARITY.NORMAL,
		"base_value": 1,
		"icon": "res://assets/fish/seetang.png",
		"description": "Technisch gesehen kein Fisch. Aber mach erstmal weiter.",
		"weight_min": 0.1,
		"weight_max": 0.3,
		"science_fact": "Seetang betreibt Fotosynthese und liefert wertvollen Sauerstoff, auch wenn er sich nicht wie ein Fisch verhält."
	},
	{
		"name": "Makrele",
		"rarity": RARITY.NORMAL,
		"base_value": 4,
		"icon": "res://assets/fish/makrele.png",
		"description": "Der Toyota Corolla unter den Fischen. Zuverlässig langweilig.",
		"weight_min": 0.3,
		"weight_max": 0.8,
		"science_fact": "Makrelen besitzen einen stromlinienförmigen Körper, der hydrodynamisch optimiert ist und energieeffizientes Schwimmen ermöglicht."
	},
	{
		"name": "Rotauge",
		"rarity": RARITY.NORMAL,
		"base_value": 5,
		"icon": "res://assets/fish/fish1.png",
		"description": "Starrt dich vorwurfsvoll an. Hat wahrscheinlich Recht damit.",
		"weight_min": 0.2,
		"weight_max": 0.6,
		"science_fact": "Rotaugen sind Schwarmfische, die visuelle Signale nutzen, um sich synchron zu bewegen – effizienter als du beim Autofahren."
	},
	{
		"name": "Barsch",
		"rarity": RARITY.UNGEWOEHNLICH,
		"base_value": 8,
		"icon": "res://assets/fish/fish2.png",
		"description": "Etwas stacheliger als deine Ex, aber weniger giftig.",
		"weight_min": 0.5,
		"weight_max": 1.5,
		"science_fact": "Barsche nutzen ihr Seitenlinienorgan, um feinste Wasserbewegungen wahrzunehmen – praktisch wie ein eingebautes Sonar."
	},
	{
		"name": "Thunfisch",
		"rarity": RARITY.UNGEWOEHNLICH,
		"base_value": 10,
		"icon": "res://assets/fish/tuna.png",
		"description": "Keine Ahnung wie der hier rein passt... Der ist viel zu fett.",
		"weight_min": 5.0,
		"weight_max": 15.0,
		"science_fact": "Thunfische gehören zu den wenigen warmblütigen Fischen, was ihnen enorme Geschwindigkeit verschafft."
	},
	{
		"name": "Hecht",
		"rarity": RARITY.SELTEN,
		"base_value": 15,
		"icon": "res://assets/fish/fish3.png",
		"description": "Sieht aus wie ein Unterwasser-Torpedo mit Zahnarztphobie.",
		"weight_min": 2.0,
		"weight_max": 6.0,
		"science_fact": "Hechte beschleunigen in Millisekunden, da ihre Muskulatur auf explosive Schnellkraft ausgelegt ist."
	},
	{
		"name": "Einsiedler",
		"rarity": RARITY.SELTEN,
		"base_value": 10,
		"icon": "res://assets/fish/hermitcrab.png",
		"description": "Der chillt einfach. Fühlst du dich nicht schlecht, dass du ihn gestört hast?",
		"weight_min": 0.185,
		"weight_max": 0.5,
		"science_fact": "Einsiedlerkrebse leben in leeren Schneckenhäusern, um ihren weichen Arsch vor Fressfeinden zu schützen, und müssen bei Wachstum in größere Häuser umziehen, wobei oft eine Symbiose mit Seeanemonen entsteht, die das Haus vergrößern, umgekehrt der Krebs die Anemone herumträgt."
	},
	{
		"name": "Manta",
		"rarity": RARITY.SELTEN,
		"base_value": 15,
		"icon": "res://assets/fish/manta.png",
		"description": "Einer von vielen. Aber er ist sehr süß.",
		"weight_min": 700.0,
		"weight_max": 1000.0,
		"science_fact": "Mantas gehören zu den größten Rochenarten und filtern winzige Planktonpartikel aus dem Wasser – sie sind quai Staubsauger auf Eleganz-Basis."
	},
	{
		"name": "Zander",
		"rarity": RARITY.EPISCH,
		"base_value": 25,
		"icon": "res://assets/fish/fish4.png",
		"description": "Der Hipster-Fisch. War schon cool, bevor es mainstream wurde.",
		"weight_min": 1.5,
		"weight_max": 4.0,
		"science_fact": "Zander sehen im Dunkeln besonders gut, da ihre Netzhaut stark lichtverstärkend aufgebaut ist."
	},
	{
		"name": "Kaugummikarpfen",
		"rarity": RARITY.EPISCH,
		"base_value": 28,
		"icon": "res://assets/fish/Kaugummi.png",
		"description": "Schmeckt nach Erdbeere und existenzieller Krise.",
		"weight_min": 3.0,
		"weight_max": 8.0,
		"science_fact": "Karpfen besitzen über 100.000 Geschmacksknospen, was sie zu wahren Gourmets des Süßwassers macht."
	},
	{
		"name": "Glubschi",
		"rarity": RARITY.EPISCH,
		"base_value": 30,
		"icon": "res://assets/fish/glubschi.png",
		"description": "Seine Augen machen 95% seines Körpergewichts aus",
		"weight_min": 0.2,
		"weight_max": 0.8,
		"science_fact": "Fische mit großen Augen sind oft an lichtarme Umgebungen angepasst, um mit maximaler Lichtaufnahme zu überleben."
	},
	{
		"name": "Karpfenkönigin",
		"rarity": RARITY.LEGENDAER,
		"base_value": 40,
		"icon": "res://assets/fish/Prinzessinor.png",
		"description": "Erwartet, dass du kniest. Und das zu Recht.",
		"weight_min": 8.0,
		"weight_max": 15.0,
		"science_fact": "Große Karpfen entwickeln komplexe soziale Hierarchien, in denen dominante Tiere bevorzugte Futterplätze erhalten."
	},
	{
		"name": "Geisterforelle",
		"rarity": RARITY.EXOTISCH,
		"base_value": 100,
		"icon": "res://assets/fish/fish6.png",
		"description": "Ist tot. Schwimmt trotzdem. Frag nicht.",
		"weight_min": 0.5,
		"weight_max": 2.0,
		"science_fact": "Forellen reagieren extrem empfindlich auf Sauerstoffgehalt im Wasser – manche Arten benötigen fast Trinkwasserqualität."
	},
	{
		"name": "Plutonium",
		"rarity": RARITY.EXOTISCH,
		"base_value": 150,
		"icon": "res://assets/fish/plutonium.png",
		"description": "Leuchtet im Dunkeln. FDA-Zulassung ausstehend. Nicht essbar",
		"weight_min": 10.0,
		"weight_max": 25.0,
		"science_fact": "Radioaktive Stoffe können Organismen zum Leuchten bringen, allerdings nicht ohne… signifikante Nebenwirkungen."
	},
	{
		"name": "Roter Knopf",
		"rarity": RARITY.ANTIK,  # 🆕 Geändert zu ANTIK
		"base_value": 0,  # Kein Verkaufswert
		"icon": "res://assets/fish/button.png",
		"description": "Ist tot. Schwimmt trotzdem. Frag nicht.",
		"weight_min": 0.5,
		"weight_max": 2.0,
		"science_fact": "Forellen reagieren extrem empfindlich auf Sauerstoffgehalt im Wasser.",
		"is_story_item": true,
		"biome": "lake",
		"story_text": "Die Geisterforelle leuchtet in deinen Händen auf. Eine alte Macht erwacht..."
	},
]

var FISH_CITY = [
	{"name": "Sand-Aal", "rarity": RARITY.NORMAL, "base_value": 6, "icon": "res://assets/fish/Aal.png",
	 "description": "Schlüpfriger als ein Politiker im Wahlkampf.", "weight_min": 0.4, "weight_max": 1.2,
	 "science_fact": "Aale können über ihre Haut Sauerstoff aufnehmen – praktisch, wenn man in Schadensbegrenzung leben muss."},
	
	{"name": "Signalfänger", "rarity": RARITY.NORMAL, "base_value": 7, "icon": "res://assets/fish/signal.png",
	 "description": "Hat besseren Empfang als dein Handy. Niemand mag den Bastard", "weight_min": 0.2, "weight_max": 0.5,
	 "science_fact": "Viele Fische besitzen Elektrorezeptoren, mit denen sie elektrische Felder wahrnehmen – sozusagen eingebaute Antennen."},
	
	{"name": "Trümmerkabel-Fisch", "rarity": RARITY.UNGEWOEHNLICH, "base_value": 10, "icon": "res://assets/fish/trümmer.png",
	 "description": "Ernährt sich von HDMI-Kabeln und zerbrochenen Träumen.", "weight_min": 1.0, "weight_max": 3.0,
	 "science_fact": "Metallverschlingende Organismen existieren wirklich – bestimmte Bakterien nutzen Metallionen wie Nährstoffe."},
	
	{"name": "Dorsch", "rarity": RARITY.UNGEWOEHNLICH, "base_value": 11, "icon": "res://assets/fish/dorsch.png",
	 "description": "Heißt auch Kabeljau. Hat eine Identitätskrise.", "weight_min": 2.0, "weight_max": 5.0,
	 "science_fact": "Dorsche verändern ihr Wanderverhalten abhängig von Wassertemperaturen – ziemlich sensibel für so einen Brocken."},
	
	{"name": "Diskusfisch", "rarity": RARITY.SELTEN, "base_value": 18, "icon": "res://assets/fish/diskus.png",
	 "description": "Flach wie deine Ausreden, aber deutlich bunter.", "weight_min": 0.3, "weight_max": 1.0,
	 "science_fact": "Diskusfische füttern ihren Nachwuchs mit einer speziellen Schleimschicht – quasi Stillen für Fische."},
	
	{"name": "Barrakuda", "rarity": RARITY.SELTEN, "base_value": 25, "icon": "res://assets/fish/baracuda.png",
	 "description": "Schwimmt schneller als du vor Verantwortung fliehst.", "weight_min": 3.0, "weight_max": 10.0,
	 "science_fact": "Barrakudas erreichen dank Muskelzusammensetzung und Körperform extreme Beschleunigung in Sekundenbruchteilen."},
	
	{"name": "Loaf-fish", "rarity": RARITY.SELTEN, "base_value": 28, "icon": "res://assets/fish/brot.png",
	 "description": "Ist halt ein Brot mit Flossen und Kiemen. Übelst sauer und schlecht gelaunt.", "weight_min": 1.0, "weight_max": 3.0,
	 "science_fact": "Ein Fleisch-Sandwich kann bis zu 15.544 Liter Wasser verbrauchen, während ein Gurken-Sandwich (aus 1 kg Gurken) nur etwa 28 Liter Wasser benötigt."},
	
	{"name": "Neonflosser", "rarity": RARITY.EPISCH, "base_value": 30, "icon": "res://assets/fish/Eel.png",
	 "description": "Sieht aus wie ein Rave im Aquarium.", "weight_min": 1.0, "weight_max": 2.5,
	 "science_fact": "Biolumineszenz bei Fischen entsteht häufig durch symbiotische Bakterien – Natur, die Party macht."},
	
	{"name": "Zigaretten", "rarity": RARITY.EPISCH, "base_value": 35, "icon": "res://assets/fish/Boro.png",
	 "description": "Marlboro Menthol. Seit 1987 im Wasser. Noch immer brennend aktuell.", "weight_min": 0.02, "weight_max": 0.05,
	 "science_fact": "Zigarettenfilter bestehen aus Zelluloseacetat – sie zersetzen sich extrem langsam und verschmutzen Gewässer über Jahrzehnte."},
	
	{"name": "Altstadtgeist", "rarity": RARITY.LEGENDAER, "base_value": 55, "icon": "res://assets/fish/ghost.png",
	 "description": "Erzählt dir Geschichten von früher. Alle langweilig.", "weight_min": 0.1, "weight_max": 0.5,
	 "science_fact": "Viele Tiefseefische nutzen transparente Gewebe, um unsichtbar zu wirken – quasi biologische Tarnkappen."},
	
	{"name": "Bullenhai", "rarity": RARITY.LEGENDAER, "base_value": 65, "icon": "res://assets/fish/bullenhai.png",
	 "description": "Sehr bulliger Hai. Ein Bullenhai eben.", "weight_min": 30.0, "weight_max": 300.0,
	 "science_fact": "Bullenhaie sind bekannt für ihre Fähigkeit, sowohl im Salzwasser als auch in Süßwasser zu leben und bis zu 3,5 Meter lang zu werden
. Sie haben eine der stärksten Beißkräfte aller Haie und werden oft als gefährlich eingestuft, wobei ihr Name von ihrem bulligen Körperbau und ihrem aggressiven Verhalten herrührt."},
	
	{"name": "Platzhalter", "rarity": RARITY.EXOTISCH, "base_value": 150, "icon": "res://assets/fish/unknown.png",
	 "description": "Existiert eigentlich nicht. Trotzdem gefangen. Paradox!", "weight_min": 0.0, "weight_max": 0.0,
	 "science_fact": "In der Biologie gibt es ‚Placeholder species‘, wenn Forscher eine Art vermuten, aber noch nicht belegt haben."},
	
	{"name": "Leiche", "rarity": RARITY.EXOTISCH, "base_value": 0, "icon": "res://assets/fish/corpse.png",
	 "description": "Markus?! Bitte nicht...", "weight_min": 60.0, "weight_max": 90.0,
	 "science_fact": "Im Wasser sinken Körper erst ab, steigen dann durch Gasbildung wieder auf – makaber, aber wissenschaftlich korrekt."},
	
	{"name": "Datenkrake", "rarity": RARITY.EXOTISCH, "base_value": 175, "icon": "res://assets/fish/krake.png",
	 "description": "Kennt deine Suchanfragen. Alle. Ja, auch die. Sicher das der Name richtig ist?", "weight_min": 10.0, "weight_max": 30.0,
	 "science_fact": "Oktopusse besitzen eines der komplexesten Nervensysteme aller Wirbellosen – acht Arme, achtmal so viel Chaos."},
	
	{
		"name": "Stöpsel",
		"rarity": RARITY.ANTIK,  # 🆕 Geändert zu ANTIK
		"base_value": 0,  # Kein Verkaufswert
		"icon": "res://assets/fish/plug.png",
		"description": "Ist tot. Schwimmt trotzdem. Frag nicht.",
		"weight_min": 0.5,
		"weight_max": 2.0,
		"science_fact": "Forellen reagieren extrem empfindlich auf Sauerstoffgehalt im Wasser.",
		"is_story_item": true,
		"biome": "city",
		"story_text": "Die Geisterforelle leuchtet in deinen Händen auf. Eine alte Macht erwacht..."
	},
]


var FISH_SEWER = [
	{"name": "Kackwurst", "rarity": RARITY.NORMAL, "base_value": 8, "icon": "res://assets/fish/kackwurst.png",
	 "description": "Exakt das, wonach es aussieht. Verkauf es schnell.", "weight_min": 0.1, "weight_max": 0.4,
	 "science_fact": "Organische Abfälle werden im Wasser von Mikroorganismen zersetzt – nicht schön, aber effizient."},
	
	{"name": "Sardine", "rarity": RARITY.NORMAL, "base_value": 9, "icon": "res://assets/fish/sardine.png",
	 "description": "Möchte intensiv in eine Dose gepresst werden.", "weight_min": 0.05, "weight_max": 0.2,
	 "science_fact": "Sardinen bilden riesige Schwärme zur Abschreckung von Räubern – Sicherheit durch Masse."},
	
	{"name": "Forelle", "rarity": RARITY.NORMAL, "base_value": 10, "icon": "res://assets/fish/forelle.png",
	 "description": "Hat schon bessere Tage gesehen. Und bessere Gewässer.", "weight_min": 0.3, "weight_max": 1.5,
	 "science_fact": "Forellen benötigen extrem sauberes, sauerstoffreiches Wasser – Abwasser ist eher… suboptimal."},
	
	{"name": "Wels", "rarity": RARITY.UNGEWOEHNLICH, "base_value": 12, "icon": "res://assets/fish/Wels.png",
	 "description": "Sieht aus wie dein Schnurrbart nach drei Wochen Quarantäne.", "weight_min": 5.0, "weight_max": 20.0,
	 "science_fact": "Welse nutzen Barteln als Tast- und Geruchsorgane, ideal für dunkle oder schlammige Gewässer."},
	
	{"name": "Teerfisch", "rarity": RARITY.SELTEN, "base_value": 20, "icon": "res://assets/fish/teerfisch.png",
	 "description": "50% Fisch, 50% Industrieabfall, 100% unverdaulich.", "weight_min": 2.0, "weight_max": 6.0,
	 "science_fact": "Viele Schadstoffe binden sich an Fettgewebe von Fischen – Bioakkumulation lässt grüßen."},
	
	{"name": "Kartoffel", "rarity": RARITY.SELTEN, "base_value": 24, "icon": "res://assets/fish/potato.png",
	 "description": "Diese Kartoffel wirkt erstaunlich glücklich", "weight_min": 0.25, "weight_max": 2.0,
	 "science_fact": "Kartoffeln sind nährstoffreiche Knollen mit viel Wasser, Stärke, Kalium, Vitamin C und B-Vitaminen, die ursprünglich aus Südamerika stammen, dort schon vor 6000 Jahren angebaut wurden und im 16. Jahrhundert nach Europa kamen."},
	
	{"name": "Mondfisch", "rarity": RARITY.EPISCH, "base_value": 36, "icon": "res://assets/fish/mond.png",
	 "description": "Hat die Form einer Vollmondnacht und den IQ eines Kieselsteins.", "weight_min": 200.0, "weight_max": 600.0,
	 "science_fact": "Mondfische sind die schwersten Knochenfische der Welt – trotz ihres… kreativen Designs."},
	
	{"name": "Katzenhai", "rarity": RARITY.EPISCH, "base_value": 40, "icon": "res://assets/fish/katzenhai.png",
	 "description": "Miaut unter Wasser. Wissenschaft kann es nicht erklären.", "weight_min": 3.0, "weight_max": 8.0,
	 "science_fact": "Katzenhaie besitzen leuchtende Muster, die sie im Dunkeln sichtbar machen – biologische Partybeleuchtung."},
	
	{"name": "Führerschein", "rarity": RARITY.LEGENDAER, "base_value": 80, "icon": "res://assets/fish/führerschein.png",
	 "description": "Abgelaufen seit 2003. Gehörte vermutlich Rainer, 52.", "weight_min": 0.005, "weight_max": 0.01,
	 "science_fact": "Plastikkarten zerfallen im Wasser extrem langsam – Mikroplastik ahoi."},
	
	{"name": "Gift-Manta", "rarity": RARITY.LEGENDAER, "base_value": 85, "icon": "res://assets/fish/mantapoison.png",
	 "description": "Man sollte diesen Manta doppelt nicht berühren!", "weight_min": 700.0, "weight_max": 1000.0,
	 "science_fact": "Es gibt tatsächlich Rochenarten mit giftigen Stacheln – eine evolutionäre Kombination aus Majestät und ‚Fass mich nicht an‘."},
	
	{"name": "Bilderbuchfisch", "rarity": RARITY.LEGENDAER, "base_value": 90, "icon": "res://assets/fish/Rainbowi.png",
	 "description": "Die einzige Hoffnung in diesem Drecksloch.", "weight_min": 1.0, "weight_max": 10.0,
	 "science_fact": "Viele Zierfische werden durch gezielte Züchtung farbintensiver – quasi Kunstwerke mit Kiemen."},
	
	{"name": "Wütende Scholle", "rarity": RARITY.EXOTISCH, "base_value": 200, "icon": "res://assets/fish/scholle.png",
	 "description": "Hat valide Gründe für ihre Wut. Glaub mir.", "weight_min": 1.0, "weight_max": 3.0,
	 "science_fact": "Schollen wandern während des Wachstums – und ihre Augen wandern gleich mit."},
	
	{"name": "Kondom", "rarity": RARITY.EXOTISCH, "base_value": 8, "icon": "res://assets/fish/Kondom.png",
	 "description": "Gebraucht. Wirf es zurück. WIRF. ES. ZURÜCK.", "weight_min": 0.005, "weight_max": 0.02,
	 "science_fact": "Latex zerfällt im Wasser sehr langsam und kann Tiere gefährlich verwickeln – bitte kein Souvenir."},
	
	{
		"name": "Bahnkarte",
		"rarity": RARITY.ANTIK,  # 🆕 Geändert zu ANTIK
		"base_value": 0,  # Kein Verkaufswert
		"icon": "res://assets/fish/ticket.png",
		"description": "Seit 37 Jahren ungültig",
		"weight_min": 0.5,
		"weight_max": 2.0,
		"science_fact": "Dieses Relikt stammt in einer Zeit, wo die Erde noch komplett war.",
		"is_story_item": true,
		"biome": "sewer",
		"story_text": "Die Geisterforelle leuchtet in deinen Händen auf. Eine alte Macht erwacht..."
	},
]


var FISH_FOREST = [
	{"name": "Karpfen", "rarity": RARITY.NORMAL, "base_value": 10, "icon": "res://assets/fish/Karpfen.png",
	 "description": "Meditiert unter Wasser. Unc ist vegatarisch.", "weight_min": 3.0, "weight_max": 10.0,
	 "science_fact": "Karpfen können Geräusche unterscheiden und sogar auf Futtergeräusche konditioniert werden."},
	
	{"name": "Wels", "rarity": RARITY.NORMAL, "base_value": 15, "icon": "res://assets/fish/Wels.png",
	 "description": "Der Bartwuchs ist legendär. Der Rest? Naja.", "weight_min": 5.0, "weight_max": 25.0,
	 "science_fact": "Welse können elektrische Felder wahrnehmen – ein Vorteil in trüben Gewässern."},
	
	{"name": "Koi", "rarity": RARITY.UNGEWOEHNLICH, "base_value": 19, "icon": "res://assets/fish/koi.png",
	 "description": "Kostet in Japan ein Vermögen. Hier? Mittwochsangebot.", "weight_min": 2.0, "weight_max": 8.0,
	 "science_fact": "Koi können über 50 Jahre alt werden – manche sogar über 200 laut historischen Aufzeichnungen."},
	
	{"name": "Rohrschatten", "rarity": RARITY.SELTEN, "base_value": 27, "icon": "res://assets/fish/rohrschatten.png",
	 "description": "Versteckt sich zwischen Schilf. Stealth Level 100.", "weight_min": 0.5, "weight_max": 2.0,
	 "science_fact": "Viele Süßwasserfische nutzen Vegetation als Tarnung, um Räubern zu entkommen – natürliche Camouflage."},
	
	{"name": "Angel", "rarity": RARITY.SELTEN, "base_value": 28, "icon": "res://assets/fish/angel.png",
	 "description": "Schöne Angel! Oder ist das vielleicht doch eine Peitsche? Du kannst sie jedenfalls NICHT verwenden (auch wenn sie verzaubert wäre).", "weight_min": 0.8, "weight_max": 2.0,
	 "science_fact": "Angelhaken wurden historisch aus Knochen, Holz oder Muschelschalen gefertigt – MacGyver wäre stolz."},
	
	{"name": "Waldaal", "rarity": RARITY.EPISCH, "base_value": 45, "icon": "res://assets/fish/waldaal.png",
	 "description": "Elektrisierend. Wörtlich.", "weight_min": 1.0, "weight_max": 3.0,
	 "science_fact": "Elektrische Aale können Stromstöße von über 600 Volt erzeugen – Naturgewalten im Mini-Format."},
	
	{"name": "Waldfresser", "rarity": RARITY.EPISCH, "base_value": 70, "icon": "res://assets/fish/Gutter.png",
	 "description": "Vegetarier. Frisst buchstäblich den Wald. Irgendwie ironisch.", "weight_min": 10.0, "weight_max": 30.0,
	 "science_fact": "Holzfresser gibt es wirklich: Manche Welse ernähren sich von Treibholz und Mikroorganismen darauf."},
	
	{"name": "Bambushai", "rarity": RARITY.LEGENDAER, "base_value": 100, "icon": "res://assets/fish/bambus.png",
	 "description": "Ernährt sich von Bambus und innerer Ruhe.", "weight_min": 5.0, "weight_max": 15.0,
	 "science_fact": "Einige Haiarten können kurze Strecken an Land zurücklegen, indem sie ihre Flossen als Stützen verwenden."},
	
	{"name": "Angepisste Makrele", "rarity": RARITY.LEGENDAER, "base_value": 120, "icon": "res://assets/fish/makrele2.png",
	 "description": "Diese Makrele ist wahrlich angepisst.", "weight_min": 5.0, "weight_max": 15.0,
	 "science_fact": "Hier gibt es nichts schlaues zu sagen. Das ist einfach nur ekelig"},
	
	{"name": "Wurzelfisch", "rarity": RARITY.EXOTISCH, "base_value": 250, "icon": "res://assets/fish/wurzelfisch.png",
	 "description": "Halb Fisch, halb Baum, komplett verstörend.", "weight_min": 20.0, "weight_max": 50.0,
	 "science_fact": "Einige Fischarten leben in symbiotischen Beziehungen mit Pflanzen – z. B. schützen Wurzeln Laichplätze."},
	
	{"name": "Markus", "rarity": RARITY.EXOTISCH, "base_value": 0, "icon": "res://assets/fish/corpse.png",
	 "description": "Schon wieder? Ernsthaft?", "weight_min": 60.0, "weight_max": 90.0,
	 "science_fact": "Verwesungsprozesse im Wasser laufen langsamer ab, da weniger Sauerstoff vorhanden ist – gruselig effizient."},
	{
		"name": "Haizahn",
		"rarity": RARITY.ANTIK,  # 🆕 Geändert zu ANTIK
		"base_value": 0,  # Kein Verkaufswert
		"icon": "res://assets/fish/zahn.png",
		"description": "Ein schönes Souvenir. Aber auch bisschen krank wenn man darüber nachdenkt.",
		"weight_min": 0.1,
		"weight_max": 0.75,
		"science_fact": "Haie haben ein sogenanntes „Revolvergebiss“ mit mehreren Zahnreihen, wodurch sie im Laufe ihres Lebens Tausende von Zähnen verlieren und durch nachwachsende ersetzen können",
		"is_story_item": true,
		"biome": "forest",
		"story_text": "Die Geisterforelle leuchtet in deinen Händen auf. Eine alte Macht erwacht..."
	},
]


var FISH_DESERT = [
	{"name": "Schmutzgrundel", "rarity": RARITY.NORMAL, "base_value": 15, "icon": "res://assets/fish/schmutzgrundel.png",
	 "description": "Lebt im Dreck. Buchstäblich. Wie deine Ernährungsgewohnheiten.", "weight_min": 0.2, "weight_max": 0.8,
	 "science_fact": "Grundeln können in extrem trübem Wasser überleben und sind wahre Anpassungsmeister."},
	
	{"name": "Solarfänger", "rarity": RARITY.NORMAL, "base_value": 16, "icon": "res://assets/fish/solarfänger.png",
	 "description": "Lädt sich über Sonnenlicht auf. Tesla wäre neidisch.", "weight_min": 0.5, "weight_max": 1.5,
	 "science_fact": "Bestimmte Meeresorganismen nutzen tatsächlich Licht für chemische Prozesse – Bio-Solarzellen der Natur."},
	
	{"name": "Rostflosser", "rarity": RARITY.UNGEWOEHNLICH, "base_value": 25, "icon": "res://assets/fish/rostflosser.png",
	 "description": "Braucht dringend eine Tetanus-Impfung.", "weight_min": 1.0, "weight_max": 3.0,
	 "science_fact": "Rost ist im Wasser weit verbreitet – Eisenbakterien erzeugen ganze rot gefärbte Zonen."},
	
	{"name": "Sandstreifer", "rarity": RARITY.SELTEN, "base_value": 30, "icon": "res://assets/fish/sandstreifer.png",
	 "description": "Getarnt wie ein Sandsturm. Mit Flossen.", "weight_min": 2.0, "weight_max": 6.0,
	 "science_fact": "Viele Wüstenfische – ja, die gibt es – leben in kurzzeitig wasserführenden Oasen oder Flussläufen."},
	
	{"name": "Aggresive Garnele", "rarity": RARITY.EPISCH, "base_value": 55, "icon": "res://assets/fish/garnele.png",
	 "description": "Winzig, aber verdammt wütend. Wie ein Chihuahua.", "weight_min": 0.1, "weight_max": 0.3,
	 "science_fact": "Knallkrebse erzeugen durch ihre Scheren Schockwellen, die Beute betäuben – kleine Wutpakete."},
	
	{"name": "Staubhai", "rarity": RARITY.EPISCH, "base_value": 80, "icon": "res://assets/fish/staubhai.png",
	 "description": "Schwimmt durch Sand. Physik hat aufgegeben.", "weight_min": 10.0, "weight_max": 40.0,
	 "science_fact": "Einige Tiere bewegen sich tatsächlich wellenförmig durch Sand – ähnlich wie Fische im Wasser."},
	
	{"name": "Wasserfisch", "rarity": RARITY.LEGENDAER, "base_value": 120, "icon": "res://assets/fish/wasserfisch.png",
	 "description": "Der einzige Fisch mit Wasser in der Wüste. Ein Held.", "weight_min": 1.0, "weight_max": 4.0,
	 "science_fact": "Wüstenseen können uralte Wasserkörper enthalten, die über Jahrtausende isoliert waren."},
	
	{"name": "Feuer-Manta", "rarity": RARITY.LEGENDAER, "base_value": 140, "icon": "res://assets/fish/mantafire.png",
	 "description": "Ein sehr sehr heißer Manta. Boah", "weight_min": 700.0, "weight_max": 1600.0,
	 "science_fact": "Temperaturresistente Meeresbewohner existieren wirklich: Einige Arten überleben nahe Vulkanquellen"},
	
	{"name": "Sonnenfragment", "rarity": RARITY.EXOTISCH, "base_value": 300, "icon": "res://assets/fish/sonne.png",
	 "description": "Ein Stück Sonne. Anfassen nicht empfohlen.", "weight_min": 50.0, "weight_max": 100.0,
	 "science_fact": "Sonnenlicht enthält Energie, die in Milliarden Jahren Fusionsprozessen entstand – heißer geht’s nicht."},
	
	{"name": "Goldhai", "rarity": RARITY.EXOTISCH, "base_value": 500, "icon": "res://assets/fish/goldhai.png",
	 "description": "Aus echtem Gold. Oder Messing. Vermutlich Messing.", "weight_min": 300.0, "weight_max": 1000.0,
	 "science_fact": "Gold kommt tatsächlich in Spuren im Meerwasser vor – nur leider nicht in Hai-Form."},
	
	{
		"name": "Benzin",
		"rarity": RARITY.ANTIK,  # 🆕 Geändert zu ANTIK
		"base_value": 0,  # Kein Verkaufswert
		"icon": "res://assets/fish/benzin.png",
		"description": "Das wird nicht lange reichen...",
		"weight_min": 1.0,
		"weight_max": 10.0,
		"science_fact": "Benzin ist ein hochentzündliches, flüchtiges Gemisch aus über 100 verschiedenen Kohlenwasserstoffen, gewonnen aus Erdöl.",
		"is_story_item": true,
		"biome": "desert",
		"story_text": "Die Geisterforelle leuchtet in deinen Händen auf. Eine alte Macht erwacht..."
	},
]

var FISH_ICELAND = [
	
	#{"name": "Polardorsch", "rarity": RARITY.NORMAL, "base_value": 20, "icon": "res://assets/fish/polardorsch.png",
	 #"description": "Ein robuster Fisch der kalten arktischen Gewässer mit silbrig-grauem Schimmer.", "weight_min": 0.2, "weight_max": 0.8,
	 #"science_fact": "Polardorsche produzieren Frostschutzproteine in ihrem Blut, die sie vor dem Erfrieren schützen."},
	#
	#{"name": "Schneekrabbe", "rarity": RARITY.NORMAL, "base_value": 23, "icon": "res://assets/fish/schneekrabbe.png",
	 #"description": "Eine große Krabbe mit weißem Panzer, der wie Schnee schimmert.", "weight_min": 0.8, "weight_max": 2.5,
	 #"science_fact": "Königskrabben können bis zu 1.800 Meter tief leben und ihre Beine haben eine Spannweite von bis zu 1,8 Metern."},
	#
	#{"name": "Zapfenqualle", "rarity": RARITY.UNGEWOEHNLICH, "base_value": 30, "icon": "res://assets/fish/zapfenqualle.png",
	 #"description": "Eine biolumineszierende Qualle, die in den dunklen Tiefen eisiger Gewässer leuchtet.", "weight_min": 0.05, "weight_max": 0.3,
	 #"science_fact": "Tiefseequallen nutzen Biolumineszenz, um Beute anzulocken oder Räuber mit plötzlichen Lichtblitzen zu verwirren."},
	#
	#{"name": "Frostbarsch", "rarity": RARITY.UNGEWOEHNLICH, "base_value": 32, "icon": "res://assets/fish/frostbarsch.png",
	 #"description": "Seine Schuppen glitzern wie frisch gefallener Schnee in der Wintersonne.", "weight_min": 0.4, "weight_max": 1.2,
	 #"science_fact": "Rotbarsche können über 75 Jahre alt werden und bringen lebende Junge zur Welt statt Eier zu legen."},
	#
	#{"name": "Gletscher-Lachs", "rarity": RARITY.UNGEWOEHNLICH, "base_value": 34, "icon": "res://assets/fish/gletscherlachs.png",
	 #"description": "Ein prächtiger Fisch mit eisblauem Fleisch, das im Dunkeln schwach leuchtet.", "weight_min": 2.0, "weight_max": 8.0,
	 #"science_fact": "Lachse können sich das magnetische Feld der Erde merken und finden so über tausende Kilometer zu ihrem Geburtsort zurück."},
	#
	#{"name": "Arktis-Tintenfisch", "rarity": RARITY.UNGEWOEHNLICH, "base_value": 35, "icon": "res://assets/fish/arktistintenfisch.png",
	 #"description": "Ein intelligenter Kopffüßer, der seine Farbe von weiß zu eisblau wechseln kann.", "weight_min": 3.0, "weight_max": 12.0,
	 #"science_fact": "Tintenfische haben drei Herzen, blaues Blut und können ihre Hautfarbe in Millisekunden ändern."},
	#
	{"name": "Eisfisch", "rarity": RARITY.SELTEN, "base_value": 40, "icon": "res://assets/fish/eisfisch.png",
	 "description": "Durchsichtiger Fisch ohne rote Blutkörperchen - fast wie aus Glas gemacht.", "weight_min": 0.15, "weight_max": 0.5,
	 "science_fact": "Antarktische Eisfische haben kein Hämoglobin im Blut und erscheinen daher fast transparent."},
	
	#{"name": "Pinguin", "rarity": RARITY.SELTEN, "base_value": 43, "icon": "res://assets/fish/pinguin.png",
	 #"description": "Eigentlich kein Fisch, aber trotzdem im Netz gelandet. Sieht verwirrt aus.", "weight_min": 2.0, "weight_max": 4.0,
	 #"science_fact": "Kaiserpinguine können bis zu 565 Meter tief tauchen und über 20 Minuten die Luft anhalten."},
	#
	#{"name": "Schneeflocken-Rochen", "rarity": RARITY.SELTEN, "base_value": 45, "icon": "res://assets/fish/schneerocken.png",
	 #"description": "Ein eleganter Rochen mit Mustern, die wie einzigartige Schneeflocken aussehen.", "weight_min": 5.0, "weight_max": 15.0,
	 #"science_fact": "Rochen haben Elektrorezeptoren unter ihrer Haut, mit denen sie elektrische Felder wahrnehmen und Beute im Sand aufspüren können."},
	#
	#{"name": "Kristallhecht", "rarity": RARITY.SELTEN, "base_value": 50, "icon": "res://assets/fish/kristallhecht.png",
	 #"description": "Ein schlanker Raubfisch mit eisigen, kristallinen Flossen.", "weight_min": 1.5, "weight_max": 4.0,
	 #"science_fact": "Hechte haben über 700 scharfe Zähne in ihrem Maul, die in mehreren Reihen angeordnet sind."},
	#
	{"name": "Anglerfisch", "rarity": RARITY.EPISCH, "base_value": 65, "icon": "res://assets/fish/angler.png",
	 "description": "Das Glühwürmchen der Tiefsee. Mit Tollwut...", "weight_min": 10.0, "weight_max": 50.0,
	 "science_fact": "Das viel kleinere Männchen findet das Weibchen, beißt sich fest und verschmilzt mit ihr zu einer Lebensgemeinschaft, wobei er seine Organe reduziert."},
	
	{"name": "Blobfisch", "rarity": RARITY.EPISCH, "base_value": 70, "icon": "res://assets/fish/blob.png",
	 "description": "Wenn Alpträume schwimmen könnten, würden sie so aussehen.", "weight_min": 200.0, "weight_max": 800.0,
	 "science_fact": "Sein berühmtes „matschiges“ Aussehen entsteht erst an der Oberfläche, da er in der Tiefsee durch den extremen Wasserdruck seine normale, fischähnliche Form behält und als gallertartige Masse über dem Meeresboden schwebt."},
	
	{"name": "Blauer Marlin", "rarity": RARITY.EPISCH, "base_value": 90, "icon": "res://assets/fish/speerfisch.png",
	 "description": "Ein Basic Fisch. Nur diese lange Nase macht ihn besonders.", "weight_min": 1.0, "weight_max": 10.0,
	 "science_fact": "Sie sind extrem schnelle Jäger der Hochsee, die ihren langen, speerähnlichen Oberkiefer (Rostrum) zum Aufspießen ihrer Beute nutzen."},
	
	{"name": "Schwarzer Marlin", "rarity": RARITY.LEGENDAER, "base_value": 500, "icon": "res://assets/fish/marlin.png",
	 "description": "Man könnte sagen, dass der Entwickler zu faul gewesen ist um ein neues Asset zu erstellen", "weight_min": 500.0, "weight_max": 700.0,
	 "science_fact": "Der schwarze Marlin gilt als der schnellste Fisch der Welt, mit dokumentierten Spitzengeschwindigkeiten von bis zu 129 km/h. Seine Fähigkeit zu schnellen Sprints verdankt er seinem torpedoförmigen Körper, der stromlinienförmig ist und beim Jagen durch das Wasser schneidet."},
	
	{"name": "Megalodon", "rarity": RARITY.EXOTISCH, "base_value": 1000, "icon": "res://assets/fish/megalodon.png",
	 "description": "Ein prähistorischer Riesenhai. Sollte eigentlich ausgestorben sein... sollte.", "weight_min": 30000.0, "weight_max": 60000.0,
	 "science_fact": "Der Megalodon lebte vor 23-3,6 Millionen Jahren und hatte eine Beißkraft von geschätzten 18 Tonnen - zehnmal stärker als ein Weißer Hai."},
	
	{
		"name": "Pinguin",
		"rarity": RARITY.ANTIK,  # 🆕 Geändert zu ANTIK
		"base_value": 0,  # Kein Verkaufswert
		"icon": "res://assets/fish/pinguin.png",
		"description": "Der arme Bursche hat seine Familie verloren.",
		"weight_min": 0.5,
		"weight_max": 2.0,
		"science_fact": "Pinguine kommunizieren durch Schreie, leben in großen Kolonien, trinken Salzwasser und nutzen ihre Bauchseite zum schnellen Gleiten über Eis.",
		"is_story_item": true,
		"biome": "iceland",
		"story_text": "Die Geisterforelle leuchtet in deinen Händen auf. Eine alte Macht erwacht..."
	},
]


# ===========================
#  RANDOM FISH (NORMAL)
# ===========================
# KORRIGIERTE VERSION
static func get_random_from_list(list: Array, bait_level := 1) -> Dictionary:
	# 1. Sammle alle verfügbaren Rarities und berechne Gewichte
	var rarity_weights: Dictionary = {}  # {RARITY: weight}
	
	for fish in list:
		var rarity: int = fish["rarity"]
		
		# Überspringe Story-Items wenn Biom abgeschlossen
		if rarity == RARITY.ANTIK:
			var biome: String = fish.get("biome", "")
			if biome != "" and Player.completed_biomes.get(biome, false):
				continue
		
		# Initialisiere Rarity wenn noch nicht vorhanden
		if not rarity_weights.has(rarity):
			rarity_weights[rarity] = 0.0
	
	# 2. Berechne Gewichte basierend auf Bait-Level
	for rarity in rarity_weights.keys():
		var base_spawn: float = RARITY_DATA[rarity]["spawn_chance"]
		var boosted_spawn: float = _calculate_rarity_boost(base_spawn, rarity, bait_level)
		rarity_weights[rarity] = boosted_spawn
	
	# Debug-Ausgabe
	print("🎣 Bait Level: ", bait_level)
	for r in rarity_weights.keys():
		print("  ", RARITY_DATA[r]["name"], ": ", rarity_weights[r], " (", 
			  snappedf(rarity_weights[r] / _sum_weights(rarity_weights) * 100.0, 0.1), "%)")
	
	# 3. Erstelle gewichtetes Array für Rarity-Auswahl
	var weighted_rarities: Array = []
	for rarity in rarity_weights.keys():
		var weight: int = int(rarity_weights[rarity])
		for i in range(weight):
			weighted_rarities.append(rarity)
	
	if weighted_rarities.is_empty():
		return _fallback_fish()
	
	# 4. Wähle zufällige Rarity
	var selected_rarity: int = weighted_rarities.pick_random()
	
	# 5. Wähle zufälligen Fisch dieser Rarity
	var fish_of_rarity: Array = []
	for fish in list:
		if fish["rarity"] == selected_rarity:
			# Überspringe Story-Items wenn Biom abgeschlossen
			if selected_rarity == RARITY.ANTIK:
				var biome: String = fish.get("biome", "")
				if biome != "" and Player.completed_biomes.get(biome, false):
					continue
			fish_of_rarity.append(fish)
	
	if fish_of_rarity.is_empty():
		return _fallback_fish()
	
	var selected: Dictionary = fish_of_rarity.pick_random().duplicate(true)
	
	# 6. Generiere Gewicht
	if selected.has("weight_min") and selected.has("weight_max"):
		var w = randf_range(selected["weight_min"], selected["weight_max"])
		selected["weight"] = snappedf(w, 0.01)
	else:
		selected["weight"] = 1.0
	
	selected["is_new_catch"] = not Player.caught_fish_species.has(selected["name"])
	
	print("✨ Gefangen: ", selected["name"], " (", RARITY_DATA[selected_rarity]["name"], ")")
	
	return selected
	
# ===========================
#  RARITY BOOST CALCULATION
# ===========================
# ===========================
#  RARITY BOOST CALCULATION
# ===========================
static func _calculate_rarity_boost(base_spawn: float, rarity: int, bait_level: int) -> float:
	# Diminishing Returns System: Je höher das Level, desto weniger Effekt
	# Formel: multiplier = 1 + (max_boost * (1 - e^(-k * level)))
	
	var max_boost: float = 0.0  # Maximaler Multiplikator bei unendlichem Level
	var growth_rate: float = 0.0  # Wie schnell der Boost wächst
	
	match rarity:
		RARITY.NORMAL:
			# Normale Fische sinken auf min. 10% ihrer Originalchance
			max_boost = -0.90  # -90% maximal (war -95%)
			growth_rate = 0.12  # Langsamer sinkend (war 0.15)
		
		RARITY.UNGEWOEHNLICH:
			max_boost = 0.40   # +40% maximal (war 0.50)
			growth_rate = 0.15  # Langsamer (war 0.20)
		
		RARITY.SELTEN:
			max_boost = 1.5    # +150% maximal (war 2.0 = 3× häufiger)
			growth_rate = 0.12  # Viel langsamer (war 0.18)
		
		RARITY.EPISCH:
			max_boost = 2.5    # +250% maximal (war 4.0 = 5× häufiger)
			growth_rate = 0.10  # Viel langsamer (war 0.15)
		
		RARITY.LEGENDAER:
			max_boost = 5.0    # +500% maximal (war 8.0 = 9× häufiger)
			growth_rate = 0.08  # Sehr langsam (war 0.12)
		
		RARITY.EXOTISCH:
			max_boost = 10.0   # +1000% maximal (war 15.0 = 16× häufiger)
			growth_rate = 0.06  # Extrem langsam (war 0.10)
		
		RARITY.ANTIK:
			max_boost = 8.0    # +800% maximal (war 12.0)
			growth_rate = 0.08  # Langsamer (war 0.12)
	
	# Exponentiell abnehmender Zuwachs (Diminishing Returns)
	var progress: float = 1.0 - exp(-growth_rate * (bait_level - 1))
	var multiplier: float = 1.0 + (max_boost * progress)
	
	# Verhindere negative Werte (mindestens 10% der Originalchance)
	multiplier = max(multiplier, 0.10)  # War 0.05
	
	return base_spawn * multiplier
# Helper: Summe aller Gewichte
static func _sum_weights(weights: Dictionary) -> float:
	var total := 0.0
	for w in weights.values():
		total += w
	return total

static func _fallback_fish() -> Dictionary:
	return {
		"name": "Unknown",
		"rarity": RARITY.NORMAL,
		"base_value": 1,
		"icon": "res://assets/fish/unknown.png",
		"weight_min": 1.0,
		"weight_max": 1.0,
		"weight": 1.0,
		"is_new_catch": true
	}

# ===========================
#  RANDOM FISH (TARGET RARITY)
# ===========================
static func get_random_fish_by_rarity(list: Array, rarity_string: String) -> Dictionary:
	var rarity_enum := rarity_string_to_enum(rarity_string)

	if rarity_enum == -1:
		return get_random_from_list(list)

	var filtered: Array = []
	for fish in list:
		if fish["rarity"] == rarity_enum:
			filtered.append(fish)

	if filtered.is_empty():
		return get_random_from_list(list)

	var selected: Dictionary = filtered.pick_random().duplicate(true)


	# Gewicht generieren
	if selected.has("weight_min") and selected.has("weight_max"):
		var w = randf_range(selected["weight_min"], selected["weight_max"])
		selected["weight"] = snappedf(w, 0.01)
	else:
		selected["weight"] = 1.0

	selected["is_new_catch"] = not Player.caught_fish_species.has(selected["name"])
	return selected


# ===========================
#  DIFFICULTY
# ===========================
static func get_fish_difficulty(fish: Dictionary) -> float:
	return RARITY_DATA[fish["rarity"]]["difficulty"]


static func get_marker_speed_for_fish(fish: Dictionary, base_speed: float = 350.0) -> float:
	return base_speed * get_fish_difficulty(fish)


# ===========================
#  ICON ACCESS
# ===========================
static func get_fish_icon(fish: Dictionary) -> String:
	return fish.get("icon", "res://assets/fish/unknown.png")


# ===========================
#  RARITY STRING → ENUM (FIXED)
# ===========================
static func rarity_string_to_enum(r: String) -> int:
	var map := {
		"Uncommon": RARITY.UNGEWOEHNLICH,
		"Rare": RARITY.SELTEN,
		"Epic": RARITY.EPISCH,
		"Legendary": RARITY.LEGENDAER,
		"Exotic": RARITY.EXOTISCH,

		# Deutsche Varianten
		"Ungewöhnlich": RARITY.UNGEWOEHNLICH,
		"Selten": RARITY.SELTEN,
		"Episch": RARITY.EPISCH,
		"Legendär": RARITY.LEGENDAER,
		"Exotisch": RARITY.EXOTISCH
	}

	return map.get(r, -1)
