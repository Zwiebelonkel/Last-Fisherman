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
	EXOTISCH,
	ANTIK
}
# NORMALE CHANCEN_______________________
static var RARITY_DATA = {
	RARITY.NORMAL: {
		"name_key": "RARITY_NORMAL",
		"color": Color.WHITE,
		"value": 1.0,
		"spawn_chance": 45.0,
		"difficulty": 1.0
	},
	RARITY.UNGEWOEHNLICH: {
		"name_key": "RARITY_UNCOMMON",
		"color": Color(0.3,1,0.3),
		"value": 1.5,
		"spawn_chance": 33.0,
		"difficulty": 1.3
	},
	RARITY.SELTEN: {
		"name_key": "RARITY_RARE",
		"color": Color(0.2,0.4,1),
		"value": 2.0,
		"spawn_chance": 12.0,
		"difficulty": 1.6
	},
	RARITY.EPISCH: {
		"name_key": "RARITY_EPIC",
		"color": Color(0.7,0,1),
		"value": 3.0,
		"spawn_chance": 7.0,
		"difficulty": 2.0
	},
	RARITY.LEGENDAER: {
		"name_key": "RARITY_LEGENDARY",
		"color": Color(1,0.8,0.1),
		"value": 6.0,
		"spawn_chance": 2.5,
		"difficulty": 2.5
	},
	RARITY.EXOTISCH: {
		"name_key": "RARITY_EXOTIC",
		"color": Color(1,0,0.2),
		"value": 12.0,
		"spawn_chance": 0.5,
		"difficulty": 3.0
	},
	RARITY.ANTIK: {
		"name_key": "RARITY_ANTIQUE",
		"color": Color(0.4,0.8,0.9),
		"value": 0.0,
		"spawn_chance": 0.4,
		"difficulty": 1.0
	}
}

# DEBUG CHANCEN_______________________
#static var RARITY_DATA = {
	#RARITY.NORMAL: {
		#"name_key": "RARITY_NORMAL",
		#"color": Color.WHITE,
		#"value": 1.0,
		#"spawn_chance": 0.0,
		#"difficulty": 1.0
	#},
	#RARITY.UNGEWOEHNLICH: {
		#"name_key": "RARITY_UNCOMMON",
		#"color": Color(0.3,1,0.3),
		#"value": 1.5,
		#"spawn_chance": 0.0,
		#"difficulty": 1.3
	#},
	#RARITY.SELTEN: {
		#"name_key": "RARITY_RARE",
		#"color": Color(0.2,0.4,1),
		#"value": 2.0,
		#"spawn_chance": 0.0,
		#"difficulty": 1.6
	#},
	#RARITY.EPISCH: {
		#"name_key": "RARITY_EPIC",
		#"color": Color(0.7,0,1),
		#"value": 3.0,
		#"spawn_chance": 0.0,
		#"difficulty": 2.0
	#},
	#RARITY.LEGENDAER: {
		#"name_key": "RARITY_LEGENDARY",
		#"color": Color(1,0.8,0.1),
		#"value": 6.0,
		#"spawn_chance": 0.0,
		#"difficulty": 2.5
	#},
	#RARITY.EXOTISCH: {
		#"name_key": "RARITY_EXOTIC",
		#"color": Color(1,0,0.2),
		#"value": 12.0,
		#"spawn_chance": 0.0,
		#"difficulty": 3.0
	#},
	#RARITY.ANTIK: {
		#"name_key": "RARITY_ANTIQUE",
		#"color": Color(0.4,0.8,0.9),
		#"value": 0.0,
		#"spawn_chance": 100.0,
		#"difficulty": 1.0
	#}
#}

