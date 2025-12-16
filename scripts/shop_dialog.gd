extends Control

# ------------------------------
#   EXPORT VARIABLES
# ------------------------------
@export var dialog_lines := {
	"dlg_01": { "de": "Ich habe das Gefühl, dass heute etwas Großes anbeißt.", "en": "I have a feeling something big will bite today." },
	"dlg_02": { "de": "Wenn du pleite bist, tu zumindest so als wärst du reich.", "en": "If you're broke, at least pretend you're rich." },
	"dlg_03": { "de": "Manche Fische verkaufen sich besser als deine Zukunft.", "en": "Some fish sell better than your future." },
	"dlg_04": { "de": "Ich würde selbst angeln, aber ich habe Rücken… und Stolz.", "en": "I'd fish myself, but I have a bad back… and pride." },
	"dlg_05": { "de": "Die Stadt stinkt, aber das Geld hier riecht fantastisch.", "en": "The city stinks, but the money here smells fantastic." },
	"dlg_06": { "de": "Köder sind wie Beziehungen: Je teurer, desto besser.", "en": "Bait is like relationships: the more expensive, the better." },
	"dlg_07": { "de": "Pass auf deine Finger auf, ein Fisch hat sie schon vermisst.", "en": "Watch your fingers, a fish already misses them." },
	"dlg_08": { "de": "Wenn du das kaufst, tu so als wär es kein Fehlkauf.", "en": "If you buy this, pretend it wasn't a bad decision." },
	"dlg_09": { "de": "Ich habe gehört, im Wald verschwinden gerade Leute.", "en": "I heard people have been disappearing in the forest." },
	"dlg_10": { "de": "Die Wüste brennt, aber mein Angebot ist eiskalt billig.", "en": "The desert burns, but my offer is ice-cold cheap." },

	"dlg_11": { "de": "Wenn du mich anlächelst, mache ich den Preis nicht günstiger.", "en": "If you smile at me, I still won't lower the price." },
	"dlg_12": { "de": "Fische lügen nicht. Menschen schon. Rate, wer mehr kauft.", "en": "Fish don't lie. People do. Guess who buys more." },
	"dlg_13": { "de": "Ich habe ein gutes Gefühl bei deinem nächsten Fang.", "en": "I have a good feeling about your next catch." },
	"dlg_14": { "de": "Wenn du zu viel fragst, erhöhe ich die Preise sofort.", "en": "Ask too many questions and I raise the prices instantly." },
	"dlg_15": { "de": "Ich hatte heute schon drei Kunden. Zwei waren tot.", "en": "I've already had three customers today. Two were dead." },
	"dlg_16": { "de": "Man sagt, ein alter Geist beobachtet jeden deiner Käufe.", "en": "They say an old spirit watches every purchase you make." },
	"dlg_17": { "de": "Der letzte Kunde wollte Rabatt. Er ist jetzt verschwunden.", "en": "The last customer asked for a discount. He's gone now." },
	"dlg_18": { "de": "Willkommen zurück! Ich wusste, du kommst wieder… irgendwann.", "en": "Welcome back! I knew you'd return… eventually." },
	"dlg_19": { "de": "Wenn du seltene Fische willst, hör auf schwach zu sein.", "en": "If you want rare fish, stop being weak." },
	"dlg_20": { "de": "Je besser der Köder, desto weniger musst du weinen.", "en": "The better the bait, the less you'll cry." },

	"dlg_21": { "de": "Ich verkaufe nur Qualität. Oder Müll. Schwer zu unterscheiden.", "en": "I sell only quality. Or trash. Hard to tell." },
	"dlg_22": { "de": "Fische aus der Kanalisation? Ja, die leben wirklich noch.", "en": "Fish from the sewers? Yes, they're actually still alive." },
	"dlg_23": { "de": "Die alten Artefakte machen mir ein bisschen Angst.", "en": "The ancient artifacts scare me a little." },
	"dlg_24": { "de": "Ich bete, dass du mehr kaufst. Für dich. Und für mich.", "en": "I pray you buy more. For you. And for me." },
	"dlg_25": { "de": "Ein Blick in dein Inventar lässt mich immer schmunzeln.", "en": "One look at your inventory always makes me smile." },
	"dlg_26": { "de": "Wenn du sparen willst, geh angeln. Wenn du gewinnen willst, kauf.", "en": "If you want to save money, go fishing. If you want to win, buy." },
	"dlg_27": { "de": "Ich hatte mal Träume. Dann wurde ich Shopkeeper.", "en": "I used to have dreams. Then I became a shopkeeper." },
	"dlg_28": { "de": "Falls du schreist, hören die Fische dich lachen.", "en": "If you scream, the fish will hear you laughing." },
	"dlg_29": { "de": "Es gibt Gerüchte über ein neues Biom im Norden.", "en": "There are rumors about a new biome in the north." },
	"dlg_30": { "de": "Du siehst motiviert aus! Oder müde. Schwer zu sagen.", "en": "You look motivated! Or tired. Hard to tell." },

	"dlg_31": { "de": "Ich habe die Preise gesenkt. Also eigentlich nicht.", "en": "I lowered the prices. Well, not really." },
	"dlg_32": { "de": "Seltene Fische mögen dich. Aus irgendeinem Grund.", "en": "Rare fish seem to like you. For some reason." },
	"dlg_33": { "de": "Wenn du ein Geräusch hörst, ignoriere es einfach.", "en": "If you hear a noise, just ignore it." },
	"dlg_34": { "de": "Die Legenden sagen: 'Mehr Köder, mehr Glück'.", "en": "The legends say: 'More bait, more luck'." },
	"dlg_35": { "de": "Ich würde dir helfen, aber dann wäre ich arbeitslos.", "en": "I'd help you, but then I'd be unemployed." },
	"dlg_36": { "de": "Fang du die Fische, ich nehme das Geld. Gute Aufteilung.", "en": "You catch the fish, I take the money. Fair deal." },
	"dlg_37": { "de": "Ich habe heute ein seltsames Leuchten am See gesehen.", "en": "I saw a strange glow at the lake today." },
	"dlg_38": { "de": "Pass auf, manche Köder ziehen… Dinge an. Nicht nur Fische.", "en": "Careful, some bait attracts… things. Not just fish." },
	"dlg_39": { "de": "Wenn du mutig bist, probier mal den teuren Köder.", "en": "If you're brave, try the expensive bait." },
	"dlg_40": { "de": "Die anderen Händler reden schlecht über dich. Ich nicht.", "en": "The other merchants talk badly about you. Not me." },
	"dlg_41": { "de": "Ich bin stolz auf dich. Ein bisschen. Nicht übertreiben.", "en": "I'm proud of you. A little. Don't overdo it." }
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


func _ready() -> void:
	_show_new_random_dialog()


func _process(delta: float) -> void:
	if typing:
		return

	timer -= delta
	if timer <= 0:
		_show_new_random_dialog()


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

		# Wenn ein Klick typwriter abbricht → sofort Loop verlassen
		if not typing:
			return

		dialog_label.text = text.substr(0, char_index)
		await get_tree().process_frame
		_update_panel_size()

		char_index += 1
		await get_tree().create_timer(typewriter_speed).timeout

	typing = false


func _on_Panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:

		# 1) Wenn gerade geschrieben wird → Typing abbrechen & Text sofort vollständig anzeigen
		if typing:
			typing = false
			dialog_label.text = current_text
			_update_panel_size()
			return

		# 2) Wenn NICHT geschrieben wird → neuen Dialog starten
		_show_new_random_dialog()


# ---------------------------------------------------------------
#  PANEL HEIGHT AUTO FIT
# ---------------------------------------------------------------
func _update_panel_size() -> void:
	var needed_height := dialog_label.get_content_height()
	panel.custom_minimum_size.y = needed_height + 60  # etwas Padding
