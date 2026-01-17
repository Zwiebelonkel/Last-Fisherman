extends Control

@onready var type_timer: Timer = Timer.new()


# ------------------------------
#   EXPORT VARIABLES
# ------------------------------
@export var dialog_lines := {
	# Normale Kunden
	"cust_01": { "de": "Ich hab gehört, hier gibt's die besten Fische der Stadt!", "en": "I heard you have the best fish in town!" },
	"cust_02": { "de": "Zeig mir, was du heute gefangen hast.", "en": "Show me what you caught today." },
	"cust_03": { "de": "Meine Frau will Fisch zum Abendessen. Hilf mir.", "en": "My wife wants fish for dinner. Help me out." },
	"cust_04": { "de": "Ich zahle gut für seltene Exemplare.", "en": "I pay well for rare specimens." },
	"cust_05": { "de": "Der Laden nebenan hat nichts. Du bist meine letzte Hoffnung.", "en": "The shop next door has nothing. You're my last hope." },
	
	# Mysteriöse/Lore Kunden
	"cust_06": { "de": "Hast du in letzter Zeit… seltsame Dinge im Wasser gesehen?", "en": "Have you seen… strange things in the water lately?" },
	"cust_07": { "de": "Die alten Fischer warnen vor dem tiefen See.", "en": "The old fishermen warn about the deep lake." },
	"cust_08": { "de": "Man munkelt, im Wald verschwinden nachts Leute.", "en": "Rumor has it people disappear in the forest at night." },
	"cust_09": { "de": "Ich brauche Fisch für ein… spezielles Ritual.", "en": "I need fish for a… special ritual." },
	"cust_10": { "de": "Die Stadt verändert sich. Hast du es auch bemerkt?", "en": "The city is changing. Have you noticed too?" },
	
	# Ungeduldig/Fordernd
	"cust_11": { "de": "Ich habe nicht den ganzen Tag Zeit!", "en": "I don't have all day!" },
	"cust_12": { "de": "Hoffentlich ist dein Fisch frisch.", "en": "I hope your fish is fresh." },
	"cust_13": { "de": "Gib mir das Beste, was du hast. Preis ist egal.", "en": "Give me the best you have. Price doesn't matter." },
	"cust_14": { "de": "Ich bin in Eile, mach schnell!", "en": "I'm in a hurry, be quick!" },
	"cust_15": { "de": "Wenn die Qualität stimmt, komme ich wieder.", "en": "If the quality is good, I'll come back." },
	
	# Freundlich/Gesprächig
	"cust_16": { "de": "Schöner Tag zum Fischen, nicht wahr?", "en": "Nice day for fishing, isn't it?" },
	"cust_17": { "de": "Dein Laden hat einen guten Ruf!", "en": "Your shop has a good reputation!" },
	"cust_18": { "de": "Ich bin Stammkunde. Du erkennst mich nicht?", "en": "I'm a regular. Don't you recognize me?" },
	"cust_19": { "de": "Meine Kinder lieben deinen Fisch!", "en": "My children love your fish!" },
	"cust_20": { "de": "Was empfiehlst du heute?", "en": "What do you recommend today?" },
	
	# Wüste/Biom-bezogen
	"cust_21": { "de": "Die Hitze in der Wüste ist unerträglich.", "en": "The heat in the desert is unbearable." },
	"cust_22": { "de": "Gibt es auch Wüstenfische? Das würde mich interessieren.", "en": "Are there desert fish? That would interest me." },
	"cust_23": { "de": "Im Norden soll ein gefrorener See sein.", "en": "They say there's a frozen lake in the north." },
	"cust_24": { "de": "Die Kanalisation ist gefährlich, aber profitabel.", "en": "The sewers are dangerous but profitable." },
	"cust_25": { "de": "Hast du schon mal im verfluchten Sumpf geangelt?", "en": "Have you ever fished in the cursed swamp?" },
	
	# Aberglaube/Mystik
	"cust_26": { "de": "Ein alter Geist soll nachts am Wasser wandeln.", "en": "An old spirit is said to walk by the water at night." },
	"cust_27": { "de": "Manche Fische bringen Glück, andere… Pech.", "en": "Some fish bring luck, others… misfortune." },
	"cust_28": { "de": "Die Vollmondnächte sind am besten zum Angeln.", "en": "Full moon nights are best for fishing." },
	"cust_29": { "de": "Ich habe ein Leuchten im Wasser gesehen. Warst du das?", "en": "I saw a glow in the water. Was that you?" },
	"cust_30": { "de": "Pass auf die großen Fische auf. Sie beißen zurück.", "en": "Watch out for the big fish. They bite back." },
	
	# Humorvoll/Sarkastisch
	"cust_31": { "de": "Ich hoffe, du verkaufst mir keinen Gummifisch.", "en": "I hope you're not selling me a rubber fish." },
	"cust_32": { "de": "Riechen deine Fische immer so… interessant?", "en": "Do your fish always smell so… interesting?" },
	"cust_33": { "de": "Mein letzter Fischer ist verschwunden. Lange Geschichte.", "en": "My last fisherman disappeared. Long story." },
	"cust_34": { "de": "Wenn der Preis stimmt, stelle ich keine Fragen.", "en": "If the price is right, I won't ask questions." },
	"cust_35": { "de": "Du siehst aus wie jemand, der weiß, wo die guten Fische sind.", "en": "You look like someone who knows where the good fish are." },
	
	# Story/Lore Hints
	"cust_36": { "de": "Der alte Leuchtturm wird nachts wieder aktiv.", "en": "The old lighthouse is active again at night." },
	"cust_37": { "de": "Jemand hat die verbotene Zone betreten. Dumme Idee.", "en": "Someone entered the forbidden zone. Bad idea." },
	"cust_38": { "de": "Die Regierung verheimlicht etwas über den See.", "en": "The government is hiding something about the lake." },
	"cust_39": { "de": "Ein Fischer hat ein Artefakt gefunden. Er verkauft es nicht.", "en": "A fisherman found an artifact. He won't sell it." },
	"cust_40": { "de": "Hörst du auch manchmal… Stimmen aus dem Wasser?", "en": "Do you also sometimes hear… voices from the water?" },
	
	# Wiederholungskunden
	"cust_41": { "de": "Ich bin wieder da! Der letzte Fisch war perfekt.", "en": "I'm back! The last fish was perfect." },
	"cust_42": { "de": "Du hast mich überzeugt. Was gibt's Neues?", "en": "You convinced me. What's new?" },
	"cust_43": { "de": "Ich vertraue nur dir. Die anderen sind Betrüger.", "en": "I only trust you. The others are frauds." },
	"cust_44": { "de": "Solange du lieferst, bleibe ich Kunde.", "en": "As long as you deliver, I'll stay a customer." },
	"cust_45": { "de": "Deine Preise sind fair. Das schätze ich.", "en": "Your prices are fair. I appreciate that." }
}