# ===========================
#  FISH LISTS BY LOCATION
# ===========================
var FISH_LAKE = [
	{
		"id": "SEETANG",
		"name_key": "FISH_LAKE_SEETANG_NAME",
		"description_key": "FISH_LAKE_SEETANG_DESC",
		"science_key": "FISH_LAKE_SEETANG_SCIENCE",
		"rarity": RARITY.NORMAL,
		"base_value": 1,
		"icon": "res://assets/fish/seetang.png",
		"weight_min": 0.1,
		"weight_max": 0.3
	},
	{
		"id": "MAKRELE",
		"name_key": "FISH_LAKE_MAKRELE_NAME",
		"description_key": "FISH_LAKE_MAKRELE_DESC",
		"science_key": "FISH_LAKE_MAKRELE_SCIENCE",
		"rarity": RARITY.NORMAL,
		"base_value": 4,
		"icon": "res://assets/fish/makrele.png",
		"weight_min": 0.3,
		"weight_max": 0.8
	},
	{
		"id": "ROTAUGE",
		"name_key": "FISH_LAKE_ROTAUGE_NAME",
		"description_key": "FISH_LAKE_ROTAUGE_DESC",
		"science_key": "FISH_LAKE_ROTAUGE_SCIENCE",
		"rarity": RARITY.NORMAL,
		"base_value": 5,
		"icon": "res://assets/fish/fish1.png",
		"weight_min": 0.2,
		"weight_max": 0.6
	},
	{
		"id": "BARSCH",
		"name_key": "FISH_LAKE_BARSCH_NAME",
		"description_key": "FISH_LAKE_BARSCH_DESC",
		"science_key": "FISH_LAKE_BARSCH_SCIENCE",
		"rarity": RARITY.UNGEWOEHNLICH,
		"base_value": 8,
		"icon": "res://assets/fish/fish2.png",
		"weight_min": 0.5,
		"weight_max": 1.5
	},
	{
		"id": "THUNFISCH",
		"name_key": "FISH_LAKE_THUNFISCH_NAME",
		"description_key": "FISH_LAKE_THUNFISCH_DESC",
		"science_key": "FISH_LAKE_THUNFISCH_SCIENCE",
		"rarity": RARITY.UNGEWOEHNLICH,
		"base_value": 10,
		"icon": "res://assets/fish/tuna.png",
		"weight_min": 5.0,
		"weight_max": 15.0
	},
	{
	"id": "SCHLAMMGEIST",
	"name_key": "FISH_LAKE_SCHLAMMGEIST_NAME",
	"description_key": "FISH_LAKE_SCHLAMMGEIST_DESC",
	"science_key": "FISH_LAKE_SCHLAMMGEIST_SCIENCE",
	"rarity": RARITY.UNGEWOEHNLICH,
	"base_value": 12,
	"icon": "res://assets/fish/schlammgeist.png",
	"weight_min": 0.6,
	"weight_max": 2.2
	},
	{
		"id": "HECHT",
		"name_key": "FISH_LAKE_HECHT_NAME",
		"description_key": "FISH_LAKE_HECHT_DESC",
		"science_key": "FISH_LAKE_HECHT_SCIENCE",
		"rarity": RARITY.SELTEN,
		"base_value": 15,
		"icon": "res://assets/fish/fish3.png",
		"weight_min": 2.0,
		"weight_max": 6.0
	},
	{
		"id": "EINSIEDLER",
		"name_key": "FISH_LAKE_EINSIEDLER_NAME",
		"description_key": "FISH_LAKE_EINSIEDLER_DESC",
		"science_key": "FISH_LAKE_EINSIEDLER_SCIENCE",
		"rarity": RARITY.SELTEN,
		"base_value": 10,
		"icon": "res://assets/fish/hermitcrab.png",
		"weight_min": 0.185,
		"weight_max": 0.5
	},
	{
	"id": "SPIEGELKARPFEN",
	"name_key": "FISH_LAKE_SPIEGELKARPFEN_NAME",
	"description_key": "FISH_LAKE_SPIEGELKARPFEN_DESC",
	"science_key": "FISH_LAKE_SPIEGELKARPFEN_SCIENCE",
	"rarity": RARITY.SELTEN,
	"base_value": 14,
	"icon": "res://assets/fish/spiegelkarpfen.png",
	"weight_min": 4.0,
	"weight_max": 12.0
	},
	{
	"id": "SEEPFERD",
	"name_key": "FISH_LAKE_SEEPFERD_NAME",
	"description_key": "FISH_LAKE_SEEPFERD_DESC",
	"science_key": "FISH_LAKE_SEEPFERD_SCIENCE",
	"rarity": RARITY.SELTEN,
	"base_value": 15,
	"icon": "res://assets/fish/Seepferd.png",
	"weight_min": 0.005,
	"weight_max": 0.035
	},
	{
		"id": "MANTA",
		"name_key": "FISH_LAKE_MANTA_NAME",
		"description_key": "FISH_LAKE_MANTA_DESC",
		"science_key": "FISH_LAKE_MANTA_SCIENCE",
		"rarity": RARITY.SELTEN,
		"base_value": 15,
		"icon": "res://assets/fish/manta.png",
		"weight_min": 700.0,
		"weight_max": 1000.0
	},
	{
		"id": "ZANDER",
		"name_key": "FISH_LAKE_ZANDER_NAME",
		"description_key": "FISH_LAKE_ZANDER_DESC",
		"science_key": "FISH_LAKE_ZANDER_SCIENCE",
		"rarity": RARITY.EPISCH,
		"base_value": 25,
		"icon": "res://assets/fish/fish4.png",
		"weight_min": 1.5,
		"weight_max": 4.0
	},
{
	"id": "TIEFENHUSTLER",
	"name_key": "FISH_LAKE_TIEFENHUSTLER_NAME",
	"description_key": "FISH_LAKE_TIEFENHUSTLER_DESC",
	"science_key": "FISH_LAKE_TIEFENHUSTLER_SCIENCE",
	"rarity": RARITY.EPISCH,
	"base_value": 26,
	"icon": "res://assets/fish/tiefenhustler.png",
	"weight_min": 1.2,
	"weight_max": 3.5
},
	{
		"id": "KORALLE",
		"name_key": "FISH_LAKE_KORALLE_NAME",
		"description_key": "FISH_LAKE_KORALLE_DESC",
		"science_key": "FISH_LAKE_KORALLE_SCIENCE",
		"rarity": RARITY.EPISCH,
		"base_value": 27,
		"icon": "res://assets/fish/Koralle.png",
		"weight_min": 0.2,
		"weight_max": 3.0
	},
	{
		"id": "KAUGUMMIKARPFEN",
		"name_key": "FISH_LAKE_KAUGUMMIKARPFEN_NAME",
		"description_key": "FISH_LAKE_KAUGUMMIKARPFEN_DESC",
		"science_key": "FISH_LAKE_KAUGUMMIKARPFEN_SCIENCE",
		"rarity": RARITY.EPISCH,
		"base_value": 28,
		"icon": "res://assets/fish/Kaugummi.png",
		"weight_min": 3.0,
		"weight_max": 8.0
	},
	{
		"id": "GLUBSCHI",
		"name_key": "FISH_LAKE_GLUBSCHI_NAME",
		"description_key": "FISH_LAKE_GLUBSCHI_DESC",
		"science_key": "FISH_LAKE_GLUBSCHI_SCIENCE",
		"rarity": RARITY.EPISCH,
		"base_value": 30,
		"icon": "res://assets/fish/glubschi.png",
		"weight_min": 0.2,
		"weight_max": 0.8
	},
	{
		"id": "KARPFENKOENIGIN",
		"name_key": "FISH_LAKE_KARPENKOENIGIN_NAME",
		"description_key": "FISH_LAKE_KARPENKOENIGIN_DESC",
		"science_key": "FISH_LAKE_KARPENKOENIGIN_SCIENCE",
		"rarity": RARITY.LEGENDAER,
		"base_value": 40,
		"icon": "res://assets/fish/Prinzessinor.png",
		"weight_min": 8.0,
		"weight_max": 15.0
	},
	{
		"id": "ANLEITUNG",
		"name_key": "FISH_LAKE_ANLEITUNG_NAME",
		"description_key": "FISH_LAKE_ANLEITUNG_DESC",
		"science_key": "FISH_LAKE_ANLEITUNG_SCIENCE",
		"rarity": RARITY.LEGENDAER,
		"base_value": 50,
		"icon": "res://assets/fish/Anleitung.png",
		"weight_min": 0.05,
		"weight_max": 0.5
	},
	{
		"id": "GEISTERFORELLE",
		"name_key": "FISH_LAKE_GEISTERFORELLE_NAME",
		"description_key": "FISH_LAKE_GEISTERFORELLE_DESC",
		"science_key": "FISH_LAKE_GEISTERFORELLE_SCIENCE",
		"rarity": RARITY.EXOTISCH,
		"base_value": 100,
		"icon": "res://assets/fish/fish6.png",
		"weight_min": 0.5,
		"weight_max": 2.0
	},
	{
		"id": "PLUTONIUM",
		"name_key": "FISH_LAKE_PLUTONIUM_NAME",
		"description_key": "FISH_LAKE_PLUTONIUM_DESC",
		"science_key": "FISH_LAKE_PLUTONIUM_SCIENCE",
		"rarity": RARITY.EXOTISCH,
		"base_value": 150,
		"icon": "res://assets/fish/plutonium.png",
		"weight_min": 10.0,
		"weight_max": 25.0
	},
	{
		"id": "ROTER_KNOPF",
		"name_key": "FISH_LAKE_ROTER_KNOPF_NAME",
		"description_key": "FISH_LAKE_ROTER_KNOPF_DESC",
		"science_key": "FISH_LAKE_ROTER_KNOPF_SCIENCE",
		"story_key": "FISH_LAKE_ROTER_KNOPF_STORY",
		"is_story_item": true,
		"biome": "lake",
		"rarity": RARITY.ANTIK,
		"base_value": 0,
		"icon": "res://assets/fish/button.png",
		"weight_min": 0.5,
		"weight_max": 2.0
	}
]

