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
	 "description": "Keine Ahnung wie der hier rein passt... Der ist viel zu fett.", "weight_min": 5.0, "weight_max": 15.0},
	
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
	 "description": "Leuchtet im Dunkeln. FDA-Zulassung ausstehend. Nicht essbar", "weight_min": 10.0, "weight_max": 25.0},
#{"name": "Schlummerlachs", "rarity": RARITY.NORMAL, "base_value": 6, "icon": "res://assets/fish/schlummerlachs.png",
 #"description": "Schläft mehr als du am Montagmorgen.", "weight_min": 0.4, "weight_max": 1.2},
#
#{"name": "Tümpelschleicher", "rarity": RARITY.NORMAL, "base_value": 4, "icon": "res://assets/fish/tuempelschleicher.png",
 #"description": "War schon hier, bevor der See existierte.", "weight_min": 0.3, "weight_max": 0.7},
#
#{"name": "Grinsforelle", "rarity": RARITY.NORMAL, "base_value": 7, "icon": "res://assets/fish/grinsforelle.png",
 #"description": "Lächelt dich extrem unangenehm an.", "weight_min": 0.3, "weight_max": 1.0},
#
#{"name": "Schwimmhamster", "rarity": RARITY.UNGEWOEHNLICH, "base_value": 10, "icon": "res://assets/fish/schwimmhamster.png",
 #"description": "Kein Hamster. Niemand weiß, was er wirklich ist.", "weight_min": 0.2, "weight_max": 0.4},
#
#{"name": "Blubberfisch", "rarity": RARITY.UNGEWOEHNLICH, "base_value": 12, "icon": "res://assets/fish/blubber.png",
 #"description": "Macht Blasen. Viele Blasen. Zu viele.", "weight_min": 0.8, "weight_max": 1.6},
#
#{"name": "Schwarzschuppe", "rarity": RARITY.UNGEWOEHNLICH, "base_value": 14, "icon": "res://assets/fish/schwarzschuppe.png",
 #"description": "Macht auf edgy, ist aber ganz nett.", "weight_min": 1.0, "weight_max": 3.0},
#
#{"name": "Schattenbarsch", "rarity": RARITY.SELTEN, "base_value": 20, "icon": "res://assets/fish/schattenbarsch.png",
 #"description": "Taucht nur auf, wenn keiner hinschaut.", "weight_min": 2.0, "weight_max": 5.0},
#
#{"name": "Eisfinne", "rarity": RARITY.SELTEN, "base_value": 24, "icon": "res://assets/fish/eisfinne.png",
 #"description": "Kälter als dein Herz nach dem dritten Date.", "weight_min": 1.2, "weight_max": 3.0},
#
#{"name": "Glitzerkette", "rarity": RARITY.SELTEN, "base_value": 22, "icon": "res://assets/fish/glitzerkette.png",
 #"description": "Strahlt wie ein Influencer-Ringlicht.", "weight_min": 0.1, "weight_max": 0.3},
#
#{"name": "Donnerkabel", "rarity": RARITY.EPISCH, "base_value": 35, "icon": "res://assets/fish/donnerkabel.png",
 #"description": "Macht elektrische Geräusche. Unter Wasser. Unnötig bedrohlich.", "weight_min": 3.0, "weight_max": 7.0},
#
#{"name": "Mondschuppenlachs", "rarity": RARITY.EPISCH, "base_value": 38, "icon": "res://assets/fish/mondschuppen.png",
 #"description": "Glänzt heller als die Zukunft deiner Ex.", "weight_min": 1.0, "weight_max": 3.5},
#
#{"name": "Rißfisch", "rarity": RARITY.EPISCH, "base_value": 40, "icon": "res://assets/fish/rissfisch.png",
 #"description": "Besteht aus 90% Angst und 10% Wasser.", "weight_min": 0.5, "weight_max": 1.2},
#
#{"name": "Königskarpfen", "rarity": RARITY.LEGENDAER, "base_value": 60, "icon": "res://assets/fish/koenigskar.png",
 #"description": "Gibt sich königlich. Steht dir aber trotzdem nicht zu.", "weight_min": 12.0, "weight_max": 20.0},
#
#{"name": "Schimmergeist", "rarity": RARITY.LEGENDAER, "base_value": 65, "icon": "res://assets/fish/schimmergeist.png",
 #"description": "Fast unsichtbar. Fast auch egal.", "weight_min": 0.3, "weight_max": 1.0},
