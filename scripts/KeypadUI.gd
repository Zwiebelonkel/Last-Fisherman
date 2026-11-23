extends CanvasLayer

signal digit_pressed(digit: String)
signal erase_pressed
signal clear_pressed
signal submitted
signal close_requested

const TEXT := {
	"title": {"de": "ZUGANGSCODE", "en": "ACCESS CODE", "ru": "КОД ДОСТУПА", "tr": "ERİŞİM KODU", "es": "CÓDIGO DE ACCESO", "fr": "CODE D'ACCÈS", "pl": "KOD DOSTĘPU"},
	"subtitle": {"de": "Gib den Code am Tastenfeld ein.", "en": "Enter the code on the keypad.", "ru": "Введи код на клавиатуре.", "tr": "Tuş takımından kodu gir.", "es": "Introduce el código en el teclado.", "fr": "Saisis le code sur le clavier.", "pl": "Wpisz kod na klawiaturze."},
	"ready": {"de": "Bereit zur Eingabe", "en": "Ready for input", "ru": "Готово к вводу", "tr": "Girişe hazır", "es": "Listo para introducir", "fr": "Prêt pour la saisie", "pl": "Gotowe do wpisania kodu"},
	"incomplete": {"de": "Bitte alle %d Ziffern eingeben.", "en": "Please enter all %d digits.", "ru": "Введи все %d цифр.", "tr": "Lütfen %d rakamın tamamını gir.", "es": "Introduce los %d dígitos.", "fr": "Saisis les %d chiffres.", "pl": "Wpisz wszystkie cyfry (%d)."},
	"incorrect": {"de": "Falscher Code. Versuche es erneut.", "en": "Incorrect code. Try again.", "ru": "Неверный код. Попробуй ещё раз.", "tr": "Yanlış kod. Tekrar dene.", "es": "Código incorrecto. Inténtalo de nuevo.", "fr": "Code incorrect. Réessaie.", "pl": "Nieprawidłowy kod. Spróbuj ponownie."},
	"correct": {"de": "Code akzeptiert. Zugang wird geöffnet...", "en": "Code accepted. Opening access...", "ru": "Код принят. Доступ открывается...", "tr": "Kod kabul edildi. Erişim açılıyor...", "es": "Código aceptado. Abriendo acceso...", "fr": "Code accepté. Ouverture de l'accès…", "pl": "Kod przyjęty. Otwieranie dostępu…"},
	"secret": {"de": "Geheimcode akzeptiert...", "en": "Secret code accepted...", "ru": "Секретный код принят...", "tr": "Gizli kod kabul edildi...", "es": "Código secreto aceptado...", "fr": "Code secret accepté…", "pl": "Tajny kod przyjęty…"},
	"confirm": {"de": "BESTÄTIGEN  [ENTER]", "en": "CONFIRM  [ENTER]", "ru": "ПОДТВЕРДИТЬ  [ENTER]", "tr": "ONAYLA  [ENTER]", "es": "CONFIRMAR  [ENTER]", "fr": "CONFIRMER  [ENTRÉE]", "pl": "POTWIERDŹ  [ENTER]"},
	"clear": {"de": "LEEREN", "en": "CLEAR", "ru": "ОЧИСТИТЬ", "tr": "TEMİZLE", "es": "VACIAR", "fr": "EFFACER", "pl": "WYCZYŚĆ"},
	"erase": {"de": "LÖSCHEN", "en": "DELETE", "ru": "СТЕРЕТЬ", "tr": "SİL", "es": "BORRAR", "fr": "SUPPRIMER", "pl": "USUŃ"},
	"close": {"de": "SCHLIESSEN  [ESC]", "en": "CLOSE  [ESC]", "ru": "ЗАКРЫТЬ  [ESC]", "tr": "KAPAT  [ESC]", "es": "CERRAR  [ESC]", "fr": "FERMER  [ÉCHAP]", "pl": "ZAMKNIJ  [ESC]"},
	"hint": {"de": "0–9  Eingabe   /   Rücktaste  Löschen", "en": "0–9  Type   /   Backspace  Delete", "ru": "0–9  Ввод   /   Backspace  Стереть", "tr": "0–9  Giriş   /   Geri Silme  Sil", "es": "0–9  Introducir   /   Retroceso  Borrar", "fr": "0–9  Saisir   /   Retour arrière  Supprimer", "pl": "0–9  Wpisz   /   Backspace  Usuń"},
	"prompt": {"de": "E  Tastenfeld benutzen", "en": "E  Use keypad", "ru": "E  Использовать клавиатуру", "tr": "E  Tuş takımını kullan", "es": "E  Usar teclado", "fr": "E  Utiliser le clavier", "pl": "E  Użyj klawiatury"},
}