var FISH_CITY = [
	{
		"id": "SAND_AAL",
		"name_key": "FISH_CITY_SAND_AAL_NAME",
		"description_key": "FISH_CITY_SAND_AAL_DESC",
		"science_key": "FISH_CITY_SAND_AAL_SCIENCE",
		"rarity": RARITY.NORMAL,
		"base_value": 6,
		"icon": "res://assets/fish/Aal.png",
		"weight_min": 0.4,
		"weight_max": 1.2
	},
	{
		"id": "SIGNALFAENGER",
		"name_key": "FISH_CITY_SIGNALFAENGER_NAME",
		"description_key": "FISH_CITY_SIGNALFAENGER_DESC",
		"science_key": "FISH_CITY_SIGNALFAENGER_SCIENCE",
		"rarity": RARITY.NORMAL,
		"base_value": 7,
		"icon": "res://assets/fish/signal.png",
		"weight_min": 0.2,
		"weight_max": 0.5
	},
	{
		"id": "SEEIGEL",
		"name_key": "FISH_CITY_SEEIGEL_NAME",
		"description_key": "FISH_CITY_SEEIGEL_DESC",
		"science_key": "FISH_CITY_SEEIGEL_SCIENCE",
		"rarity": RARITY.NORMAL,
		"base_value": 9,
		"icon": "res://assets/fish/Seeigel.png",
		"weight_min": 0.050,
		"weight_max": 0.200
	},
	{
		"id": "TRUEMMERKABEL_FISCH",
		"name_key": "FISH_CITY_TRUEMMERKABEL_FISCH_NAME",
		"description_key": "FISH_CITY_TRUEMMERKABEL_FISCH_DESC",
		"science_key": "FISH_CITY_TRUEMMERKABEL_FISCH_SCIENCE",
		"rarity": RARITY.UNGEWOEHNLICH,
		"base_value": 10,
		"icon": "res://assets/fish/trümmer.png",
		"weight_min": 1.0,
		"weight_max": 3.0
	},
{
	"id": "METALLAAL",
	"name_key": "FISH_CITY_METALLAAL_NAME",
	"description_key": "FISH_CITY_METALLAAL_DESC",
	"science_key": "FISH_CITY_METALLAAL_SCIENCE",
	"rarity": RARITY.UNGEWOEHNLICH,
	"base_value": 12,
	"icon": "res://assets/fish/metallaal.png",
	"weight_min": 1.5,
	"weight_max": 4.0
},
	{
		"id": "DORSCH",
		"name_key": "FISH_CITY_DORSCH_NAME",
		"description_key": "FISH_CITY_DORSCH_DESC",
		"science_key": "FISH_CITY_DORSCH_SCIENCE",
		"rarity": RARITY.UNGEWOEHNLICH,
		"base_value": 11,
		"icon": "res://assets/fish/dorsch.png",
		"weight_min": 2.0,
		"weight_max": 5.0
	},
	{
		"id": "DISKUSFISCH",
		"name_key": "FISH_CITY_DISKUSFISCH_NAME",
		"description_key": "FISH_CITY_DISKUSFISCH_DESC",
		"science_key": "FISH_CITY_DISKUSFISCH_SCIENCE",
		"rarity": RARITY.SELTEN,
		"base_value": 18,
		"icon": "res://assets/fish/diskus.png",
		"weight_min": 0.3,
		"weight_max": 1.0
	},
{
	"id": "SCHATTENKOI",
	"name_key": "FISH_CITY_SCHATTENKOI_NAME",
	"description_key": "FISH_CITY_SCHATTENKOI_DESC",
	"science_key": "FISH_CITY_SCHATTENKOI_SCIENCE",
	"rarity": RARITY.SELTEN,
	"base_value": 22,
	"icon": "res://assets/fish/schattenkoi.png",
	"weight_min": 3.0,
	"weight_max": 9.0
},
	{
		"id": "BARRAKUDA",
		"name_key": "FISH_CITY_BARRAKUDA_NAME",
		"description_key": "FISH_CITY_BARRAKUDA_DESC",
		"science_key": "FISH_CITY_BARRAKUDA_SCIENCE",
		"rarity": RARITY.SELTEN,
		"base_value": 25,
		"icon": "res://assets/fish/baracuda.png",
		"weight_min": 3.0,
		"weight_max": 10.0
	},
	{
		"id": "LOAF_FISH",
		"name_key": "FISH_CITY_LOAF_FISH_NAME",
		"description_key": "FISH_CITY_LOAF_FISH_DESC",
		"science_key": "FISH_CITY_LOAF_FISH_SCIENCE",
		"rarity": RARITY.SELTEN,
		"base_value": 28,
		"icon": "res://assets/fish/brot.png",
		"weight_min": 1.0,
		"weight_max": 3.0
	},
	{
		"id": "WHITE_DOG",
		"name_key": "FISH_CITY_WHITE_DOG_NAME",
		"description_key": "FISH_CITY_WHITE_DOG_DESC",
		"science_key": "FISH_CITY_WHITE_DOG_SCIENCE",
		"rarity": RARITY.SELTEN,
		"base_value": 29,
		"icon": "res://assets/fish/hund.png",
		"weight_min": 5.0,
		"weight_max": 15.0
	},
	{
		"id": "NEONFLOSSER",
		"name_key": "FISH_CITY_NEONFLOSSER_NAME",
		"description_key": "FISH_CITY_NEONFLOSSER_DESC",
		"science_key": "FISH_CITY_NEONFLOSSER_SCIENCE",
		"rarity": RARITY.EPISCH,
		"base_value": 30,
		"icon": "res://assets/fish/Eel.png",
		"weight_min": 1.0,
		"weight_max": 2.5
	},
	{
		"id": "RADIOAKTIV",
		"name_key": "FISH_CITY_RADIOAKTIV_NAME",
		"description_key": "FISH_CITY_RADIOAKTIV_DESC",
		"science_key": "FISH_CITY_RADIOAKTIV_SCIENCE",
		"rarity": RARITY.EPISCH,
		"base_value": 32,
		"icon": "res://assets/fish/radioactive.png",
		"weight_min": 1.0,
		"weight_max": 200.0
	},
{
	"id": "ABFLUSSENGEL",
	"name_key": "FISH_CITY_ABFLUSSENGEL_NAME",
	"description_key": "FISH_CITY_ABFLUSSENGEL_DESC",
	"science_key": "FISH_CITY_ABFLUSSENGEL_SCIENCE",
	"rarity": RARITY.EPISCH,
	"base_value": 37,
	"icon": "res://assets/fish/abflussengel.png",
	"weight_min": 0.8,
	"weight_max": 2.5
},
	{
		"id": "ZIGARETTEN",
		"name_key": "FISH_CITY_ZIGARETTEN_NAME",
		"description_key": "FISH_CITY_ZIGARETTEN_DESC",
		"science_key": "FISH_CITY_ZIGARETTEN_SCIENCE",
		"rarity": RARITY.EPISCH,
		"base_value": 35,
		"icon": "res://assets/fish/Boro.png",
		"weight_min": 0.02,
		"weight_max": 0.05
	},
{
	"id": "SEATURTLE",
	"name_key": "FISH_CITY_SEATURTLE_NAME",
	"description_key": "FISH_CITY_SEATURTLE_DESC",
	"science_key": "FISH_CITY_SEATURTLE_SCIENCE",
	"rarity": RARITY.LEGENDAER,
	"base_value": 50,
	"icon": "res://assets/fish/schildkröte.png",
	"weight_min": 80.0,
	"weight_max": 250.0
},
	{
		"id": "ALTSTADTGEIST",
		"name_key": "FISH_CITY_ALTSTADTGEIST_NAME",
		"description_key": "FISH_CITY_ALTSTADTGEIST_DESC",
		"science_key": "FISH_CITY_ALTSTADTGEIST_SCIENCE",
		"rarity": RARITY.LEGENDAER,
		"base_value": 55,
		"icon": "res://assets/fish/ghost.png",
		"weight_min": 0.1,
		"weight_max": 0.5
	},
	{
		"id": "BULLENHAI",
		"name_key": "FISH_CITY_BULLENHAI_NAME",
		"description_key": "FISH_CITY_BULLENHAI_DESC",
		"science_key": "FISH_CITY_BULLENHAI_SCIENCE",
		"rarity": RARITY.LEGENDAER,
		"base_value": 65,
		"icon": "res://assets/fish/bullenhai.png",
		"weight_min": 30.0,
		"weight_max": 300.0
	},
	{
		"id": "PLATZHALTER",
		"name_key": "FISH_CITY_PLATZHALTER_NAME",
		"description_key": "FISH_CITY_PLATZHALTER_DESC",
		"science_key": "FISH_CITY_PLATZHALTER_SCIENCE",
		"rarity": RARITY.EXOTISCH,
		"base_value": 150,
		"icon": "res://assets/fish/unknown.png",
		"weight_min": 0.0,
		"weight_max": 0.0
	},
	{
		"id": "LEICHE",
		"name_key": "FISH_CITY_LEICHE_NAME",
		"description_key": "FISH_CITY_LEICHE_DESC",
		"science_key": "FISH_CITY_LEICHE_SCIENCE",
		"rarity": RARITY.EXOTISCH,
		"base_value": 0,
		"icon": "res://assets/fish/corpse.png",
		"weight_min": 60.0,
		"weight_max": 90.0
	},
	{
		"id": "DATENKRAKE",
		"name_key": "FISH_CITY_DATENKRAKE_NAME",
		"description_key": "FISH_CITY_DATENKRAKE_DESC",
		"science_key": "FISH_CITY_DATENKRAKE_SCIENCE",
		"rarity": RARITY.EXOTISCH,
		"base_value": 175,
		"icon": "res://assets/fish/krake.png",
		"weight_min": 10.0,
		"weight_max": 30.0
	},
	{
		"id": "STOEPSEL",
		"name_key": "FISH_CITY_STOEPSEL_NAME",
		"description_key": "FISH_CITY_STOEPSEL_DESC",
		"science_key": "FISH_CITY_STOEPSEL_SCIENCE",
		"story_key": "FISH_CITY_STOEPSEL_STORY",
		"is_story_item": true,
		"biome": "city",
		"rarity": RARITY.ANTIK,
		"base_value": 0,
		"icon": "res://assets/fish/plug.png",
		"weight_min": 0.5,
		"weight_max": 2.0
	}
]