#
#{"name": "Splitterforelle", "rarity": RARITY.LEGENDAER, "base_value": 70, "icon": "res://assets/fish/splitterf.png",
 #"description": "Ihre Schuppen schneiden dich emotional.", "weight_min": 2.0, "weight_max": 6.0},
#
#{"name": "Zeitfresser", "rarity": RARITY.EXOTISCH, "base_value": 160, "icon": "res://assets/fish/zeitfresser.png",
 #"description": "Du schaust ihn an – zwei Stunden vorbei.", "weight_min": 0.6, "weight_max": 1.5},
#
#{"name": "Wellenwächter", "rarity": RARITY.EXOTISCH, "base_value": 180, "icon": "res://assets/fish/wellenwaechter.png",
 #"description": "Bewacht Wellen. Keine Ahnung warum.", "weight_min": 5.0, "weight_max": 10.0},
#
#{"name": "See-Eisen", "rarity": RARITY.EXOTISCH, "base_value": 200, "icon": "res://assets/fish/see_eisen.png",
 #"description": "Ein Fisch aus Metall. Physik wurde gefeuert.", "weight_min": 20.0, "weight_max": 40.0},
#
#{"name": "Kosmoskoi", "rarity": RARITY.EXOTISCH, "base_value": 240, "icon": "res://assets/fish/kosmoskoi.png",
 #"description": "Schaut in deine Seele und bewertet sie mit 3/10.", "weight_min": 1.0, "weight_max": 3.0},
#
#{"name": "Fehler_404", "rarity": RARITY.EXOTISCH, "base_value": 300, "icon": "res://assets/fish/error404.png",
 #"description": "Fisch konnte nicht gefunden werden.", "weight_min": 0.0, "weight_max": 0.0}

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
	 "description": "Kennt deine Suchanfragen. Alle. Ja, auch die. Sicher das der Name richtig ist?", "weight_min": 10.0, "weight_max": 30.0},
#{"name": "U-Bahn-Guppy", "rarity": RARITY.NORMAL, "base_value": 7, "icon": "res://assets/fish/u_bahn_guppy.png",
 #"description": "Kommt immer zu spät. Selbst im Wasser.", "weight_min": 0.2, "weight_max": 0.6},
#
#{"name": "Kiezkrümmer", "rarity": RARITY.NORMAL, "base_value": 6, "icon": "res://assets/fish/kiezkruemmer.png",
 #"description": "Riecht nach Bier und Verzweiflung.", "weight_min": 0.3, "weight_max": 1.0},
#
#{"name": "Pfandflosser", "rarity": RARITY.NORMAL, "base_value": 8, "icon": "res://assets/fish/pfandflosser.png",
 #"description": "Sammelt Flaschen. Auch unter Wasser.", "weight_min": 0.1, "weight_max": 0.4},
#
#{"name": "Laternenleuchte", "rarity": RARITY.UNGEWOEHNLICH, "base_value": 12, "icon": "res://assets/fish/laternenleuchte.png",
 #"description": "Leuchtet heller als die ganze Straße.", "weight_min": 0.4, "weight_max": 1.0},
#
#{"name": "Asphaltkriecher", "rarity": RARITY.UNGEWOEHNLICH, "base_value": 13, "icon": "res://assets/fish/asphaltkriecher.png",
 #"description": "Wurde offenbar auf einer Straße geboren.", "weight_min": 1.0, "weight_max": 2.5},
#
#{"name": "Taschenratte", "rarity": RARITY.UNGEWOEHNLICH, "base_value": 14, "icon": "res://assets/fish/taschenratte.png",
 #"description": "Lebt in Taschen und frisst Kaugummis.", "weight_min": 0.6, "weight_max": 1.5},
#
#{"name": "Gullygeist", "rarity": RARITY.SELTEN, "base_value": 20, "icon": "res://assets/fish/gullygeist.png",
 #"description": "Spukt in Abflussgittern. Du wolltest ihn nicht finden.", "weight_min": 0.2, "weight_max": 0.7},
#
#{"name": "Antennenschleicher", "rarity": RARITY.SELTEN, "base_value": 22, "icon": "res://assets/fish/antennenschleicher.png",
 #"description": "Bringt HD-Empfang. In SD-Qualität.", "weight_min": 0.5, "weight_max": 1.2},
#
#{"name": "Parkbankhecht", "rarity": RARITY.SELTEN, "base_value": 19, "icon": "res://assets/fish/parkbankhecht.png",
 #"description": "Wurde zuletzt mit einer Bierdose gesehen.", "weight_min": 1.0, "weight_max": 4.0},
