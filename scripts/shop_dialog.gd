extends Control

# ------------------------------
#   EXPORT VARIABLES
# ------------------------------
@export var dialog_lines: Array[String] = [
	"Ich habe das Gefühl, dass heute etwas Großes anbeißt.",
	"Wenn du pleite bist, tu zumindest so als wärst du reich.",
	"Manche Fische verkaufen sich besser als deine Zukunft.",
	"Ich würde selbst angeln, aber ich habe Rücken… und Stolz.",
	"Die Stadt stinkt, aber das Geld hier riecht fantastisch.",
	"Köder sind wie Beziehungen: Je teurer, desto besser.",
	"Pass auf deine Finger auf, ein Fisch hat sie schon vermisst.",
	"Wenn du das kaufst, tu so als wär es kein Fehlkauf.",
	"Ich habe gehört, im Wald verschwinden gerade Leute.",
	"Die Wüste brennt, aber mein Angebot ist eiskalt billig.",
	"Wenn du mich anlächelst, mache ich den Preis nicht günstiger.",
	"Fische lügen nicht. Menschen schon. Rate, wer mehr kauft.",
	"Ich habe ein gutes Gefühl bei deinem nächsten Fang.",
	"Wenn du zu viel fragst, erhöhe ich die Preise sofort.",
	"Ich hatte heute schon drei Kunden. Zwei waren tot.",
	"Man sagt, ein alter Geist beobachtet jeden deiner Käufe.",
	"Der letzte Kunde wollte Rabatt. Er ist jetzt verschwunden.",
	"Willkommen zurück! Ich wusste, du kommst wieder… irgendwann.",
	"Wenn du seltene Fische willst, hör auf schwach zu sein.",
	"Je besser der Köder, desto weniger musst du weinen.",
	"Ich verkaufe nur Qualität. Oder Müll. Schwer zu unterscheiden.",
	"Fische aus der Kanalisation? Ja, die leben wirklich noch.",
	"Die alten Artefakte machen mir ein bisschen Angst.",
	"Ich bete, dass du mehr kaufst. Für dich. Und für mich.",
	"Ein Blick in dein Inventar lässt mich immer schmunzeln.",
	"Wenn du sparen willst, geh angeln. Wenn du gewinnen willst, kauf.",
	"Ich hatte mal Träume. Dann wurde ich Shopkeeper.",
	"Falls du schreist, hören die Fische dich lachen.",
	"Es gibt Gerüchte über ein neues Biom im Norden.",
	"Du siehst motiviert aus! Oder müde. Schwer zu sagen.",
	"Ich habe die Preise gesenkt. Also eigentlich nicht.",
	"Seltene Fische mögen dich. Aus irgendeinem Grund.",
	"Wenn du ein Geräusch hörst, ignoriere es einfach.",
	"Die Legenden sagen: ‘Mehr Köder, mehr Glück’.",
	"Ich würde dir helfen, aber dann wäre ich arbeitslos.",
	"Fang du die Fische, ich nehme das Geld. Gute Aufteilung.",
	"Ich habe heute ein seltsames Leuchten am See gesehen.",
	"Pass auf, manche Köder ziehen… Dinge an. Nicht nur Fische.",
	"Wenn du mutig bist, probier mal den teuren Köder.",
	"Die anderen Händler reden schlecht über dich. Ich nicht.",
	"Ich bin stolz auf dich. Ein bisschen. Nicht übertreiben."
]


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


func _ready() -> void:
	_show_new_random_dialog()


func _process(delta: float) -> void:
	if typing:
		return

	timer -= delta
	if timer <= 0:
		_show_new_random_dialog()


# ---------------------------------------------------------------
#  RANDOM DIALOG + TYPEWRITER START
# ---------------------------------------------------------------
func _show_new_random_dialog():
	if dialog_lines.is_empty():
		return

	current_text = dialog_lines.pick_random()
	timer = change_interval
	_start_typewriter(current_text)


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