var FISH_SEWER = [
	{
		"id": "KACKWURST",
		"name_key": "FISH_SEWER_KACKWURST_NAME",
		"description_key": "FISH_SEWER_KACKWURST_DESC",
		"science_key": "FISH_SEWER_KACKWURST_SCIENCE",
		"rarity": RARITY.NORMAL,
		"base_value": 8,
		"icon": "res://assets/fish/kackwurst.png",
		"weight_min": 0.1,
		"weight_max": 0.4
	},
	{
		"id": "SARDINE",
		"name_key": "FISH_SEWER_SARDINE_NAME",
		"description_key": "FISH_SEWER_SARDINE_DESC",
		"science_key": "FISH_SEWER_SARDINE_SCIENCE",
		"rarity": RARITY.NORMAL,
		"base_value": 9,
		"icon": "res://assets/fish/sardine.png",
		"weight_min": 0.05,
		"weight_max": 0.2
	},
	{
		"id": "FORELLE",
		"name_key": "FISH_SEWER_FORELLE_NAME",
		"description_key": "FISH_SEWER_FORELLE_DESC",
		"science_key": "FISH_SEWER_FORELLE_SCIENCE",
		"rarity": RARITY.NORMAL,
		"base_value": 10,
		"icon": "res://assets/fish/forelle.png",
		"weight_min": 0.3,
		"weight_max": 1.5
	},
	{
		"id": "WELS",
		"name_key": "FISH_SEWER_WELS_NAME",
		"description_key": "FISH_SEWER_WELS_DESC",
		"science_key": "FISH_SEWER_WELS_SCIENCE",
		"rarity": RARITY.UNGEWOEHNLICH,
		"base_value": 12,
		"icon": "res://assets/fish/Wels.png",
		"weight_min": 5.0,
		"weight_max": 20.0
	},
	{
		"id": "SEEPFERD2",
		"name_key": "FISH_SEWER_SEEPFERD2_NAME",
		"description_key": "FISH_SEWER_SEEPFERD2_DESC",
		"science_key": "FISH_SEWER_SEEPFERD2_SCIENCE",
		"rarity": RARITY.UNGEWOEHNLICH,
		"base_value": 14,
		"icon": "res://assets/fish/Seepferd2.png",
		"weight_min": 0.05,
		"weight_max": 0.12
	},
	{
	"id": "SIFFZUNGE",
	"name_key": "FISH_SEWER_SIFFZUNGE_NAME",
	"description_key": "FISH_SEWER_SIFFZUNGE_DESC",
	"science_key": "FISH_SEWER_SIFFZUNGE_SCIENCE",
	"rarity": RARITY.UNGEWOEHNLICH,
	"base_value": 15,
	"icon": "res://assets/fish/siffzunge.png",
	"weight_min": 0.3,
	"weight_max": 1.0
},
	{
		"id": "TEERFISCH",
		"name_key": "FISH_SEWER_TEERFISCH_NAME",
		"description_key": "FISH_SEWER_TEERFISCH_DESC",
		"science_key": "FISH_SEWER_TEERFISCH_SCIENCE",
		"rarity": RARITY.SELTEN,
		"base_value": 20,
		"icon": "res://assets/fish/teerfisch.png",
		"weight_min": 2.0,
		"weight_max": 6.0
	},
	{
	"id": "KLOAKENHECHT",
	"name_key": "FISH_SEWER_KLOAKENHECHT_NAME",
	"description_key": "FISH_SEWER_KLOAKENHECHT_DESC",
	"science_key": "FISH_SEWER_KLOAKENHECHT_SCIENCE",
	"rarity": RARITY.SELTEN,
	"base_value": 23,
	"icon": "res://assets/fish/kloakenhecht.png",
	"weight_min": 2.5,
	"weight_max": 7.0
},
	{
		"id": "KARTOFFEL",
		"name_key": "FISH_SEWER_KARTOFFEL_NAME",
		"description_key": "FISH_SEWER_KARTOFFEL_DESC",
		"science_key": "FISH_SEWER_KARTOFFEL_SCIENCE",
		"rarity": RARITY.SELTEN,
		"base_value": 24,
		"icon": "res://assets/fish/potato.png",
		"weight_min": 0.25,
		"weight_max": 2.0
	},
	{
		"id": "MONDFISCH",
		"name_key": "FISH_SEWER_MONDFISCH_NAME",
		"description_key": "FISH_SEWER_MONDFISCH_DESC",
		"science_key": "FISH_SEWER_MONDFISCH_SCIENCE",
		"rarity": RARITY.EPISCH,
		"base_value": 36,
		"icon": "res://assets/fish/mond.png",
		"weight_min": 200.0,
		"weight_max": 600.0
	},
	{
		"id": "KATZENHAI",
		"name_key": "FISH_SEWER_KATZENHAI_NAME",
		"description_key": "FISH_SEWER_KATZENHAI_DESC",
		"science_key": "FISH_SEWER_KATZENHAI_SCIENCE",
		"rarity": RARITY.EPISCH,
		"base_value": 40,
		"icon": "res://assets/fish/katzenhai.png",
		"weight_min": 3.0,
		"weight_max": 8.0
	},
	{
	"id": "GERUCHSFISCH",
	"name_key": "FISH_SEWER_GERUCHSFISCH_NAME",
	"description_key": "FISH_SEWER_GERUCHSFISCH_DESC",
	"science_key": "FISH_SEWER_GERUCHSFISCH_SCIENCE",
	"rarity": RARITY.EPISCH,
	"base_value": 34,
	"icon": "res://assets/fish/geruchsfisch.png",
	"weight_min": 0.6,
	"weight_max": 2.0
},
	{
		"id": "FUEHRERSCHEIN",
		"name_key": "FISH_SEWER_FUEHRERSCHEIN_NAME",
		"description_key": "FISH_SEWER_FUEHRERSCHEIN_DESC",
		"science_key": "FISH_SEWER_FUEHRERSCHEIN_SCIENCE",
		"rarity": RARITY.LEGENDAER,
		"base_value": 80,
		"icon": "res://assets/fish/führerschein.png",
		"weight_min": 0.005,
		"weight_max": 0.01
	},
	{
		"id": "GIFT_MANTA",
		"name_key": "FISH_SEWER_GIFT_MANTA_NAME",
		"description_key": "FISH_SEWER_GIFT_MANTA_DESC",
		"science_key": "FISH_SEWER_GIFT_MANTA_SCIENCE",
		"rarity": RARITY.LEGENDAER,
		"base_value": 85,
		"icon": "res://assets/fish/mantapoison.png",
		"weight_min": 700.0,
		"weight_max": 1000.0
	},
	{
		"id": "BILDERBUCHFISCH",
		"name_key": "FISH_SEWER_BILDERBUCHFISCH_NAME",
		"description_key": "FISH_SEWER_BILDERBUCHFISCH_DESC",
		"science_key": "FISH_SEWER_BILDERBUCHFISCH_SCIENCE",
		"rarity": RARITY.LEGENDAER,
		"base_value": 90,
		"icon": "res://assets/fish/Rainbowi.png",
		"weight_min": 1.0,
		"weight_max": 10.0
	},
	{
		"id": "WUETENDE_SCHOLLE",
		"name_key": "FISH_SEWER_WUETENDE_SCHOLLE_NAME",
		"description_key": "FISH_SEWER_WUETENDE_SCHOLLE_DESC",
		"science_key": "FISH_SEWER_WUETENDE_SCHOLLE_SCIENCE",
		"rarity": RARITY.EXOTISCH,
		"base_value": 200,
		"icon": "res://assets/fish/scholle.png",
		"weight_min": 1.0,
		"weight_max": 3.0
	},
	{
		"id": "KONDOM",
		"name_key": "FISH_SEWER_KONDOM_NAME",
		"description_key": "FISH_SEWER_KONDOM_DESC",
		"science_key": "FISH_SEWER_KONDOM_SCIENCE",
		"rarity": RARITY.EXOTISCH,
		"base_value": 8,
		"icon": "res://assets/fish/Kondom.png",
		"weight_min": 0.005,
		"weight_max": 0.02
	},
	{
		"id": "BAHNKARTE",
		"name_key": "FISH_SEWER_BAHNKARTE_NAME",
		"description_key": "FISH_SEWER_BAHNKARTE_DESC",
		"science_key": "FISH_SEWER_BAHNKARTE_SCIENCE",
		"story_key": "FISH_SEWER_BAHNKARTE_STORY",
		"is_story_item": true,
		"biome": "sewer",
		"rarity": RARITY.ANTIK,
		"base_value": 0,
		"icon": "res://assets/fish/ticket.png",
		"weight_min": 0.5,
		"weight_max": 2.0
	}
]