#
#{"name": "Ampelrochen", "rarity": RARITY.EPISCH, "base_value": 32, "icon": "res://assets/fish/ampelrochen.png",
 #"description": "Wechselt Farben — aber nur auf Rot.", "weight_min": 2.0, "weight_max": 4.0},
#
#{"name": "Stromkasten-Lurker", "rarity": RARITY.EPISCH, "base_value": 34, "icon": "res://assets/fish/stromlurker.png",
 #"description": "Hat mehr Volt als du Entscheidungen im Leben.", "weight_min": 1.0, "weight_max": 3.0},
#
#{"name": "Graffiti-Barsch", "rarity": RARITY.EPISCH, "base_value": 37, "icon": "res://assets/fish/graffiti_barsch.png",
 #"description": "Besprüht Wände. Unter Wasser. Fragt nicht.", "weight_min": 0.8, "weight_max": 2.0},
#
#{"name": "Neon-Stadthai", "rarity": RARITY.LEGENDAER, "base_value": 60, "icon": "res://assets/fish/neon_stadthai.png",
 #"description": "Leuchtet wie Reklametafeln um 03:00 Uhr.", "weight_min": 4.0, "weight_max": 12.0},
#
#{"name": "Kellerkönig", "rarity": RARITY.LEGENDAER, "base_value": 70, "icon": "res://assets/fish/kellerkoenig.png",
 #"description": "Regiert feuchte Kellerräume mit eiserner Flosse.", "weight_min": 3.0, "weight_max": 7.0},
#
#{"name": "Drehkreuz-Schuppe", "rarity": RARITY.LEGENDAER, "base_value": 65, "icon": "res://assets/fish/drehkreuz.png",
 #"description": "Lässt dich nur durch, wenn du gültig entwertet bist.", "weight_min": 2.0, "weight_max": 6.0},
#
#{"name": "Internetabfallfisch", "rarity": RARITY.EXOTISCH, "base_value": 180, "icon": "res://assets/fish/internetmuell.png",
 #"description": "Lebt von Memes. Sehr toxisch.", "weight_min": 0.5, "weight_max": 1.5},
#
#{"name": "Serverkrake", "rarity": RARITY.EXOTISCH, "base_value": 220, "icon": "res://assets/fish/serverkrake.png",
 #"description": "Betreibt sein eigenes Rechenzentrum.", "weight_min": 10.0, "weight_max": 25.0},
#
#{"name": "Nachbarschaftsdämon", "rarity": RARITY.EXOTISCH, "base_value": 260, "icon": "res://assets/fish/nachbar.png",
 #"description": "Beobachtet dich. Immer. Unangenehm.", "weight_min": 1.0, "weight_max": 3.0},
#
#{"name": "Flutlichtfresser", "rarity": RARITY.EXOTISCH, "base_value": 300, "icon": "res://assets/fish/flutlicht.png",
 #"description": "Frisst Lampen und strahlt dann selber.", "weight_min": 5.0, "weight_max": 15.0},
#
#{"name": "Betrunkener Aal", "rarity": RARITY.EXOTISCH, "base_value": 140, "icon": "res://assets/fish/betrunken_aal.png",
 #"description": "Weiß selbst nicht, wie er hier gelandet ist.", "weight_min": 0.5, "weight_max": 2.0}

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
	
	{"name": "Bilderbuchfisch", "rarity": RARITY.LEGENDAER, "base_value": 90, "icon": "res://assets/fish/Rainbowi.png",
	 "description": "Die einzige Hoffnung in diesem Drecksloch.", "weight_min": 1.0, "weight_max": 10.0},
	
	{"name": "Wütende Scholle", "rarity": RARITY.EXOTISCH, "base_value": 200, "icon": "res://assets/fish/scholle.png",
	 "description": "Hat valide Gründe für ihre Wut. Glaub mir.", "weight_min": 1.0, "weight_max": 3.0},
	
	{"name": "Kondom", "rarity": RARITY.EXOTISCH, "base_value": 8, "icon": "res://assets/fish/Kondom.png",
	 "description": "Gebraucht. Wirf es zurück. WIRF. ES. ZURÜCK.", "weight_min": 0.005, "weight_max": 0.02},
#{"name": "Rattenlachs", "rarity": RARITY.NORMAL, "base_value": 9, "icon": "res://assets/fish/rattenlachs.png",
 #"description": "Halb Lachs, halb Ratte, komplett fragwürdig.", "weight_min": 0.3, "weight_max": 1.0},
#
#{"name": "Schleimschupper", "rarity": RARITY.NORMAL, "base_value": 8, "icon": "res://assets/fish/schleimschuppe.png",
 #"description": "Glitschig. Sehr glitschig. Zu glitschig.", "weight_min": 0.2, "weight_max": 0.5},
