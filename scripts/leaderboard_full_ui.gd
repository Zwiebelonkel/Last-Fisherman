extends Control

const NumberFormat = preload("res://scripts/NumberFormat.gd")
# LeaderboardFullUI.gd
# CanvasLayer mit layer = 10 o.ä., standardmäßig visible = false

signal closed

enum FilterMode { GLOBAL, FRIENDS }

var current_filter := FilterMode.GLOBAL
var current_leaderboard := "fish_total"
var current_request_mode := -1
var tab_container: TabContainer
var entries_boxes := {}  # leaderboard_name -> VBoxContainer
var global_btn: Button
var friends_btn: Button
var around_btn: Button
var _closing_key: int = KEY_NONE

func _ready() -> void:
	# Die Szene hatte den Leaderboard-Root nur als 40x40-Control in der Mitte
	# gespeichert. Dadurch wurden Overlay und Layout geclippt/falsch platziert.
	# Das Fullscreen-Popup erzwingt seine Größe daher beim Start selbst.
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	_build_ui()
	
	Leaderboards.entries_updated.connect(_on_entries_updated)
	Leaderboards.state_changed.connect(_on_state_changed)
	Leaderboards.player_names_updated.connect(_refresh_names)

func _input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key != null:
		var code: int = key.physical_keycode if key.physical_keycode != KEY_NONE else key.keycode
		if _closing_key != KEY_NONE and code == _closing_key:
			get_viewport().set_input_as_handled()
			if not key.pressed:
				_closing_key = KEY_NONE
			return
	if not visible:
		return
	if not _is_close_shortcut(event):
		return

	_closing_key = key.physical_keycode if key.physical_keycode != KEY_NONE else key.keycode
	get_viewport().set_input_as_handled()
	close()

func _is_close_shortcut(event: InputEvent) -> bool:
	var key_event := event as InputEventKey
	if not key_event or not key_event.pressed or key_event.echo:
		return false

	return (
		key_event.keycode == KEY_ESCAPE
		or key_event.physical_keycode == KEY_ESCAPE
		or key_event.keycode == KEY_TAB
		or key_event.physical_keycode == KEY_TAB
		or event.is_action_pressed("ui_cancel")
		or event.is_action_pressed("pause")
	)

# -------------------------
# UI aufbauen
# -------------------------
func _build_ui() -> void:
	# Dim overlay
	var overlay = ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.75)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	# Panel
	var panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(900, 620)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.set_anchor(SIDE_LEFT, 0.5)
	panel.set_anchor(SIDE_TOP, 0.5)
	panel.set_anchor(SIDE_RIGHT, 0.5)
	panel.set_anchor(SIDE_BOTTOM, 0.5)
	panel.set_offset(SIDE_LEFT, -450)
	panel.set_offset(SIDE_TOP, -310)
	panel.set_offset(SIDE_RIGHT, 450)
	panel.set_offset(SIDE_BOTTOM, 310)
	add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(vbox)

	# --- Titel + Close ---
	var title_row = HBoxContainer.new()
	vbox.add_child(title_row)

	var title = Label.new()
	title.text = tr("LEADERBOARD_TITLE")
	title.add_theme_font_size_override("font_size", 32)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(title)

	var close_btn = Button.new()
	close_btn.text = "✕  " + tr("LEADERBOARD_CLOSE")
	close_btn.pressed.connect(close)
	title_row.add_child(close_btn)

	# --- Filter Buttons ---
	var filter_row = HBoxContainer.new()
	filter_row.add_theme_constant_override("separation", 6)
	vbox.add_child(filter_row)

	global_btn = Button.new()
	global_btn.text = "🌍 " + tr("LEADERBOARD_GLOBAL")
	global_btn.toggle_mode = true
	global_btn.button_pressed = true
	global_btn.name = "GlobalBtn"
	global_btn.pressed.connect(func():
		_select_filter(global_btn)
		current_filter = FilterMode.GLOBAL
		_request_current(Steam.LEADERBOARD_DATA_REQUEST_GLOBAL)
	)
	filter_row.add_child(global_btn)

	friends_btn = Button.new()
	friends_btn.text = "👥 " + tr("LEADERBOARD_FRIENDS")
	friends_btn.toggle_mode = true
	friends_btn.name = "FriendsBtn"
	friends_btn.pressed.connect(func():
		_select_filter(friends_btn)
		current_filter = FilterMode.FRIENDS
		_request_current(Steam.LEADERBOARD_DATA_REQUEST_FRIENDS)
	)
	filter_row.add_child(friends_btn)

	around_btn = Button.new()
	around_btn.text = "📍 " + tr("LEADERBOARD_AROUND_ME")
	around_btn.toggle_mode = true
	around_btn.name = "AroundBtn"
	around_btn.pressed.connect(func():
		_select_filter(around_btn)
		current_filter = FilterMode.GLOBAL
		_request_current(Steam.LEADERBOARD_DATA_REQUEST_GLOBAL_AROUND_USER)
	)
	filter_row.add_child(around_btn)

	var refresh_btn = Button.new()
	refresh_btn.text = tr("LEADERBOARD_REFRESH")
	refresh_btn.pressed.connect(func():
		var mode := current_request_mode
		if mode == -1:
			mode = Steam.LEADERBOARD_DATA_REQUEST_GLOBAL
		_request_current(mode, true)
	)
	filter_row.add_child(refresh_btn)

	# --- Tabs ---
	tab_container = TabContainer.new()
	tab_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tab_container.tab_changed.connect(_on_tab_changed)
	vbox.add_child(tab_container)

	for lb in [[tr("LEADERBOARD_TAB_FISH"), "fish_total"], [tr("LEADERBOARD_TAB_MONEY"), "money_total"]]:
		var scroll = _build_tab(lb[0], lb[1])
		tab_container.add_child(scroll)