var FISH_FOREST = [
	{
		"id": "KARPFEN",
		"name_key": "FISH_FOREST_KARPFEN_NAME",
		"description_key": "FISH_FOREST_KARPFEN_DESC",
		"science_key": "FISH_FOREST_KARPFEN_SCIENCE",
		"rarity": RARITY.NORMAL,
		"base_value": 10,
		"icon": "res://assets/fish/Karpfen.png",
		"weight_min": 3.0,
		"weight_max": 10.0
	},
	{
		"id": "WELS_FOREST",
		"name_key": "FISH_FOREST_WELS_NAME",
		"description_key": "FISH_FOREST_WELS_DESC",
		"science_key": "FISH_FOREST_WELS_SCIENCE",
		"rarity": RARITY.NORMAL,
		"base_value": 15,
		"icon": "res://assets/fish/Wels.png",
		"weight_min": 5.0,
		"weight_max": 25.0
	},
	{
		"id": "KOI",
		"name_key": "FISH_FOREST_KOI_NAME",
		"description_key": "FISH_FOREST_KOI_DESC",
		"science_key": "FISH_FOREST_KOI_SCIENCE",
		"rarity": RARITY.UNGEWOEHNLICH,
		"base_value": 19,
		"icon": "res://assets/fish/koi.png",
		"weight_min": 2.0,
		"weight_max": 8.0
	},
	{
	"id": "MOOSWELS",
	"name_key": "FISH_FOREST_MOOSWELS_NAME",
	"description_key": "FISH_FOREST_MOOSWELS_DESC",
	"science_key": "FISH_FOREST_MOOSWELS_SCIENCE",
	"rarity": RARITY.UNGEWOEHNLICH,
	"base_value": 18,
	"icon": "res://assets/fish/mooswels.png",
	"weight_min": 4.0,
	"weight_max": 12.0
},
{
	"id": "CLOWNFISH",
	"name_key": "FISH_FOREST_CLOWNFISH_NAME",
	"description_key": "FISH_FOREST_CLOWNFISH_DESC",
	"science_key": "FISH_FOREST_CLOWNFISH_SCIENCE",
	"rarity": RARITY.NORMAL,
	"base_value": 20,
	"icon": "res://assets/fish/clownfisch.png",
	"weight_min": 0.2,
	"weight_max": 0.8
},
	{
		"id": "ROHRSCHATTEN",
		"name_key": "FISH_FOREST_ROHRSCHATTEN_NAME",
		"description_key": "FISH_FOREST_ROHRSCHATTEN_DESC",
		"science_key": "FISH_FOREST_ROHRSCHATTEN_SCIENCE",
		"rarity": RARITY.SELTEN,
		"base_value": 27,
		"icon": "res://assets/fish/rohrschatten.png",
		"weight_min": 0.5,
		"weight_max": 2.0
	},
	{
	"id": "NEBELBISS",
	"name_key": "FISH_FOREST_NEBELBISS_NAME",
	"description_key": "FISH_FOREST_NEBELBISS_DESC",
	"science_key": "FISH_FOREST_NEBELBISS_SCIENCE",
	"rarity": RARITY.SELTEN,
	"base_value": 30,
	"icon": "res://assets/fish/nebelbiss.png",
	"weight_min": 1.0,
	"weight_max": 3.5
},
	{
		"id": "ANGEL",
		"name_key": "FISH_FOREST_ANGEL_NAME",
		"description_key": "FISH_FOREST_ANGEL_DESC",
		"science_key": "FISH_FOREST_ANGEL_SCIENCE",
		"rarity": RARITY.SELTEN,
		"base_value": 28,
		"icon": "res://assets/fish/angel.png",
		"weight_min": 0.8,
		"weight_max": 2.0
	},
	{
		"id": "WALDAAL",
		"name_key": "FISH_FOREST_WALDAAL_NAME",
		"description_key": "FISH_FOREST_WALDAAL_DESC",
		"science_key": "FISH_FOREST_WALDAAL_SCIENCE",
		"rarity": RARITY.EPISCH,
		"base_value": 45,
		"icon": "res://assets/fish/waldaal.png",
		"weight_min": 1.0,
		"weight_max": 3.0
	},
	{
		"id": "WALDFRESSER",
		"name_key": "FISH_FOREST_WALDFRESSER_NAME",
		"description_key": "FISH_FOREST_WALDFRESSER_DESC",
		"science_key": "FISH_FOREST_WALDFRESSER_SCIENCE",
		"rarity": RARITY.EPISCH,
		"base_value": 70,
		"icon": "res://assets/fish/Gutter.png",
		"weight_min": 10.0,
		"weight_max": 30.0
	},
	{
	"id": "WURMFUERST",
	"name_key": "FISH_FOREST_WURMFUERST_NAME",
	"description_key": "FISH_FOREST_WURMFUERST_DESC",
	"science_key": "FISH_FOREST_WURMFUERST_SCIENCE",
	"rarity": RARITY.EPISCH,
	"base_value": 85,
	"icon": "res://assets/fish/wurmfuerst.png",
	"weight_min": 0.8,
	"weight_max": 2.8
},
	{
		"id": "BAMBUSHAI",
		"name_key": "FISH_FOREST_BAMBUSHAI_NAME",
		"description_key": "FISH_FOREST_BAMBUSHAI_DESC",
		"science_key": "FISH_FOREST_BAMBUSHAI_SCIENCE",
		"rarity": RARITY.LEGENDAER,
		"base_value": 100,
		"icon": "res://assets/fish/bambus.png",
		"weight_min": 5.0,
		"weight_max": 15.0
	},
	{
		"id": "ANGEPISSTE_MAKRELE",
		"name_key": "FISH_FOREST_ANGEPISSTE_MAKRELE_NAME",
		"description_key": "FISH_FOREST_ANGEPISSTE_MAKRELE_DESC",
		"science_key": "FISH_FOREST_ANGEPISSTE_MAKRELE_SCIENCE",
		"rarity": RARITY.LEGENDAER,
		"base_value": 120,
		"icon": "res://assets/fish/makrele2.png",
		"weight_min": 5.0,
		"weight_max": 15.0
	},
	{
		"id": "WURZELFISCH",
		"name_key": "FISH_FOREST_WURZELFISCH_NAME",
		"description_key": "FISH_FOREST_WURZELFISCH_DESC",
		"science_key": "FISH_FOREST_WURZELFISCH_SCIENCE",
		"rarity": RARITY.EXOTISCH,
		"base_value": 250,
		"icon": "res://assets/fish/wurzelfisch.png",
		"weight_min": 20.0,
		"weight_max": 50.0
	},
	{
		"id": "MARKUS",
		"name_key": "FISH_FOREST_MARKUS_NAME",
		"description_key": "FISH_FOREST_MARKUS_DESC",
		"science_key": "FISH_FOREST_MARKUS_SCIENCE",
		"rarity": RARITY.EXOTISCH,
		"base_value": 0,
		"icon": "res://assets/fish/corpse.png",
		"weight_min": 60.0,
		"weight_max": 90.0
	},
	{
		"id": "HAIZAHN",
		"name_key": "FISH_FOREST_HAIZAHN_NAME",
		"description_key": "FISH_FOREST_HAIZAHN_DESC",
		"science_key": "FISH_FOREST_HAIZAHN_SCIENCE",
		"story_key": "FISH_FOREST_HAIZAHN_STORY",
		"is_story_item": true,
		"biome": "forest",
		"rarity": RARITY.ANTIK,
		"base_value": 0,
		"icon": "res://assets/fish/zahn.png",
		"weight_min": 0.1,
		"weight_max": 0.75
	}
]