#
#{"name": "Pfützling", "rarity": RARITY.NORMAL, "base_value": 7, "icon": "res://assets/fish/pfuetzling.png",
 #"description": "Winziges Wesen aus reiner Enttäuschung.", "weight_min": 0.05, "weight_max": 0.15},
#
#{"name": "Abflusskabel", "rarity": RARITY.UNGEWOEHNLICH, "base_value": 12, "icon": "res://assets/fish/abflusskabel.png",
 #"description": "Hat sich in der Kanalisation verlaufen. Seit 1999.", "weight_min": 0.8, "weight_max": 2.0},
#
#{"name": "Schrubbfisch", "rarity": RARITY.UNGEWOEHNLICH, "base_value": 13, "icon": "res://assets/fish/schrubb.png",
 #"description": "Putzt den Boden. Ungefragt.", "weight_min": 1.5, "weight_max": 3.0},
#
#{"name": "Hygienekarpfen", "rarity": RARITY.UNGEWOEHNLICH, "base_value": 11, "icon": "res://assets/fish/hygienef.png",
 #"description": "Trägt immer zwei Masken. Aus Prinzip.", "weight_min": 0.6, "weight_max": 1.8},
#
#{"name": "Biohazard-Barsch", "rarity": RARITY.SELTEN, "base_value": 22, "icon": "res://assets/fish/biohazard.png",
 #"description": "Bei Kontakt bitte sofort den Arzt rufen.", "weight_min": 1.0, "weight_max": 2.5},
#
#{"name": "Latrinenrochen", "rarity": RARITY.SELTEN, "base_value": 25, "icon": "res://assets/fish/latrine.png",
 #"description": "Fliegt flach — riecht stark.", "weight_min": 3.0, "weight_max": 6.0},
#
#{"name": "Zementfresser", "rarity": RARITY.SELTEN, "base_value": 21, "icon": "res://assets/fish/zementfresser.png",
 #"description": "Knabbert Beton wie Chips.", "weight_min": 4.0, "weight_max": 8.0},
#
#{"name": "Schachtkobold", "rarity": RARITY.EPISCH, "base_value": 40, "icon": "res://assets/fish/schachtkobold.png",
 #"description": "Lebt in Schächten und lacht sehr ungesund.", "weight_min": 1.0, "weight_max": 2.0},
#
#{"name": "Industrieaal", "rarity": RARITY.EPISCH, "base_value": 38, "icon": "res://assets/fish/industrieaal.png",
 #"description": "Besteht zu 70% aus Motoröl.", "weight_min": 3.0, "weight_max": 7.0},
#
#{"name": "Schmutzstachel", "rarity": RARITY.EPISCH, "base_value": 36, "icon": "res://assets/fish/schmutzstachel.png",
 #"description": "Hat einen Stachel aus purem Nihilismus.", "weight_min": 2.0, "weight_max": 5.0},
#
#{"name": "Kanalrattenkönig", "rarity": RARITY.LEGENDAER, "base_value": 70, "icon": "res://assets/fish/rattenkoenig.png",
 #"description": "Regiert die Unterwelt. Wortwörtlich.", "weight_min": 4.0, "weight_max": 10.0},
#
#{"name": "Schlicksirene", "rarity": RARITY.LEGENDAER, "base_value": 80, "icon": "res://assets/fish/schlicksirene.png",
 #"description": "Singt schön. Riecht weniger schön.", "weight_min": 0.5, "weight_max": 1.5},
#
#{"name": "Betonengel", "rarity": RARITY.LEGENDAER, "base_value": 85, "icon": "res://assets/fish/betonengel.png",
 #"description": "Hart wie Stein. Nett wie Oma.", "weight_min": 10.0, "weight_max": 20.0},
#
#{"name": "Abflussdämon", "rarity": RARITY.EXOTISCH, "base_value": 200, "icon": "res://assets/fish/abflussdaemon.png",
 #"description": "Steigt auf, wenn du dreimal fluchst.", "weight_min": 0.4, "weight_max": 1.0},
#
#{"name": "Röhrenwyrm", "rarity": RARITY.EXOTISCH, "base_value": 240, "icon": "res://assets/fish/roehrenwyrm.png",
 #"description": "Altes Wesen. Mag Rohre. Nur Rohre.", "weight_min": 8.0, "weight_max": 18.0},
