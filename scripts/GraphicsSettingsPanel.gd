extends Panel

signal back_requested

const TEXT := {
	"fishing_line_segments": {"de": "Schnursegmente", "en": "Fishing line segments", "ru": "Сегменты лески", "tr": "Misina segmentleri", "es": "Segmentos del sedal", "fr": "Segments du fil de pêche", "pl": "Segmenty żyłki"},
	"description": {"de": "Wähle ein Profil oder passe einzelne Details an. Änderungen werden sofort gespeichert.", "en": "Choose a preset or adjust individual details. Changes are saved immediately.", "ru": "Выберите профиль или настройте параметры. Изменения сохраняются сразу.", "tr": "Bir profil seç veya ayrıntıları ayarla. Değişiklikler hemen kaydedilir.", "es": "Elige un perfil o ajusta cada detalle. Los cambios se guardan al instante.", "fr": "Choisis un profil ou ajuste les détails. Les modifications sont enregistrées immédiatement.", "pl": "Wybierz profil lub dostosuj szczegóły. Zmiany są zapisywane od razu."},
	"preset": {"de": "Qualitätsprofil", "en": "Quality preset", "ru": "Профиль качества", "tr": "Kalite profili", "es": "Perfil de calidad", "fr": "Profil de qualité", "pl": "Profil jakości"},
	"economy": {"de": "Schwache Geräte", "en": "Low-end devices", "ru": "Слабые устройства", "tr": "Düşük donanım", "es": "Equipos modestos", "fr": "Appareils peu puissants", "pl": "Słabsze urządzenia"},
	"balanced": {"de": "Ausgewogen", "en": "Balanced", "ru": "Сбалансированный", "tr": "Dengeli", "es": "Equilibrado", "fr": "Équilibré", "pl": "Zrównoważony"},
	"custom": {"de": "Benutzerdefiniert", "en": "Custom", "ru": "Свой", "tr": "Özel", "es": "Personalizado", "fr": "Personnalisé", "pl": "Niestandardowy"},
	"shadow_quality": {"de": "Schattenqualität", "en": "Shadow quality", "ru": "Качество теней", "tr": "Gölge kalitesi", "es": "Calidad de sombras", "fr": "Qualité des ombres", "pl": "Jakość cieni"},
	"texture_quality": {"de": "3D-Texturauflösung", "en": "3D texture resolution", "ru": "Разрешение 3D-текстур", "tr": "3B doku çözünürlüğü", "es": "Resolución de texturas 3D", "fr": "Résolution des textures 3D", "pl": "Rozdzielczość tekstur 3D"},
	"water_quality": {"de": "Wasserqualität", "en": "Water quality", "ru": "Качество воды", "tr": "Su kalitesi", "es": "Calidad del agua", "fr": "Qualité de l'eau", "pl": "Jakość wody"},
	"particle_quality": {"de": "Partikeldichte", "en": "Particle density", "ru": "Плотность частиц", "tr": "Parçacık yoğunluğu", "es": "Densidad de partículas", "fr": "Densité des particules", "pl": "Gęstość cząsteczek"},
	"view_distance": {"de": "Sichtweite", "en": "View distance", "ru": "Дальность прорисовки", "tr": "Görüş mesafesi", "es": "Distancia de visión", "fr": "Distance d'affichage", "pl": "Zasięg widzenia"},
	"short": {"de": "Kurz", "en": "Short", "ru": "Малая", "tr": "Kısa", "es": "Corta", "fr": "Courte", "pl": "Krótki"},
	"normal": {"de": "Normal", "en": "Normal", "ru": "Средняя", "tr": "Normal", "es": "Normal", "fr": "Normale", "pl": "Normalny"},
	"full": {"de": "Voll", "en": "Full", "ru": "Полная", "tr": "Tam", "es": "Completa", "fr": "Complète", "pl": "Pełny"},
	"tablet_blur_enabled": {"de": "Tablet-Hintergrundunschärfe", "en": "Tablet background blur", "ru": "Размытие фона планшета", "tr": "Tablet arka plan bulanıklığı", "es": "Desenfoque del fondo de la tableta", "fr": "Flou d'arrière-plan de la tablette", "pl": "Rozmycie tła tabletu"},
}

const PRESETS := [
	{"resolution_scale": 0.5, "frame_limit": 30, "shadow_quality": 0, "texture_quality": 2, "water_quality": 0, "particle_quality": 0, "view_distance": 0, "fog_quality": 0, "godray_enabled": false, "glow_enabled": false, "tablet_blur_enabled": false},
	{"resolution_scale": 0.75, "frame_limit": 60, "shadow_quality": 1, "texture_quality": 1, "water_quality": 1, "particle_quality": 1, "view_distance": 1, "fog_quality": 1, "godray_enabled": false, "glow_enabled": false, "tablet_blur_enabled": true},
	{"resolution_scale": 1.0, "frame_limit": 0, "shadow_quality": 3, "texture_quality": 0, "water_quality": 2, "particle_quality": 2, "view_distance": 2, "fog_quality": 3, "godray_enabled": true, "glow_enabled": true, "tablet_blur_enabled": true},
]