var FISH_DESERT = [
	{
		"id": "SCHMUTZGRUNDEL",
		"name_key": "FISH_DESERT_SCHMUTZGRUNDEL_NAME",
		"description_key": "FISH_DESERT_SCHMUTZGRUNDEL_DESC",
		"science_key": "FISH_DESERT_SCHMUTZGRUNDEL_SCIENCE",
		"rarity": RARITY.NORMAL,
		"base_value": 15,
		"icon": "res://assets/fish/schmutzgrundel.png",
		"weight_min": 0.2,
		"weight_max": 0.8
	},
	{
		"id": "SOLARFAENGER",
		"name_key": "FISH_DESERT_SOLARFAENGER_NAME",
		"description_key": "FISH_DESERT_SOLARFAENGER_DESC",
		"science_key": "FISH_DESERT_SOLARFAENGER_SCIENCE",
		"rarity": RARITY.NORMAL,
		"base_value": 16,
		"icon": "res://assets/fish/solarfänger.png",
		"weight_min": 0.5,
		"weight_max": 1.5
	},
	{
		"id": "ROSTFLOSSER",
		"name_key": "FISH_DESERT_ROSTFLOSSER_NAME",
		"description_key": "FISH_DESERT_ROSTFLOSSER_DESC",
		"science_key": "FISH_DESERT_ROSTFLOSSER_SCIENCE",
		"rarity": RARITY.UNGEWOEHNLICH,
		"base_value": 25,
		"icon": "res://assets/fish/rostflosser.png",
		"weight_min": 1.0,
		"weight_max": 3.0
	},
	{
	"id": "FLIMMERAAL",
	"name_key": "FISH_DESERT_FLIMMERAAL_NAME",
	"description_key": "FISH_DESERT_FLIMMERAAL_DESC",
	"science_key": "FISH_DESERT_FLIMMERAAL_SCIENCE",
	"rarity": RARITY.UNGEWOEHNLICH,
	"base_value": 27,
	"icon": "res://assets/fish/flimmeraal.png",
	"weight_min": 1.0,
	"weight_max": 3.0
},
{
	"id": "BETTA",
	"name_key": "FISH_DESERT_BETTA_NAME",
	"description_key": "FISH_DESERT_BETTA_DESC",
	"science_key": "FISH_DESERT_BETTA_SCIENCE",
	"rarity": RARITY.UNGEWOEHNLICH,
	"base_value": 29,
	"icon": "res://assets/fish/kampffisch.png",
	"weight_min": 0.1,
	"weight_max": 0.4
},
	{
		"id": "SANDSTREIFER",
		"name_key": "FISH_DESERT_SANDSTREIFER_NAME",
		"description_key": "FISH_DESERT_SANDSTREIFER_DESC",
		"science_key": "FISH_DESERT_SANDSTREIFER_SCIENCE",
		"rarity": RARITY.SELTEN,
		"base_value": 30,
		"icon": "res://assets/fish/sandstreifer.png",
		"weight_min": 2.0,
		"weight_max": 6.0
	},
	{
	"id": "SALZFRESSER",
	"name_key": "FISH_DESERT_SALZFRESSER_NAME",
	"description_key": "FISH_DESERT_SALZFRESSER_DESC",
	"science_key": "FISH_DESERT_SALZFRESSER_SCIENCE",
	"rarity": RARITY.SELTEN,
	"base_value": 33,
	"icon": "res://assets/fish/salzfresser.png",
	"weight_min": 2.0,
	"weight_max": 6.0
},
	{
		"id": "STEINSCHNECKE",
		"name_key": "FISH_DESERT_STEINSCHNECKE_NAME",
		"description_key": "FISH_DESERT_STEINSCHNECKE_DESC",
		"science_key": "FISH_DESERT_STEINSCHNECKE_SCIENCE",
		"rarity": RARITY.SELTEN,
		"base_value": 35,
		"icon": "res://assets/fish/stoneSlug.png",
		"weight_min": 500.0,
		"weight_max": 3000.0
	},
	{
		"id": "AGGRESIVE_GARNELE",
		"name_key": "FISH_DESERT_AGGRESIVE_GARNELE_NAME",
		"description_key": "FISH_DESERT_AGGRESIVE_GARNELE_DESC",
		"science_key": "FISH_DESERT_AGGRESIVE_GARNELE_SCIENCE",
		"rarity": RARITY.EPISCH,
		"base_value": 55,
		"icon": "res://assets/fish/garnele.png",
		"weight_min": 0.1,
		"weight_max": 0.3
	},
	{
		"id": "STAUBHAI",
		"name_key": "FISH_DESERT_STAUBHAI_NAME",
		"description_key": "FISH_DESERT_STAUBHAI_DESC",
		"science_key": "FISH_DESERT_STAUBHAI_SCIENCE",
		"rarity": RARITY.EPISCH,
		"base_value": 80,
		"icon": "res://assets/fish/staubhai.png",
		"weight_min": 10.0,
		"weight_max": 40.0
	},
	{
	"id": "DUENENHAI",
	"name_key": "FISH_DESERT_DUENENHAI_NAME",
	"description_key": "FISH_DESERT_DUENENHAI_DESC",
	"science_key": "FISH_DESERT_DUENENHAI_SCIENCE",
	"rarity": RARITY.EPISCH,
	"base_value": 90,
	"icon": "res://assets/fish/duenenhai.png",
	"weight_min": 8.0,
	"weight_max": 25.0
},
	{
		"id": "WASSERFISCH",
		"name_key": "FISH_DESERT_WASSERFISCH_NAME",
		"description_key": "FISH_DESERT_WASSERFISCH_DESC",
		"science_key": "FISH_DESERT_WASSERFISCH_SCIENCE",
		"rarity": RARITY.LEGENDAER,
		"base_value": 120,
		"icon": "res://assets/fish/wasserfisch.png",
		"weight_min": 1.0,
		"weight_max": 4.0
	},
	{
		"id": "FEUER_MANTA",
		"name_key": "FISH_DESERT_FEUER_MANTA_NAME",
		"description_key": "FISH_DESERT_FEUER_MANTA_DESC",
		"science_key": "FISH_DESERT_FEUER_MANTA_SCIENCE",
		"rarity": RARITY.LEGENDAER,
		"base_value": 140,
		"icon": "res://assets/fish/mantafire.png",
		"weight_min": 700.0,
		"weight_max": 1600.0
	},
{
	"id": "PAN",
	"name_key": "FISH_DESERT_PAN_NAME",
	"description_key": "FISH_DESERT_PAN_DESC",
	"science_key": "FISH_DESERT_PAN_SCIENCE",
	"rarity": RARITY.LEGENDAER,
	"base_value": 150,
	"icon": "res://assets/fish/pfanne.png",
	"weight_min": 2.0,
	"weight_max": 6.0
},
	{
		"id": "SONNENFRAGMENT",
		"name_key": "FISH_DESERT_SONNENFRAGMENT_NAME",
		"description_key": "FISH_DESERT_SONNENFRAGMENT_DESC",
		"science_key": "FISH_DESERT_SONNENFRAGMENT_SCIENCE",
		"rarity": RARITY.EXOTISCH,
		"base_value": 300,
		"icon": "res://assets/fish/sonne.png",
		"weight_min": 50.0,
		"weight_max": 100.0
	},
	{
		"id": "GOLDHAI",
		"name_key": "FISH_DESERT_GOLDHAI_NAME",
		"description_key": "FISH_DESERT_GOLDHAI_DESC",
		"science_key": "FISH_DESERT_GOLDHAI_SCIENCE",
		"rarity": RARITY.EXOTISCH,
		"base_value": 500,
		"icon": "res://assets/fish/goldhai.png",
		"weight_min": 300.0,
		"weight_max": 1000.0
	},
	{
		"id": "BENZIN",
		"name_key": "FISH_DESERT_BENZIN_NAME",
		"description_key": "FISH_DESERT_BENZIN_DESC",
		"science_key": "FISH_DESERT_BENZIN_SCIENCE",
		"story_key": "FISH_DESERT_BENZIN_STORY",
		"is_story_item": true,
		"biome": "desert",
		"rarity": RARITY.ANTIK,
		"base_value": 0,
		"icon": "res://assets/fish/benzin.png",
		"weight_min": 1.0,
		"weight_max": 10.0
	}
]

