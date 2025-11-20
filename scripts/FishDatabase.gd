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
	RARITY.NORMAL:        {"name": "Normal",       "color": Color.WHITE, "value": 1.0},
	RARITY.UNGEWOEHNLICH: {"name": "Ungewöhnlich", "color": Color(0.3,1,0.3), "value": 1.5},
	RARITY.SELTEN:        {"name": "Selten",       "color": Color(0.2,0.4,1), "value": 2.0},
	RARITY.EPISCH:        {"name": "Episch",       "color": Color(0.7,0,1), "value": 3.0},
	RARITY.LEGENDAER:     {"name": "Legendär",     "color": Color(1,0.8,0.1), "value": 6.0},
	RARITY.EXOTISCH:      {"name": "Exotisch",     "color": Color(1,0,0.2), "value": 12.0}
}

# ===========================
#  FISH LISTS BY LOCATION
# ===========================

# Ort 1 – Normaler See
var FISH_LAKE = [
	{"name": "Rotauge",      "rarity": RARITY.NORMAL,        "base_value": 5},
	{"name": "Barsch",       "rarity": RARITY.UNGEWOEHNLICH, "base_value": 8},
	{"name": "Hecht",        "rarity": RARITY.SELTEN,        "base_value": 15},
	{"name": "Zander",       "rarity": RARITY.EPISCH,        "base_value": 25},
	{"name": "Karpfenkönig", "rarity": RARITY.LEGENDAER,     "base_value": 40},
	{"name": "Geisterforelle","rarity": RARITY.EXOTISCH,     "base_value": 100}
]

# Ort 2 – Überflutete Stadt
var FISH_CITY = [
	{"name": "Schmutzgrundel",      "rarity": RARITY.NORMAL, "base_value": 6},
	{"name": "Trümmerkabel-Fisch",  "rarity": RARITY.UNGEWOEHNLICH, "base_value": 10},
	{"name": "Rohrschatten",        "rarity": RARITY.SELTEN, "base_value": 18},
	{"name": "Neonflosser",         "rarity": RARITY.EPISCH, "base_value": 30},
	{"name": "Altstadtgeist",       "rarity": RARITY.LEGENDAER, "base_value": 55},
	{"name": "Stadtmythos",         "rarity": RARITY.EXOTISCH, "base_value": 150}
]

# usw. für weitere Orte

# ===========================
#  FISH SELECTION
# ===========================

func get_random_from_list(list: Array) -> Dictionary:
	return list.pick_random()
