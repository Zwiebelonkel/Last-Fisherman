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
	{"name": "Seetang",        "rarity": RARITY.NORMAL,        "base_value": 1,   "icon": "res://assets/fish/seetang.png"},
	{"name": "Rotauge",        "rarity": RARITY.NORMAL,        "base_value": 5,   "icon": "res://assets/fish/fish1.png"},
	{"name": "Barsch",         "rarity": RARITY.UNGEWOEHNLICH, "base_value": 8,   "icon": "res://assets/fish/fish2.png"},
	{"name": "Hecht",          "rarity": RARITY.SELTEN,        "base_value": 15,  "icon": "res://assets/fish/fish3.png"},
	{"name": "Zander",         "rarity": RARITY.EPISCH,        "base_value": 25,  "icon": "res://assets/fish/fish4.png"},
	{"name": "Kaugummikarpfen",  "rarity": RARITY.EPISCH,        "base_value": 28,  "icon": "res://assets/fish/Kaugummi.png"},
	{"name": "Karpfenkönigin",   "rarity": RARITY.LEGENDAER,     "base_value": 40,  "icon": "res://assets/fish/Prinzessinor.png"},
	{"name": "Geisterforelle", "rarity": RARITY.EXOTISCH,      "base_value": 100, "icon": "res://assets/fish/fish6.png"},
	{"name": "Plutonium",      "rarity": RARITY.EXOTISCH,      "base_value": 150, "icon": "res://assets/fish/Plutonium.png"}
]

var FISH_CITY = [
	{"name": "Sand-Aal",     "rarity": RARITY.NORMAL,        "base_value": 6,   "icon": "res://assets/fish/Aal.png"},
	{"name": "Signalfänger",       "rarity": RARITY.NORMAL,        "base_value": 7,   "icon": "res://assets/fish/signal.png"},
	{"name": "Trümmerkabel-Fisch", "rarity": RARITY.UNGEWOEHNLICH, "base_value": 10,  "icon": "res://assets/fish/fish1.png"},
	{"name": "Rohrschatten",       "rarity": RARITY.SELTEN,        "base_value": 18,  "icon": "res://assets/fish/fish1.png"},
	{"name": "Barakuda",       "rarity": RARITY.SELTEN,        "base_value": 25,  "icon": "res://assets/fish/baracuda.png"},
	{"name": "Neonflosser",        "rarity": RARITY.EPISCH,        "base_value": 30,  "icon": "res://assets/fish/Eel.png"},
	{"name": "Zigaretten",        "rarity": RARITY.EPISCH,        "base_value": 35,  "icon": "res://assets/fish/Boro.png"},
	{"name": "Altstadtgeist",      "rarity": RARITY.LEGENDAER,     "base_value": 55,  "icon": "res://assets/fish/fish1.png"},
	{"name": "Stadtmythos",        "rarity": RARITY.EXOTISCH,      "base_value": 150, "icon": "res://assets/fish/fish1.png"},
	{"name": "Leiche",             "rarity": RARITY.EXOTISCH,      "base_value": 0,   "icon": "res://assets/fish/corpse.png"}
]

var FISH_SEWER = [
	{"name": "Kackwurst",     "rarity": RARITY.NORMAL,        "base_value": 8,   "icon": "res://assets/fish/kackwurst.png"},
	{"name": "Forelle",       "rarity": RARITY.NORMAL,        "base_value": 10,   "icon": "res://assets/fish/signal.png"},
	{"name": "Trümmerkabel-Fisch", "rarity": RARITY.UNGEWOEHNLICH, "base_value": 12,  "icon": "res://assets/fish/fish1.png"},
	{"name": "Teerfisch",       "rarity": RARITY.SELTEN,        "base_value": 20,  "icon": "res://assets/fish/fish1.png"},
	{"name": "Mondfisch",        "rarity": RARITY.EPISCH,        "base_value": 36,  "icon": "res://assets/fish/fish1.png"},
	{"name": "Katzenhai",        "rarity": RARITY.EPISCH,        "base_value": 40,  "icon": "res://assets/fish/Boro.png"},
	{"name": "Führerschein",      "rarity": RARITY.LEGENDAER,     "base_value": 80,  "icon": "res://assets/fish/führerschein.png"},
	{"name": "Wütende Scholle",        "rarity": RARITY.EXOTISCH,      "base_value": 200, "icon": "res://assets/fish/fish1.png"},
	{"name": "Kondom",             "rarity": RARITY.EXOTISCH,      "base_value": 0,   "icon": "res://assets/fish/corpse.png"}
]

var FISH_FOREST = [
	{"name": "Schmutzgrundel",     "rarity": RARITY.NORMAL,        "base_value": 8,   "icon": "res://assets/fish/fish1.png"},
	{"name": "Signalfänger",       "rarity": RARITY.NORMAL,        "base_value": 10,   "icon": "res://assets/fish/signal.png"},
	{"name": "Trümmerkabel-Fisch", "rarity": RARITY.UNGEWOEHNLICH, "base_value": 12,  "icon": "res://assets/fish/fish1.png"},
	{"name": "Rohrschatten",       "rarity": RARITY.SELTEN,        "base_value": 20,  "icon": "res://assets/fish/fish1.png"},
	{"name": "Neonflosser",        "rarity": RARITY.EPISCH,        "base_value": 36,  "icon": "res://assets/fish/fish1.png"},
	{"name": "Zigaretten",        "rarity": RARITY.EPISCH,        "base_value": 40,  "icon": "res://assets/fish/Boro.png"},
	{"name": "Altstadtgeist",      "rarity": RARITY.LEGENDAER,     "base_value": 60,  "icon": "res://assets/fish/fish1.png"},
	{"name": "Stadtmythos",        "rarity": RARITY.EXOTISCH,      "base_value": 200, "icon": "res://assets/fish/fish1.png"},
	{"name": "Leiche",             "rarity": RARITY.EXOTISCH,      "base_value": 0,   "icon": "res://assets/fish/corpse.png"}
]

var FISH_DESERT = [
	{"name": "Schmutzgrundel",     "rarity": RARITY.NORMAL,        "base_value": 8,   "icon": "res://assets/fish/fish1.png"},
	{"name": "Signalfänger",       "rarity": RARITY.NORMAL,        "base_value": 10,   "icon": "res://assets/fish/signal.png"},
	{"name": "Trümmerkabel-Fisch", "rarity": RARITY.UNGEWOEHNLICH, "base_value": 12,  "icon": "res://assets/fish/fish1.png"},
	{"name": "Rohrschatten",       "rarity": RARITY.SELTEN,        "base_value": 20,  "icon": "res://assets/fish/fish1.png"},
	{"name": "Neonflosser",        "rarity": RARITY.EPISCH,        "base_value": 36,  "icon": "res://assets/fish/fish1.png"},
	{"name": "Zigaretten",        "rarity": RARITY.EPISCH,        "base_value": 40,  "icon": "res://assets/fish/Boro.png"},
	{"name": "Altstadtgeist",      "rarity": RARITY.LEGENDAER,     "base_value": 60,  "icon": "res://assets/fish/fish1.png"},
	{"name": "Stadtmythos",        "rarity": RARITY.EXOTISCH,      "base_value": 200, "icon": "res://assets/fish/fish1.png"},
	{"name": "Leiche",             "rarity": RARITY.EXOTISCH,      "base_value": 0,   "icon": "res://assets/fish/corpse.png"}
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