# ✅ ICELAND - Originale Fische (bleibt wie im Original)
var FISH_ICELAND = [
	{
		"id": "EISFISCH",
		"name_key": "FISH_ICELAND_EISFISCH_NAME",
		"description_key": "FISH_ICELAND_EISFISCH_DESC",
		"science_key": "FISH_ICELAND_EISFISCH_SCIENCE",
		"rarity": RARITY.SELTEN,
		"base_value": 40,
		"icon": "res://assets/fish/eisfisch.png",
		"weight_min": 0.15,
		"weight_max": 0.5
	},
	{
	"id": "FROSTMAUL",
	"name_key": "FISH_ICELAND_FROSTMAUL_NAME",
	"description_key": "FISH_ICELAND_FROSTMAUL_DESC",
	"science_key": "FISH_ICELAND_FROSTMAUL_SCIENCE",
	"rarity": RARITY.SELTEN,
	"base_value": 45,
	"icon": "res://assets/fish/frostmaul.png",
	"weight_min": 5.0,
	"weight_max": 15.0
},
	{
		"id": "ANGLERFISCH",
		"name_key": "FISH_ICELAND_ANGLERFISCH_NAME",
		"description_key": "FISH_ICELAND_ANGLERFISCH_DESC",
		"science_key": "FISH_ICELAND_ANGLERFISCH_SCIENCE",
		"rarity": RARITY.EPISCH,
		"base_value": 65,
		"icon": "res://assets/fish/angler.png",
		"weight_min": 10.0,
		"weight_max": 50.0
	},
	{
		"id": "BLOBFISCH",
		"name_key": "FISH_ICELAND_BLOBFISCH_NAME",
		"description_key": "FISH_ICELAND_BLOBFISCH_DESC",
		"science_key": "FISH_ICELAND_BLOBFISCH_SCIENCE",
		"rarity": RARITY.EPISCH,
		"base_value": 70,
		"icon": "res://assets/fish/blob.png",
		"weight_min": 200.0,
		"weight_max": 800.0
	},
	{
	"id": "EISLICHT",
	"name_key": "FISH_ICELAND_EISLICHT_NAME",
	"description_key": "FISH_ICELAND_EISLICHT_DESC",
	"science_key": "FISH_ICELAND_EISLICHT_SCIENCE",
	"rarity": RARITY.EPISCH,
	"base_value": 76,
	"icon": "res://assets/fish/eislicht.png",
	"weight_min": 0.5,
	"weight_max": 1.8
},
	{
		"id": "BLAUER_MARLIN",
		"name_key": "FISH_ICELAND_BLAUER_MARLIN_NAME",
		"description_key": "FISH_ICELAND_BLAUER_MARLIN_DESC",
		"science_key": "FISH_ICELAND_BLAUER_MARLIN_SCIENCE",
		"rarity": RARITY.EPISCH,
		"base_value": 90,
		"icon": "res://assets/fish/speerfisch.png",
		"weight_min": 1.0,
		"weight_max": 10.0
	},
	{
		"id": "KRISTALL_FISCH",
		"name_key": "FISH_ICELAND_KRISTALL_FISCH_NAME",
		"description_key": "FISH_ICELAND_KRISTALL_FISCH_DESC",
		"science_key": "FISH_ICELAND_KRISTALL_FISCH_SCIENCE",
		"rarity": RARITY.LEGENDAER,
		"base_value": 550,
		"icon": "res://assets/fish/cristal.png",
		"weight_min": 0.5,
		"weight_max": 1.2
	},
	{
	"id": "GLETSCHERZUNGE",
	"name_key": "FISH_ICELAND_GLETSCHERZUNGE_NAME",
	"description_key": "FISH_ICELAND_GLETSCHERZUNGE_DESC",
	"science_key": "FISH_ICELAND_GLETSCHERZUNGE_SCIENCE",
	"rarity": RARITY.LEGENDAER,
	"base_value": 490,
	"icon": "res://assets/fish/gletscherzunge.png",
	"weight_min": 20.0,
	"weight_max": 60.0
},
	{
		"id": "SCHWARZER_MARLIN",
		"name_key": "FISH_ICELAND_SCHWARZER_MARLIN_NAME",
		"description_key": "FISH_ICELAND_SCHWARZER_MARLIN_DESC",
		"science_key": "FISH_ICELAND_SCHWARZER_MARLIN_SCIENCE",
		"rarity": RARITY.LEGENDAER,
		"base_value": 500,
		"icon": "res://assets/fish/marlin.png",
		"weight_min": 500.0,
		"weight_max": 700.0
	},
	{
		"id": "MEGALODON",
		"name_key": "FISH_ICELAND_MEGALODON_NAME",
		"description_key": "FISH_ICELAND_MEGALODON_DESC",
		"science_key": "FISH_ICELAND_MEGALODON_SCIENCE",
		"rarity": RARITY.EXOTISCH,
		"base_value": 1000,
		"icon": "res://assets/fish/megalodon.png",
		"weight_min": 30000.0,
		"weight_max": 60000.0
	},
	{
		"id": "PINGUIN",
		"name_key": "FISH_ICELAND_PINGUIN_NAME",
		"description_key": "FISH_ICELAND_PINGUIN_DESC",
		"science_key": "FISH_ICELAND_PINGUIN_SCIENCE",
		"story_key": "FISH_ICELAND_PINGUIN_STORY",
		"is_story_item": true,
		"biome": "iceland",
		"rarity": RARITY.ANTIK,
		"base_value": 0,
		"icon": "res://assets/fish/pinguin.png",
		"weight_min": 0.5,
		"weight_max": 2.0
	}
]

# 🆕 OCEAN - NUR STEAM SPIELER (Komplett neue Map)
var FISH_OCEAN = [
	{
		"id": "STEAM_PLAYER",
		"name_key": "FISH_OCEAN_STEAM_PLAYER_NAME",
		"description_key": "FISH_OCEAN_STEAM_PLAYER_DESC",
		"science_key": "FISH_OCEAN_STEAM_PLAYER_SCIENCE",
		"story_key": "FISH_OCEAN_STEAM_PLAYER_STORY",
		"is_story_item": true,
		"is_steam_player": true,
		"biome": "ocean",
		"rarity": RARITY.ANTIK,
		"base_value": 0,
		"icon": "",  # Wird dynamisch vom Steam Avatar überschrieben
		"weight_min": 70.0,
		"weight_max": 90.0
	}
]

# ===========================
#  RANDOM FISH (NORMAL)
# ===========================
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
	
	# 🆕 STEAM PLAYER INTEGRATION
	if selected.get("is_steam_player", false):
		_apply_steam_data_to_fish(selected)
	
	# 6. Generiere Gewicht
	if selected.has("weight_min") and selected.has("weight_max"):
		var w = randf_range(selected["weight_min"], selected["weight_max"])
		selected["weight"] = snappedf(w, 0.01)
	else:
		selected["weight"] = 1.0
	
	selected["is_new_catch"] = not Player.caught_fish_species.has(selected["id"]) 
	
	return selected

# ===========================
# 🆕 STEAM INTEGRATION
# ===========================
static func _apply_steam_data_to_fish(fish: Dictionary) -> void:
	"""Lädt Steam-Nutzername und Avatar und überschreibt Fisch-Daten"""
	
	# Prüfe ob Steam verfügbar ist
	if not Engine.has_singleton("Steam"):
		print("⚠️ Steam nicht verfügbar - verwende Fallback")
		fish["name_key"] = ""
		fish["steam_name"] = "Mysterious Angler"
		return
	
	# Prüfe ob Steam initialisiert ist
	if not Steam.isSteamRunning():
		print("⚠️ Steam läuft nicht - verwende Fallback")
		fish["name_key"] = ""
		fish["steam_name"] = "Mysterious Angler"
		return
	
	# Steam Name laden
	var steam_name := Steam.getPersonaName()
	if steam_name == "":
		steam_name = "Unknown Player"
	
	print("🎣 Steam-Spieler gefangen:", steam_name)
	
	# Überschreibe den Namen direkt (kein Translation Key)
	fish["steam_name"] = steam_name
	fish["name_key"] = ""  # Deaktiviere Translation
	
	# Steam ID holen
	var steam_id: int = Steam.getSteamID()
	
	# Avatar laden (Large = 184x184)
	var avatar_handle: int = Steam.getLargeFriendAvatar(steam_id)
	
	if avatar_handle > 0:
		var avatar_size: Dictionary = Steam.getImageSize(avatar_handle)
		
		if avatar_size.has("width") and avatar_size.has("height"):
			if avatar_size["width"] > 0 and avatar_size["height"] > 0:
				# getImageRGBA gibt ein Dictionary zurück mit "buffer" key
				var avatar_data: Dictionary = Steam.getImageRGBA(avatar_handle)
				
				if avatar_data.has("buffer"):
					var avatar_buffer: PackedByteArray = avatar_data["buffer"]
					
					if avatar_buffer.size() > 0:
						# Erstelle Image aus Steam-Daten
						var avatar_image := Image.create_from_data(
							avatar_size["width"],
							avatar_size["height"],
							false,
							Image.FORMAT_RGBA8,
							avatar_buffer
						)
						
						if avatar_image:
							# 🆕 Mache Avatar quadratisch (crop zum kleineren Seitenverhältnis)
							var width: int = int(avatar_size["width"])
							var height: int = int(avatar_size["height"])
							
							if width != height:
								var crop_size: int = min(width, height)
								var offset_x: int = (width - crop_size) / 2
								var offset_y: int = (height - crop_size) / 2
								
								# Crop zum Quadrat
								var rect := Rect2i(offset_x, offset_y, crop_size, crop_size)
								var cropped_image := avatar_image.get_region(rect)
								avatar_image = cropped_image
								
								print("🔲 Avatar gecropped zu:", crop_size, "x", crop_size)
							
							# Erstelle Texture2D aus Image
							var texture := ImageTexture.create_from_image(avatar_image)
							fish["steam_avatar"] = texture
							
							print("✅ Steam Avatar geladen:", avatar_image.get_width(), "x", avatar_image.get_height())
						else:
							print("⚠️ Konnte Image nicht erstellen")
					else:
						print("⚠️ Avatar Buffer leer")
				else:
					print("⚠️ Avatar Data hat keinen 'buffer' key")
			else:
				print("⚠️ Avatar Größe ungültig:", avatar_size)
		else:
			print("⚠️ Avatar Size Dictionary fehlt width/height")
	else:
		print("⚠️ Kein Avatar Handle:", avatar_handle)

# ===========================
#  RARITY BOOST CALCULATION
# ===========================
static func _calculate_rarity_boost(base_spawn: float, rarity: int, bait_level: int) -> float:
	var max_boost: float = 0.0
	var growth_rate: float = 0.0
	
	match rarity:
		RARITY.NORMAL:
			max_boost = -0.90
			growth_rate = 0.12
		
		RARITY.UNGEWOEHNLICH:
			max_boost = 0.40
			growth_rate = 0.15
		
		RARITY.SELTEN:
			max_boost = 1.5
			growth_rate = 0.12
		
		RARITY.EPISCH:
			max_boost = 2.5
			growth_rate = 0.10
		
		RARITY.LEGENDAER:
			max_boost = 5.0
			growth_rate = 0.08
		
		RARITY.EXOTISCH:
			max_boost = 10.0
			growth_rate = 0.06
		
		RARITY.ANTIK:
			max_boost = 8.0
			growth_rate = 0.08
	
	var progress: float = 1.0 - exp(-growth_rate * (bait_level - 1))
	var multiplier: float = 1.0 + (max_boost * progress)
	multiplier = max(multiplier, 0.10)
	
	return base_spawn * multiplier