@onready var title_label: Label = %Title
@onready var panel: PanelContainer = %Panel
@onready var subtitle_label: Label = %Subtitle
@onready var display_label: Label = %CodeDisplay
@onready var status_label: Label = %Status
@onready var keys: GridContainer = %Keys
@onready var confirm_button: Button = %ConfirmButton
@onready var close_button: Button = %CloseButton
@onready var clear_button: Button = %ClearButton
@onready var erase_button: Button = %EraseButton
@onready var hint_label: Label = %Hint

var is_open := false
var _was_paused := false
var _previous_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_CAPTURED
var _digit_count := 4

func _ready() -> void:
	hide()
	get_viewport().size_changed.connect(_fit_panel)
	panel.resized.connect(_fit_panel)
	for child in keys.get_children():
		var button := child as Button
		if button != null and button.has_meta("digit"):
			button.pressed.connect(func(): digit_pressed.emit(str(button.get_meta("digit"))))
	clear_button.pressed.connect(func(): clear_pressed.emit())
	erase_button.pressed.connect(func(): erase_pressed.emit())
	confirm_button.pressed.connect(func(): submitted.emit())
	close_button.pressed.connect(func(): close_requested.emit())
	_fit_panel.call_deferred()

func _fit_panel() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	var panel_size := panel.get_combined_minimum_size()
	panel.size = panel_size
	panel.pivot_offset = panel_size * 0.5
	var ratio := minf(1.0, minf((viewport_size.x - 32.0) / panel_size.x, (viewport_size.y - 32.0) / panel_size.y))
	panel.scale = Vector2.ONE * maxf(ratio, 0.1)
	panel.position = (viewport_size - panel_size) * 0.5

static func text_for(key: String) -> String:
	var language: String = Player.current_language
	return TEXT[key].get(language, TEXT[key]["de"])

func open_ui(digit_count: int) -> void:
	if is_open:
		return
	_digit_count = digit_count
	title_label.text = text_for("title")
	subtitle_label.text = text_for("subtitle")
	confirm_button.text = text_for("confirm")
	close_button.text = text_for("close")
	clear_button.text = text_for("clear")
	erase_button.text = text_for("erase")
	hint_label.text = text_for("hint")
	_was_paused = get_tree().paused
	_previous_mouse_mode = Input.mouse_mode
	is_open = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	show()
	set_code("")
	set_feedback("ready")
	set_busy(false)

func close_ui() -> void:
	if not is_open:
		return
	is_open = false
	hide()
	get_tree().paused = _was_paused
	Input.mouse_mode = _previous_mouse_mode

func _exit_tree() -> void:
	if is_open:
		get_tree().paused = _was_paused
		Input.mouse_mode = _previous_mouse_mode

func set_code(value: String) -> void:
	var digits: PackedStringArray = []
	for i in range(_digit_count):
		digits.append(value[i] if i < value.length() else "_")
	display_label.text = "  ".join(digits)

func set_feedback(key: String) -> void:
	status_label.text = text_for(key) % _digit_count if key == "incomplete" else text_for(key)
	status_label.modulate = Color("ef9b83") if key in ["incorrect", "incomplete"] else Color("a1cbaa")

func set_busy(busy: bool) -> void:
	for child in keys.get_children():
		if child is Button:
			child.disabled = busy
	confirm_button.disabled = busy

func _input(event: InputEvent) -> void:
	if not is_open or not event is InputEventKey:
		return
	get_viewport().set_input_as_handled()
	var key := event as InputEventKey
	var code: Key = key.keycode if key.keycode != KEY_NONE else key.physical_keycode
	# Close on release so the same Escape cannot open the player's pause menu.
	if code == KEY_ESCAPE:
		if not key.pressed:
			close_requested.emit()
		return
	if not key.pressed or key.echo or confirm_button.disabled:
		return
	if code >= KEY_0 and code <= KEY_9:
		digit_pressed.emit(str(code - KEY_0))
	elif code >= KEY_KP_0 and code <= KEY_KP_9:
		digit_pressed.emit(str(code - KEY_KP_0))
	elif code == KEY_BACKSPACE:
		erase_pressed.emit()
	elif code == KEY_DELETE:
		clear_pressed.emit()
	elif code in [KEY_ENTER, KEY_KP_ENTER]:
		submitted.emit()