@export var change_interval := 5.0    # Zeit zwischen Textwechseln
@export var typewriter_speed := 0.03  # Zeit pro Zeichen

# ------------------------------
#   NODE REFERENCES
# ------------------------------
@onready var dialog_label: RichTextLabel = $Panel/MarginContainer/VBoxContainer/RichTextLabel
@onready var panel: Panel = $Panel

# ------------------------------
#   INTERNAL VARIABLES
# ------------------------------
var timer := 0.0
var typing := false
var current_text := ""
var current_dialog_key := ""  # 🌍 NEU - Speichert den Dialog-Key
var _type_text := ""
var _type_index := 0



func _ready() -> void:
	add_child(type_timer)
	type_timer.one_shot = false
	type_timer.timeout.connect(_on_type_timer_timeout)
	_show_new_random_dialog()



func _process(delta: float) -> void:
	if typing:
		return



# ---------------------------------------------------------------
#  RANDOM DIALOG + TYPEWRITER START (🌍 LOCALIZED)
# ---------------------------------------------------------------
func _show_new_random_dialog():
	if dialog_lines.is_empty():
		return

	# Wähle zufälligen Dialog-Key (Array aus Keys erstellen)
	var keys = dialog_lines.keys()
	current_dialog_key = keys[randi() % keys.size()]
	
	# 🌍 Hole Text in aktueller Sprache
	current_text = _get_localized_text(current_dialog_key)
	
	timer = change_interval
	_start_typewriter(current_text)


# ---------------------------------------------------------------
#  🌍 GET LOCALIZED TEXT
# ---------------------------------------------------------------
func _get_localized_text(dialog_key: String) -> String:
	var dialog_entry = dialog_lines.get(dialog_key, {})
	
	# Hole aktuelle Sprache aus Player (oder TranslationServer)
	var current_language = Player.current_language
	
	# Fallback: Wenn Sprache nicht gefunden, nutze Deutsch
	if dialog_entry.has(current_language):
		return dialog_entry[current_language]
	elif dialog_entry.has("de"):
		return dialog_entry["de"]
	else:
		return "???"


# ---------------------------------------------------------------
#  TYPEWRITER EFFECT
# ---------------------------------------------------------------
func _start_typewriter(text: String) -> void:
	typing = true
	dialog_label.text = ""
	var char_index := 0
	
	while char_index <= text.length():
		# ✅ Prüfe ob Node noch im Tree ist
		if not is_inside_tree() or not typing:
			typing = false
			return
		
		dialog_label.text = text.substr(0, char_index)
		await get_tree().process_frame
		_update_panel_size()
		char_index += 1
		
		# ✅ Nochmal prüfen vor Timer-Erstellung
		if not is_inside_tree():
			typing = false
			return
			
		await get_tree().create_timer(typewriter_speed).timeout

	typing = false



# ---------------------------------------------------------------
#  PANEL HEIGHT AUTO FIT
# ---------------------------------------------------------------
func _update_panel_size() -> void:
	var needed_height := dialog_label.get_content_height()
	panel.custom_minimum_size.y = needed_height + 60  # etwas Padding
	
func _on_type_timer_timeout() -> void:
	# Node wurde entfernt → sofort abbrechen
	if not is_inside_tree():
		type_timer.stop()
		return

	if not typing:
		type_timer.stop()
		return

	if _type_index >= _type_text.length():
		type_timer.stop()
		typing = false
		return

	_type_index += 1
	dialog_label.text = _type_text.substr(0, _type_index)
	_update_panel_size()