#
#{"name": "Giftgrützer", "rarity": RARITY.EXOTISCH, "base_value": 250, "icon": "res://assets/fish/giftgruetz.png",
 #"description": "Leuchtet grün. Sollte es nicht.", "weight_min": 1.0, "weight_max": 3.0},
#
#{"name": "Klopapier-Schlange", "rarity": RARITY.EXOTISCH, "base_value": 120, "icon": "res://assets/fish/klopapier.png",
 #"description": "Tauchte 2020 das erste Mal auf.", "weight_min": 0.2, "weight_max": 0.6},
#
#{"name": "Verdorbener Traum", "rarity": RARITY.EXOTISCH, "base_value": 300, "icon": "res://assets/fish/traum.png",
 #"description": "Manifestation deiner Lebensentscheidungen.", "weight_min": 0.1, "weight_max": 0.3}

]

var FISH_FOREST = [
	{"name": "Karpfen", "rarity": RARITY.NORMAL, "base_value": 10, "icon": "res://assets/fish/Karpfen.png",
	 "description": "Meditiert unter Wasser. Unc ist vegatarisch.", "weight_min": 3.0, "weight_max": 10.0},
	
	{"name": "Wels", "rarity": RARITY.NORMAL, "base_value": 15, "icon": "res://assets/fish/Wels.png",
	 "description": "Der Bartwuchs ist legendär. Der Rest? Naja.", "weight_min": 5.0, "weight_max": 25.0},
	
	{"name": "Koi", "rarity": RARITY.UNGEWOEHNLICH, "base_value": 19, "icon": "res://assets/fish/koi.png",
	 "description": "Kostet in Japan ein Vermögen. Hier? Mittwochsangebot.", "weight_min": 2.0, "weight_max": 8.0},
	
	{"name": "Rohrschatten", "rarity": RARITY.SELTEN, "base_value": 27, "icon": "res://assets/fish/rohrschatten.png",
	 "description": "Versteckt sich zwischen Schilf. Stealth Level 100.", "weight_min": 0.5, "weight_max": 2.0},
	
	{"name": "Angel", "rarity": RARITY.SELTEN, "base_value": 28, "icon": "res://assets/fish/angel.png",
	 "description": "Schöne Angel! Oder ist das vielleicht doch eine Peitsche? Du kannst sie jedenfalls NICHT verwenden (auch wenn sie verzaubert wäre).", "weight_min": 0.8, "weight_max": 2.0},
	
	{"name": "Waldaal", "rarity": RARITY.EPISCH, "base_value": 45, "icon": "res://assets/fish/waldaal.png",
	 "description": "Elektrisierend. Wörtlich.", "weight_min": 1.0, "weight_max": 3.0},
	
	{"name": "Waldfresser", "rarity": RARITY.EPISCH, "base_value": 70, "icon": "res://assets/fish/Gutter.png",
	 "description": "Vegetarier. Frisst buchstäblich den Wald. Irgendwie ironisch.", "weight_min": 10.0, "weight_max": 30.0},
	
	{"name": "Bambushai", "rarity": RARITY.LEGENDAER, "base_value": 100, "icon": "res://assets/fish/bambus.png",
	 "description": "Ernährt sich von Bambus und innerer Ruhe.", "weight_min": 5.0, "weight_max": 15.0},
	
	{"name": "Wurzelfisch", "rarity": RARITY.EXOTISCH, "base_value": 250, "icon": "res://assets/fish/wurzelfisch.png",
	 "description": "Halb Fisch, halb Baum, komplett verstörend.", "weight_min": 20.0, "weight_max": 50.0},
	
	{"name": "Markus", "rarity": RARITY.EXOTISCH, "base_value": 0, "icon": "res://assets/fish/corpse.png",
	 "description": "Schon wieder? Ernsthaft?", "weight_min": 60.0, "weight_max": 90.0},
#{"name": "Moosbarbe", "rarity": RARITY.NORMAL, "base_value": 12, "icon": "res://assets/fish/moosbarbe.png",
 #"description": "Hat mehr Moos am Körper als du im Portemonnaie.", "weight_min": 0.5, "weight_max": 1.5},
#
#{"name": "Waldmolchling", "rarity": RARITY.NORMAL, "base_value": 11, "icon": "res://assets/fish/waldmolch.png",
 #"description": "Technisch kein Fisch. Tut aber so.", "weight_min": 0.1, "weight_max": 0.4},
#
#{"name": "Zapfenfisch", "rarity": RARITY.NORMAL, "base_value": 13, "icon": "res://assets/fish/zapfenfisch.png",
 #"description": "Tarnung 10/10. Sieht aus wie ein Tannenzapfen.", "weight_min": 0.3, "weight_max": 0.9},
#
#{"name": "Wurzelschnapper", "rarity": RARITY.UNGEWOEHNLICH, "base_value": 17, "icon": "res://assets/fish/wurzelschnapper.png",
 #"description": "Knabbert an Bäumen. Hat Geschmack.", "weight_min": 1.0, "weight_max": 3.0},
#
#{"name": "Borkenfinne", "rarity": RARITY.UNGEWOEHNLICH, "base_value": 18, "icon": "res://assets/fish/borkenfinne.png",
 #"description": "Halb Fisch, halb Baumrinde.", "weight_min": 0.8, "weight_max": 2.0},
#
#{"name": "Pilzglimmer", "rarity": RARITY.UNGEWOEHNLICH, "base_value": 16, "icon": "res://assets/fish/pilzglimmer.png",
 #"description": "Leuchtet wie ein Pilztrip. Behauptet, essbar zu sein.", "weight_min": 0.2, "weight_max": 0.8},
#
#{"name": "Astläufer", "rarity": RARITY.SELTEN, "base_value": 28, "icon": "res://assets/fish/astlaeufer.png",
 #"description": "Kann klettern. Fängt dich eher als du ihn.", "weight_min": 0.6, "weight_max": 2.0},
#
#{"name": "Naddelwels", "rarity": RARITY.SELTEN, "base_value": 30, "icon": "res://assets/fish/naddelwels.png",
 #"description": "Verschwindet im Dickicht. Und in deinen Träumen.", "weight_min": 2.0, "weight_max": 5.0},
#
#{"name": "Farnschuppe", "rarity": RARITY.SELTEN, "base_value": 26, "icon": "res://assets/fish/farnschuppe.png",
 #"description": "Verschmilzt fast mit Pflanzen. Fast.", "weight_min": 0.4, "weight_max": 1.2},
#
#{"name": "Klangfisch", "rarity": RARITY.EPISCH, "base_value": 48, "icon": "res://assets/fish/klangfisch.png",
 #"description": "Macht Geräusche wie Waldgeister. Oder dein Magen.", "weight_min": 1.0, "weight_max": 3.0},
#
#{"name": "Waldschleicher", "rarity": RARITY.EPISCH, "base_value": 52, "icon": "res://assets/fish/waldschleicher.png",
 #"description": "Siehst du nicht. Fängt dich trotzdem.", "weight_min": 2.0, "weight_max": 4.0},
#
#{"name": "Moonsprout", "rarity": RARITY.EPISCH, "base_value": 55, "icon": "res://assets/fish/moonsprout.png",
 #"description": "Wächst bei Mondlicht. Und flüstert komische Sachen.", "weight_min": 0.5, "weight_max": 1.5},
#
#{"name": "Wipfelhai", "rarity": RARITY.LEGENDAER, "base_value": 95, "icon": "res://assets/fish/wipfelhai.png",
 #"description": "Lebt angeblich in Baumwipfeln. Logik egal.", "weight_min": 3.0, "weight_max": 10.0},
#
#{"name": "Stumpfdrache", "rarity": RARITY.LEGENDAER, "base_value": 100, "icon": "res://assets/fish/stumpfdrache.png",
 #"description": "Mini-Drache, maximal nervig.", "weight_min": 2.0, "weight_max": 6.0},
#
#{"name": "Hainwächter", "rarity": RARITY.LEGENDAER, "base_value": 110, "icon": "res://assets/fish/hainwaechter.png",
 #"description": "Beschützt den Wald. Hält dich aber nicht davon ab, ihn zu fangen.", "weight_min": 4.0, "weight_max": 12.0},
#
#{"name": "Wurzelkoloss", "rarity": RARITY.EXOTISCH, "base_value": 260, "icon": "res://assets/fish/wurzelkoloss.png",
 #"description": "Ein Baum, ein Fisch und eine Identitätskrise.", "weight_min": 20.0, "weight_max": 40.0},
#
#{"name": "Waldflamme", "rarity": RARITY.EXOTISCH, "base_value": 230, "icon": "res://assets/fish/waldflamme.png",
 #"description": "Brennt unter Wasser. Weil Magie. Oder Bug.", "weight_min": 1.0, "weight_max": 3.0},
#
#{"name": "Götterfarnling", "rarity": RARITY.EXOTISCH, "base_value": 280, "icon": "res://assets/fish/goetterfarn.png",
 #"description": "Wurde von einem Waldgott gesegnet. Nicht von einem guten.", "weight_min": 0.3, "weight_max": 1.0},
#
#{"name": "Baumschreck", "rarity": RARITY.EXOTISCH, "base_value": 300, "icon": "res://assets/fish/baumschreck.png",
 #"description": "Würde dich gern essen. Hat aber keine Hände.", "weight_min": 5.0, "weight_max": 15.0},
#
#{"name": "Waldfehler_001", "rarity": RARITY.EXOTISCH, "base_value": 350, "icon": "res://assets/fish/error_forest.png",
 #"description": "Ein Fehler im Waldsystem. Bitte neu starten.", "weight_min": 0.0, "weight_max": 0.0}


]