func _build_tab(tab_name: String, lb_name: String) -> ScrollContainer:
	var scroll = ScrollContainer.new()
	scroll.name = tab_name
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(vbox)

	# Header
	vbox.add_child(_make_row("#", tr("LEADERBOARD_HEADER_PLAYER"), tr("LEADERBOARD_HEADER_SCORE"), true))

	var sep = ColorRect.new()
	sep.custom_minimum_size = Vector2(0, 1)
	sep.color = Color(0.6, 0.6, 0.6, 0.4)
	vbox.add_child(sep)

	# 10 leere Zeilen
	for i in range(10):
		var row = _make_row(str(i + 1), "—", "—")
		row.name = "Row_%d" % i
		vbox.add_child(row)

	scroll.set_meta("lb_name", lb_name)
	entries_boxes[lb_name] = vbox
	return scroll

func _make_row(rank: String, name: String, score: String, header := false) -> HBoxContainer:
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)

	var fs = 20 if header else 17
	var col = Color(1, 0.95, 0.8) if header else Color(0.85, 0.82, 0.75)

	for pair in [[rank, 50], [name, 500], [score, 160]]:
		var lbl = Label.new()
		lbl.text = pair[0]
		lbl.custom_minimum_size = Vector2(pair[1], 0)
		lbl.add_theme_font_size_override("font_size", fs)
		lbl.add_theme_color_override("font_color", col)
		if pair[1] == 160:
			lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(lbl)

	return row

# -------------------------
# Öffnen / Schließen
# -------------------------
func open() -> void:
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_select_filter(global_btn)
	current_filter = FilterMode.GLOBAL
	_request_current(Steam.LEADERBOARD_DATA_REQUEST_GLOBAL)

func close() -> void:
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	emit_signal("closed")

# -------------------------
# Steam requests
# -------------------------
func _request_current(mode: int, force := false) -> void:
	var tab = tab_container.get_current_tab_control()
	if not tab:
		return
	var lb_name: String = tab.get_meta("lb_name")
	current_leaderboard = lb_name
	current_request_mode = mode

	_render_current()
	Leaderboards.request_board(lb_name, mode, force)

func _on_tab_changed(_idx: int) -> void:
	if visible:
		_request_current(current_request_mode if current_request_mode != -1 else Steam.LEADERBOARD_DATA_REQUEST_GLOBAL)

func _on_entries_updated(board: String, mode: int, _entries: Array) -> void:
	if visible and board == current_leaderboard and mode == current_request_mode:
		_render_current()

func _on_state_changed(board: String, mode: int, _message_key: String) -> void:
	if visible and board == current_leaderboard and mode == current_request_mode:
		_render_current()

func _refresh_names() -> void:
	if visible:
		_render_current()

func _render_current() -> void:
	if Leaderboards.has_cached(current_leaderboard, current_request_mode):
		var entries := Leaderboards.get_entries(current_leaderboard, current_request_mode)
		if entries.is_empty():
			_show_message(current_leaderboard, tr("LEADERBOARD_NO_ENTRIES"))
		else:
			_populate(current_leaderboard, entries)
	else:
		_show_message(current_leaderboard, tr(Leaderboards.get_state(current_leaderboard, current_request_mode)))

func _select_filter(active_button: Button) -> void:
	for button in [global_btn, friends_btn, around_btn]:
		if button:
			button.button_pressed = button == active_button

func _show_message(lb_name: String, message: String) -> void:
	if not entries_boxes.has(lb_name):
		return

	var vbox: VBoxContainer = entries_boxes[lb_name]
	var rows = vbox.get_children().slice(2)
	for i in range(rows.size()):
		var labels = rows[i].get_children()
		if labels.size() < 3:
			continue
		labels[0].text = str(i + 1) if i == 0 else ""
		labels[1].text = message if i == 0 else ""
		labels[2].text = ""
		for lbl in labels:
			lbl.add_theme_color_override("font_color", Color(0.85, 0.82, 0.75))

func _populate(lb_name: String, entries: Array) -> void:
	if not entries_boxes.has(lb_name):
		return

	var vbox: VBoxContainer = entries_boxes[lb_name]
	var rows = vbox.get_children().slice(2)  # skip header + separator

	for i in range(rows.size()):
		var labels = rows[i].get_children()
		if labels.size() < 3:
			continue

		if i < entries.size():
			var d = entries[i]
			var sid = d.get("steam_id", 0)
			var pname = Leaderboards.player_name(sid)
			labels[0].text = NumberFormat.compact(d.get("global_rank", i + 1))
			labels[1].text = pname
			labels[2].text = NumberFormat.compact(d.get("score", 0))

			var is_me = sid == GodotSteam.steam_id
			var col = Color(1.0, 0.8, 0.2) if is_me else Color(0.85, 0.82, 0.75)
			for lbl in labels:
				lbl.add_theme_color_override("font_color", col)
		else:
			labels[0].text = str(i + 1)
			labels[1].text = "—"
			labels[2].text = "—"
			for lbl in labels:
				lbl.add_theme_color_override("font_color", Color(0.85, 0.82, 0.75))
