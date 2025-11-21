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
	RARITY.NORMAL:        {"name": "Normal",       "color": Color.WHITE, "value": 1.0, "spawn_chance": 40.0, "difficulty": 1.0},
	RARITY.UNGEWOEHNLICH: {"name": "Ungewöhnlich", "color": Color(0.3,1,0.3), "value": 1.5, "spawn_chance": 30.0, "difficulty": 1.3},
	RARITY.SELTEN:        {"name": "Selten",       "color": Color(0.2,0.4,1), "value": 2.0, "spawn_chance": 15.0, "difficulty": 1.6},
	RARITY.EPISCH:        {"name": "Episch",       "color": Color(0.7,0,1), "value": 3.0, "spawn_chance": 10.0, "difficulty": 2.0},
	RARITY.LEGENDAER:     {"name": "Legendär",     "color": Color(1,0.8,0.1), "value": 6.0, "spawn_chance": 4.0, "difficulty": 2.5},
	RARITY.EXOTISCH:      {"name": "Exotisch",     "color": Color(1,0,0.2), "value": 12.0, "spawn_chance": 1.0, "difficulty": 3.0}
}
# ===========================
#  FISH LISTS BY LOCATION
# ===========================
var FISH_LAKE = [
	{"name": "Rotauge",      "rarity": RARITY.NORMAL,        "base_value": 5},
	{"name": "Barsch",       "rarity": RARITY.UNGEWOEHNLICH, "base_value": 8},
	{"name": "Hecht",        "rarity": RARITY.SELTEN,        "base_value": 15},
	{"name": "Zander",       "rarity": RARITY.EPISCH,        "base_value": 25},
	{"name": "Karpfenkönig", "rarity": RARITY.LEGENDAER,     "base_value": 40},
	{"name": "Geisterforelle","rarity": RARITY.EXOTISCH,     "base_value": 100}
]
var FISH_CITY = [
	{"name": "Schmutzgrundel",      "rarity": RARITY.NORMAL, "base_value": 6},
	{"name": "Trümmerkabel-Fisch",  "rarity": RARITY.UNGEWOEHNLICH, "base_value": 10},
	{"name": "Rohrschatten",        "rarity": RARITY.SELTEN, "base_value": 18},
	{"name": "Neonflosser",         "rarity": RARITY.EPISCH, "base_value": 30},
	{"name": "Altstadtgeist",       "rarity": RARITY.LEGENDAER, "base_value": 55},
	{"name": "Stadtmythos",         "rarity": RARITY.EXOTISCH, "base_value": 150}
]
# ===========================
#  FISH SELECTION
# ===========================
func get_random_from_list(list: Array) -> Dictionary:
	var weighted_list = []
	
	# Erstelle gewichtete Liste basierend auf Spawn-Chancen
	for fish in list:
		var rarity = fish["rarity"]
		var spawn_chance = RARITY_DATA[rarity]["spawn_chance"]
		
		# Füge den Fisch mehrmals hinzu, proportional zu seiner Chance
		for i in range(int(spawn_chance)):
			weighted_list.append(fish)
	
	return weighted_list.pick_random()

# Gibt die Schwierigkeit des Fangs zurück (für Minigame-Anpassung)
func get_fish_difficulty(fish: Dictionary) -> float:
	var rarity = fish["rarity"]
	return RARITY_DATA[rarity]["difficulty"]

# Gibt die angepasste Fanggeschwindigkeit zurück
func get_marker_speed_for_fish(fish: Dictionary, base_speed: float = 350.0) -> float:
	var difficulty = get_fish_difficulty(fish)
	return base_speed * difficulty