var FISH_DESERT = [
	{"name": "Schmutzgrundel", "rarity": RARITY.NORMAL, "base_value": 15, "icon": "res://assets/fish/schmutzgrundel.png",
	 "description": "Lebt im Dreck. Buchstäblich. Wie deine Ernährungsgewohnheiten.", "weight_min": 0.2, "weight_max": 0.8},
	
	{"name": "Solarfänger", "rarity": RARITY.NORMAL, "base_value": 16, "icon": "res://assets/fish/solarfänger.png",
	 "description": "Lädt sich über Sonnenlicht auf. Tesla wäre neidisch.", "weight_min": 0.5, "weight_max": 1.5},
	
	{"name": "Rostflosser", "rarity": RARITY.UNGEWOEHNLICH, "base_value": 25, "icon": "res://assets/fish/fish1.png",
	 "description": "Braucht dringend eine Tetanus-Impfung.", "weight_min": 1.0, "weight_max": 3.0},
	
	{"name": "Sandstreifer", "rarity": RARITY.SELTEN, "base_value": 30, "icon": "res://assets/fish/fish1.png",
	 "description": "Getarnt wie ein Sandsturm. Mit Flossen.", "weight_min": 2.0, "weight_max": 6.0},
	
	{"name": "Aggresive Garnele", "rarity": RARITY.EPISCH, "base_value": 55, "icon": "res://assets/fish/garnele.png",
	 "description": "Winzig, aber verdammt wütend. Wie ein Chihuahua.", "weight_min": 0.1, "weight_max": 0.3},
	
	{"name": "Staubhai", "rarity": RARITY.EPISCH, "base_value": 80, "icon": "res://assets/fish/Boro.png",
	 "description": "Schwimmt durch Sand. Physik hat aufgegeben.", "weight_min": 10.0, "weight_max": 40.0},
	
	{"name": "Wasserfisch", "rarity": RARITY.LEGENDAER, "base_value": 120, "icon": "res://assets/fish/fish1.png",
	 "description": "Der einzige Fisch mit Wasser in der Wüste. Ein Held.", "weight_min": 1.0, "weight_max": 4.0},
	
	{"name": "Sonnenfragment", "rarity": RARITY.EXOTISCH, "base_value": 300, "icon": "res://assets/fish/fish1.png",
	 "description": "Ein Stück Sonne. Anfassen nicht empfohlen.", "weight_min": 50.0, "weight_max": 100.0},
	
	{"name": "Goldhai", "rarity": RARITY.EXOTISCH, "base_value": 500, "icon": "res://assets/fish/corpse.png",
	 "description": "Aus echtem Gold. Oder Messing. Vermutlich Messing.", "weight_min": 20.0, "weight_max": 80.0},
#{"name": "Staubgrundel", "rarity": RARITY.NORMAL, "base_value": 17, "icon": "res://assets/fish/staubgrundel.png",
 #"description": "Atmet Staub. Hält länger durch als du.", "weight_min": 0.2, "weight_max": 0.7},
#
#{"name": "Dünenflosse", "rarity": RARITY.NORMAL, "base_value": 16, "icon": "res://assets/fish/duenenflosse.png",
 #"description": "Surft über Sandwellen. Voll der Pro.", "weight_min": 0.3, "weight_max": 1.0},
#
#{"name": "Kieselschupper", "rarity": RARITY.NORMAL, "base_value": 18, "icon": "res://assets/fish/kieselschupper.png",
 #"description": "Sieht aus wie ein überambitionierter Stein.", "weight_min": 0.2, "weight_max": 0.8},
#
#{"name": "Oasenpicker", "rarity": RARITY.UNGEWOEHNLICH, "base_value": 24, "icon": "res://assets/fish/oasenpicker.png",
 #"description": "Findet jede Oase. Du eher nicht.", "weight_min": 0.5, "weight_max": 1.5},
#
#{"name": "Sandglimmer", "rarity": RARITY.UNGEWOEHNLICH, "base_value": 23, "icon": "res://assets/fish/sandglimmer.png",
 #"description": "Glitzert gefährlich verführerisch.", "weight_min": 0.3, "weight_max": 1.2},
#
#{"name": "Kakteenfinne", "rarity": RARITY.UNGEWOEHNLICH, "base_value": 26, "icon": "res://assets/fish/kakteenfinne.png",
 #"description": "Stacheliger als dein Humor.", "weight_min": 0.8, "weight_max": 2.0},
#
#{"name": "Sandbohrer", "rarity": RARITY.SELTEN, "base_value": 32, "icon": "res://assets/fish/sandbohrer.png",
 #"description": "Bohrt sich durch Sand wie du durch Probleme.", "weight_min": 2.0, "weight_max": 6.0},
#
#{"name": "Schimmergecko", "rarity": RARITY.SELTEN, "base_value": 29, "icon": "res://assets/fish/schimmergecko.png",
 #"description": "Wahrscheinlich gar kein Fisch… aber er glitzert!", "weight_min": 0.1, "weight_max": 0.4},
#
#{"name": "Kupferstaubfisch", "rarity": RARITY.SELTEN, "base_value": 35, "icon": "res://assets/fish/kupferstaub.png",
 #"description": "Schmeckt metallisch. Riecht metallischer.", "weight_min": 1.0, "weight_max": 3.0},
#
#{"name": "Hitzeschuppe", "rarity": RARITY.EPISCH, "base_value": 58, "icon": "res://assets/fish/hitzeschuppe.png",
 #"description": "Zu heiß zum Anfassen. Wortwörtlich.", "weight_min": 0.5, "weight_max": 1.2},
#
#{"name": "Quarzflosser", "rarity": RARITY.EPISCH, "base_value": 62, "icon": "res://assets/fish/quarzflosser.png",
 #"description": "Durchsichtiger als deine Ausreden.", "weight_min": 2.0, "weight_max": 5.0},
#
#{"name": "Sandstachelhai", "rarity": RARITY.EPISCH, "base_value": 70, "icon": "res://assets/fish/sandstachel.png",
 #"description": "Hat dieselbe Persönlichkeit wie ein Kaktus.", "weight_min": 5.0, "weight_max": 15.0},
#
#{"name": "Wüstenfürst", "rarity": RARITY.LEGENDAER, "base_value": 110, "icon": "res://assets/fish/wuestenfuerst.png",
 #"description": "Beherrscht den Sand. Und jetzt deinen Eimer.", "weight_min": 3.0, "weight_max": 8.0},
#
#{"name": "Sandwolf", "rarity": RARITY.LEGENDAER, "base_value": 120, "icon": "res://assets/fish/sandwolf.png",
 #"description": "Heult nicht den Mond an. Er heult dich an.", "weight_min": 2.0, "weight_max": 6.0},
#
#{"name": "Mineralienmole", "rarity": RARITY.LEGENDAER, "base_value": 115, "icon": "res://assets/fish/mineralmole.png",
 #"description": "Wühlt wie verrückt. Auch unter Wasser nicht besser.", "weight_min": 4.0, "weight_max": 10.0},
#
#{"name": "Phasensplitter", "rarity": RARITY.EXOTISCH, "base_value": 280, "icon": "res://assets/fish/phasensplitter.png",
 #"description": "Existiert in drei Realitäten gleichzeitig.", "weight_min": 1.0, "weight_max": 3.0},
#
#{"name": "Wüstengottesanbeter", "rarity": RARITY.EXOTISCH, "base_value": 300, "icon": "res://assets/fish/wuestenbeter.png",
 #"description": "Betet für deinen Tod. Nett.", "weight_min": 0.2, "weight_max": 0.6},
#
#{"name": "Glasfresser", "rarity": RARITY.EXOTISCH, "base_value": 320, "icon": "res://assets/fish/glasfresser.png",
 #"description": "Frisst Glas. Und deine Hoffnung.", "weight_min": 5.0, "weight_max": 12.0},
#
#{"name": "Solarbrüller", "rarity": RARITY.EXOTISCH, "base_value": 350, "icon": "res://assets/fish/solarbrueller.png",
 #"description": "Brüllt in die Sonne. Die Sonne brüllt zurück.", "weight_min": 8.0, "weight_max": 20.0},
#
#{"name": "Sandfehler_002", "rarity": RARITY.EXOTISCH, "base_value": 400, "icon": "res://assets/fish/error_desert.png",
 #"description": "Fehlerhafte Wüstensimulation entdeckt.", "weight_min": 0.0, "weight_max": 0.0}

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