# Helper: Summe aller Gewichte
static func _sum_weights(weights: Dictionary) -> float:
	var total := 0.0
	for w in weights.values():
		total += w
	return total

static func _fallback_fish() -> Dictionary:
	return {
		"id": "UNKNOWN",
		"name_key": "FISH_UNKNOWN_NAME",
		"description_key": "",
		"science_key": "",
		"rarity": RARITY.NORMAL,
		"base_value": 1,
		"icon": "res://assets/fish/unknown.png",
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
	
	# 🆕 STEAM PLAYER INTEGRATION
	if selected.get("is_steam_player", false):
		_apply_steam_data_to_fish(selected)

	# Gewicht generieren
	if selected.has("weight_min") and selected.has("weight_max"):
		var w = randf_range(selected["weight_min"], selected["weight_max"])
		selected["weight"] = snappedf(w, 0.01)
	else:
		selected["weight"] = 1.0

	selected["is_new_catch"] = not Player.caught_fish_species.has(selected["id"])
	return selected

# ===========================
#  DIFFICULTY (FIXED VERSION)
# ===========================
static func get_fish_difficulty(fish: Dictionary) -> float:
	if not fish.has("rarity"):
		push_error("⚠️ Fish ohne rarity: ", fish.get("id", "Unknown"))
		return 1.0
	
	var rarity: int = fish["rarity"]
	
	if not RARITY_DATA.has(rarity):
		push_error("⚠️ Ungültige rarity: ", rarity, " für ", fish.get("id", "Unknown"))
		return 1.0
	
	var difficulty: float = RARITY_DATA[rarity].get("difficulty", 1.0)
	return max(difficulty, 0.5)

static func get_marker_speed_for_fish(fish: Dictionary, base_speed: float = 350.0) -> float:
	var speed := base_speed * get_fish_difficulty(fish)
	return max(speed, 50.0)

# ===========================
#  ICON ACCESS
# ===========================
static func get_fish_icon(fish: Dictionary) -> Texture2D:
	# 1️⃣ Steam-Fish → Avatar oder Player-Fallback
	if fish.get("is_steam_player", false):
		if fish.has("steam_avatar") and fish["steam_avatar"] is Texture2D:
			return fish["steam_avatar"]
		return load("res://assets/fish/player.png")

	# 2️⃣ Normale Fische → Icon-Pfad
	var icon_path : String= fish.get("icon", "")
	if icon_path is String and icon_path != "" and ResourceLoader.exists(icon_path):
		var tex := load(icon_path)
		if tex is Texture2D:
			return tex

	# 3️⃣ Globaler Fallback
	return load("res://assets/fish/unknown.png")


# ===========================
#  RARITY STRING → ENUM (FIXED)
# ===========================
static func rarity_string_to_enum(r: String) -> int:
	var map := {
		"Common": RARITY.NORMAL,
		"Uncommon": RARITY.UNGEWOEHNLICH,
		"Rare": RARITY.SELTEN,
		"Epic": RARITY.EPISCH,
		"Legendary": RARITY.LEGENDAER,
		"Exotic": RARITY.EXOTISCH,
		"Ungewöhnlich": RARITY.UNGEWOEHNLICH,
		"Selten": RARITY.SELTEN,
		"Episch": RARITY.EPISCH,
		"Legendär": RARITY.LEGENDAER,
		"Exotisch": RARITY.EXOTISCH
	}
	return map.get(r, -1)

# ===========================
# SICHERE RARITY-ZUGRIFFE
# ===========================
static func get_rarity_safe(fish: Dictionary) -> int:
	"""Gibt rarity zurück oder NORMAL als Fallback"""
	if not fish.has("rarity"):
		push_warning("⚠️ Fisch ohne rarity:", fish.get("id", "Unknown"))
		return RARITY.NORMAL
	
	var rarity = fish["rarity"]
	if not RARITY_DATA.has(rarity):
		push_warning("⚠️ Ungültige rarity:", rarity)
		return RARITY.NORMAL
	
	return rarity

static func get_rarity_data_safe(fish: Dictionary) -> Dictionary:
	"""Gibt rarity data zurück oder Normal-Daten"""
	var rarity = get_rarity_safe(fish)
	return RARITY_DATA[rarity]

static func get_rarity_name_key(fish: Dictionary) -> String:
	var data := get_rarity_data_safe(fish)
	return str(data.get("name_key", "RARITY_UNKNOWN"))

static func get_rarity_color(fish: Dictionary) -> Color:
	"""Gibt Rarity-Farbe zurück"""
	return get_rarity_data_safe(fish)["color"]

static func get_rarity_value(fish: Dictionary) -> float:
	"""Gibt Rarity-Wert zurück"""
	return get_rarity_data_safe(fish)["value"]

static func get_fish_value(fish: Dictionary) -> int:
	"""Berechnet Verkaufswert des Fisches"""
	var base_value = fish.get("base_value", 1)
	var rarity_multiplier = get_rarity_value(fish)
	return int(base_value * rarity_multiplier)

func get_fish_name(fish: Dictionary) -> String:
	# 🆕 Prüfe ob Steam-Name vorhanden
	if fish.has("steam_name") and fish["steam_name"] != "":
		return fish["steam_name"]
	
	var key: String = fish.get("name_key", "")
	if key == "":
		return tr("UNKNOWN")
	return tr(key)

func get_fish_description(fish: Dictionary) -> String:
	var key: String = fish.get("description_key", "")
	return tr(key) if key != "" else ""

func get_fish_science(fish: Dictionary) -> String:
	var key: String = fish.get("science_key", "")
	return tr(key) if key != "" else ""

func get_fish_story(fish: Dictionary) -> String:
	var key: String = fish.get("story_key", "")
	return tr(key) if key != "" else ""

func get_fish_by_id(id: String) -> Dictionary:
	for list in [FISH_LAKE, FISH_CITY, FISH_SEWER, FISH_FOREST, FISH_DESERT, FISH_ICELAND, FISH_OCEAN]:
		for fish in list:
			if fish.get("id", "") == id:
				return fish
	return {}
	
func get_fish_name_by_id(fish_id: String) -> String:
	var fish := get_fish_by_id(fish_id)
	if fish.is_empty():
		return tr("FISH_UNKNOWN_NAME")
	
	# 🆕 Steam-Name Support
	if fish.has("steam_name") and fish["steam_name"] != "":
		return fish["steam_name"]
	
	return tr(fish.get("name_key", "FISH_UNKNOWN_NAME"))

func get_fish_list_for_biome(biome: String) -> Array:
	match biome:
		"lake":
			return FISH_LAKE
		"city":
			return FISH_CITY
		"sewer":
			return FISH_SEWER
		"forest":
			return FISH_FOREST
		"desert":
			return FISH_DESERT
		"iceland":
			return FISH_ICELAND
		"ocean":
			return FISH_OCEAN
		_:
			push_warning("⚠️ Unbekanntes Biom: %s" % biome)
			return FISH_LAKE
			
# ===========================
# 🆕 STEAM PLAYER FISH (OCEAN)
# ===========================
func get_steam_player_fish() -> Dictionary:
	# Sicherheit: Ocean-Liste prüfen
	if FISH_OCEAN.is_empty():
		push_error("❌ FISH_OCEAN ist leer!")
		return {}

	# Es gibt absichtlich nur EINEN Fisch
	var fish: Dictionary = FISH_OCEAN[0].duplicate(true)

	# Erzwinge ANTIK
	fish["rarity"] = RARITY.ANTIK
	fish["base_value"] = 0
	fish["is_story_item"] = true
	fish["unique"] = true

	# 🆕 Steam-Daten anwenden
	if fish.get("is_steam_player", false):
		_apply_steam_data_to_fish(fish)

	# Gewicht generieren
	if fish.has("weight_min") and fish.has("weight_max"):
		var w = randf_range(fish["weight_min"], fish["weight_max"])
		fish["weight"] = snappedf(w, 0.01)
	else:
		fish["weight"] = 80.0

	# Immer "neu" (existenzielle Bedeutung)
	fish["is_new_catch"] = true

	return fish