const SELECT_VALUES := {
	"resolution_scale": [1.0, 0.75, 0.5, 0.25],
	"frame_limit": [0, 120, 60, 30],
	"shadow_quality": [0, 1, 2, 3],
	"texture_quality": [0, 1, 2],
	"water_quality": [0, 1, 2],
	"particle_quality": [0, 1, 2],
	"view_distance": [0, 1, 2],
	"fog_quality": [0, 1, 2, 3],
}

@onready var rows: VBoxContainer = $Margin/Content/Scroll/Rows
@onready var preset_control: OptionButton = $Margin/Content/PresetRow/Preset
var controls: Dictionary = {}
var labels: Dictionary = {}
var segment_value: Label


func _ready() -> void:
	for key: String in SELECT_VALUES:
		_add_control(key, false)
	_add_segment_control()
	for key: String in ["godray_enabled", "glow_enabled", "tablet_blur_enabled"]:
		_add_control(key, true)
	preset_control.item_selected.connect(_apply_preset)
	$Margin/Content/Back.pressed.connect(func() -> void: back_requested.emit())
	get_viewport().size_changed.connect(_fit_panel)
	_fit_panel()
	refresh_controls()


func _fit_panel() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	size = Vector2(minf(800.0, viewport_size.x - 32.0), minf(720.0, viewport_size.y - 32.0))
	position = (viewport_size - size) * 0.5


func _text(key: String) -> String:
	if TEXT.has(key):
		return TEXT[key].get(Player.current_language, TEXT[key]["en"])
	var existing := {"resolution_scale": "3DSCALE", "frame_limit": "FRAMELIMIT", "fog_quality": "FOG QUALITY", "godray_enabled": "GODRAY ENABLED", "glow_enabled": "GLOW ENABLED"}
	return tr(existing.get(key, key))


func _add_control(key: String, toggle: bool) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	rows.add_child(row)
	var label := Label.new()
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	row.add_child(label)
	labels[key] = label
	var control: Control
	if toggle:
		var button := CheckButton.new()
		button.toggled.connect(func(value: bool) -> void: _set_value(key, value))
		control = button
	else:
		var button := OptionButton.new()
		button.item_selected.connect(func(index: int) -> void: _set_value(key, SELECT_VALUES[key][index]))
		control = button
	control.name = key
	control.custom_minimum_size = Vector2(210, 30)
	row.add_child(control)
	controls[key] = control


func _add_segment_control() -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	rows.add_child(row)
	var label := Label.new()
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	row.add_child(label)
	labels["fishing_line_segments"] = label
	var slider := HSlider.new()
	slider.name = "fishing_line_segments"
	slider.min_value = 24
	slider.max_value = 192
	slider.step = 12
	slider.custom_minimum_size = Vector2(154, 30)
	slider.value_changed.connect(func(value: float) -> void: _set_value("fishing_line_segments", int(value)))
	row.add_child(slider)
	segment_value = Label.new()
	segment_value.custom_minimum_size.x = 44
	segment_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(segment_value)
	controls["fishing_line_segments"] = slider


func _choices(key: String) -> Array:
	match key:
		"resolution_scale": return ["100 %", "75 %", "50 %", "25 %"]
		"frame_limit": return [tr("unlimited"), "120 FPS", "60 FPS", "30 FPS"]
		"texture_quality": return ["100 %", "50 %", "25 %"]
		"view_distance": return [_text("short"), _text("normal"), _text("full")]
		"shadow_quality", "fog_quality": return [tr("off"), tr("low"), tr("medium"), tr("high")]
	return [tr("low"), tr("medium"), tr("high")]


func refresh_controls() -> void:
	$Margin/Content/Title.text = tr("GRAPHICS")
	$Margin/Content/Description.text = _text("description")
	$Margin/Content/PresetRow/Label.text = _text("preset")
	$Margin/Content/Back.text = tr("BACK")
	preset_control.clear()
	for title: String in [_text("economy"), _text("balanced"), tr("high"), _text("custom")]:
		preset_control.add_item(title)
	preset_control.set_item_disabled(3, true)
	var selected := 3
	for index in range(PRESETS.size()):
		var matches := true
		for key: String in PRESETS[index]:
			if Player.get(key) != PRESETS[index][key]:
				matches = false
		if matches:
			selected = index
	preset_control.select(selected)
	for key: String in controls:
		labels[key].text = _text(key)
		var control: Control = controls[key]
		if control is HSlider:
			control.set_value_no_signal(Player.fishing_line_segments)
			segment_value.text = str(Player.fishing_line_segments)
		elif control is CheckButton:
			control.set_pressed_no_signal(Player.get(key))
		else:
			var option := control as OptionButton
			option.clear()
			for title: String in _choices(key):
				option.add_item(title)
			option.select(maxi(0, SELECT_VALUES[key].find(Player.get(key))))


func _set_value(key: String, value: Variant) -> void:
	Player.set(key, value)
	Player.apply_graphics_settings()
	Player.save_settings()
	refresh_controls()


func _apply_preset(index: int) -> void:
	if index < 0 or index >= PRESETS.size():
		return
	for key: String in PRESETS[index]:
		Player.set(key, PRESETS[index][key])
	Player.apply_graphics_settings()
	Player.save_settings()
	refresh_controls()
