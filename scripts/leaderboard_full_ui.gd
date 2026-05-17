extends Control
# LeaderboardFullUI.gd
# CanvasLayer mit layer = 10 o.ä., standardmäßig visible = false

signal closed

enum FilterMode { GLOBAL, FRIENDS }

var current_filter := FilterMode.GLOBAL
var cached_data := {}  # leaderboard_name -> Array of entries
var current_leaderboard := "fish_total"
var tab_container: TabContainer
var entries_boxes := {}  # leaderboard_name -> VBoxContainer

func _ready() -> void:
	visible = false
	_build_ui()
	
	if not Steam.leaderboard_scores_downloaded.is_connected(_on_downloaded):
		Steam.leaderboard_scores_downloaded.connect(_on_downloaded)

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE or event.keycode == KEY_TAB:
			close()
			get_viewport().set_input_as_handled()

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
	panel.add_child(vbox)

	# --- Titel + Close ---
	var title_row = HBoxContainer.new()
	vbox.add_child(title_row)

	var title = Label.new()
	title.text = "LEADERBOARDS"
	title.add_theme_font_size_override("font_size", 32)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(title)

	var close_btn = Button.new()
	close_btn.text = "✕  Close"
	close_btn.pressed.connect(close)
	title_row.add_child(close_btn)

	# --- Filter Buttons ---
	var filter_row = HBoxContainer.new()
	filter_row.add_theme_constant_override("separation", 6)
	vbox.add_child(filter_row)

	var global_btn = Button.new()
	global_btn.text = "🌍 Global"
	global_btn.toggle_mode = true
	global_btn.button_pressed = true
	global_btn.name = "GlobalBtn"
	global_btn.pressed.connect(func():
		current_filter = FilterMode.GLOBAL
		_refresh_current_tab()
		_request_current(Steam.LEADERBOARD_DATA_REQUEST_GLOBAL)
	)
	filter_row.add_child(global_btn)

	var friends_btn = Button.new()
	friends_btn.text = "👥 Friends"
	friends_btn.toggle_mode = true
	friends_btn.name = "FriendsBtn"
	friends_btn.pressed.connect(func():
		current_filter = FilterMode.FRIENDS
		_refresh_current_tab()
		_request_current(Steam.LEADERBOARD_DATA_REQUEST_FRIENDS)
	)
	filter_row.add_child(friends_btn)

	var around_btn = Button.new()
	around_btn.text = "📍 Around Me"
	around_btn.toggle_mode = true
	around_btn.name = "AroundBtn"
	around_btn.pressed.connect(func():
		current_filter = FilterMode.GLOBAL
		_request_current(Steam.LEADERBOARD_DATA_REQUEST_GLOBAL_AROUND_USER)
	)
	filter_row.add_child(around_btn)

	var refresh_btn = Button.new()
	refresh_btn.text = "🔄 Refresh"
	refresh_btn.pressed.connect(func(): _request_current(Steam.LEADERBOARD_DATA_REQUEST_GLOBAL))
	filter_row.add_child(refresh_btn)

	# --- Tabs ---
	tab_container = TabContainer.new()
	tab_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tab_container.tab_changed.connect(_on_tab_changed)
	vbox.add_child(tab_container)

	for lb in [["Most Fish Caught", "fish_total"], ["Most Money Earned", "money_total"]]:
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
	vbox.add_child(_make_row("#", "Player", "Score", true))

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
	_request_current(Steam.LEADERBOARD_DATA_REQUEST_GLOBAL)

func close() -> void:
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	emit_signal("closed")

# -------------------------
# Steam requests
# -------------------------
func _request_current(mode: int) -> void:
	var tab = tab_container.get_current_tab_control()
	if not tab:
		return
	var lb_name: String = tab.get_meta("lb_name")
	current_leaderboard = lb_name
	_request(lb_name, mode)

func _request(lb_name: String, mode: int) -> void:
	if not GodotSteam.leaderboards.has(lb_name):
		return
	var handle = GodotSteam.leaderboards[lb_name]
	Steam.downloadLeaderboardEntries(0, 9, mode, handle)

func _on_tab_changed(_idx: int) -> void:
	_request_current(Steam.LEADERBOARD_DATA_REQUEST_GLOBAL)

# -------------------------
# Steam callback
# -------------------------
func _on_downloaded(a, b = null, c = null) -> void:
	if not visible:
		return

	var handle := -1
	var results: Array = []

	for v in [a, b, c]:
		if v is int and handle == -1:
			handle = v
		elif v is Array:
			results = v
		elif v is Dictionary:
			if v.has("leaderboard"): handle = int(v["leaderboard"])
			if v.has("results"):    results = v["results"]

	if handle <= 0 or results.is_empty():
		return

	var lb_name := Steam.getLeaderboardName(handle)
	cached_data[lb_name] = results
	_populate(lb_name, results)

func _refresh_current_tab() -> void:
	var lb_name = current_leaderboard
	if cached_data.has(lb_name):
		_populate(lb_name, cached_data[lb_name])

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
			var pname = Steam.getFriendPersonaName(sid) if sid != 0 else "Unknown"
			labels[0].text = str(d.get("global_rank", i + 1))
			labels[1].text = pname
			labels[2].text = str(d.get("score", 0))

			var is_me = sid == GodotSteam.steam_id
			var col = Color(1.0, 0.8, 0.2) if is_me else Color(0.85, 0.82, 0.75)
			for lbl in labels:
				lbl.add_theme_color_override("font_color", col)
		else:
			labels[0].text = str(i + 1)
			labels[1].text = "—"
			labels[2].text = "—"
