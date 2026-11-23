extends Node3D

const NumberFormat = preload("res://scripts/NumberFormat.gd")
# LeaderboardDisplay.gd
# Hänge dieses Script an einen Node3D in deiner Hub-Szene

@export var board_position := Vector3(-3.0, 2.0, -2.0)  # Position der Tafel
@export var board_size := Vector2(2.0, 1.5)  # Größe der Tafel
@export var max_entries := 10  # Anzahl der angezeigten Einträge

@export var interaction_distance_open: float = 2.5
@export var full_ui: NodePath  # zeigt auf den LeaderboardFullUI-CanvasLayer

var _player: Node3D = null
var _full_ui_node = null

var leaderboard_ui: SubViewport
var leaderboard_panel: Control
var entries_container: VBoxContainer
var tab_container: TabContainer
var tab_timer: Timer

func _ready():
	print("📊 LeaderboardDisplay startet...")
	
	_create_leaderboard_display()
	Leaderboards.entries_updated.connect(_on_entries_updated)
	Leaderboards.state_changed.connect(_on_state_changed)
	Leaderboards.player_names_updated.connect(_refresh_names)
	_load_leaderboards()
	_start_tab_rotation()
	
	_full_ui_node = get_node_or_null(full_ui)

func _start_tab_rotation():
	tab_timer = Timer.new()
	tab_timer.wait_time = 2.5   # ⏱️ alle 5 Sekunden
	tab_timer.one_shot = false
	tab_timer.autostart = true
	add_child(tab_timer)
	
	tab_timer.timeout.connect(_switch_tab)

func _switch_tab():
	if not tab_container:
		return
	
	var count := tab_container.get_tab_count()
	if count <= 1:
		return
	
	tab_container.current_tab = (tab_container.current_tab + 1) % count

func _create_leaderboard_display():
	# 1. Erstelle SubViewport für UI
	leaderboard_ui = SubViewport.new()
	leaderboard_ui.size = Vector2i(1024, 768)
	leaderboard_ui.transparent_bg = false
	leaderboard_ui.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(leaderboard_ui)
	
	# 2. Erstelle UI Container
	leaderboard_panel = Control.new()
	leaderboard_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	leaderboard_ui.add_child(leaderboard_panel)
	
	# Background
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.1, 0.08, 0.06, 1.0)  # Holz-Farbe
	leaderboard_panel.add_child(bg)
	
	# Titel
	var title = Label.new()
	title.text = tr("LEADERBOARD_TITLE")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7))
	title.position = Vector2(0, 20)
	title.size = Vector2(1024, 80)
	leaderboard_panel.add_child(title)
	
	# Tabs für verschiedene Boards
	tab_container = TabContainer.new()
	tab_container.position = Vector2(50, 120)
	tab_container.size = Vector2(924, 600)
	leaderboard_panel.add_child(tab_container)
	
	# Fish Caught Tab
	var fish_tab = _create_leaderboard_tab(tr("LEADERBOARD_TAB_FISH"), "fish_total")
	tab_container.add_child(fish_tab)
	
	# Money Earned Tab
	var money_tab = _create_leaderboard_tab(tr("LEADERBOARD_TAB_MONEY"), "money_total")
	tab_container.add_child(money_tab)
	
	# 3. Erstelle 3D Mesh für die Tafel
	var board_mesh = QuadMesh.new()
	board_mesh.size = board_size
	
	# Material mit Viewport Texture
	var board_material = StandardMaterial3D.new()
	board_material.albedo_texture = leaderboard_ui.get_texture()
	board_material.emission_enabled = true
	board_material.emission_texture = leaderboard_ui.get_texture()
	board_material.emission_energy_multiplier = 1.5
	
	# MeshInstance3D
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = board_mesh
	mesh_instance.material_override = board_material
	mesh_instance.position = board_position
	add_child(mesh_instance)
	
	print("✅ Leaderboard Display erstellt")

func _create_leaderboard_tab(tab_name: String, leaderboard_name: String) -> ScrollContainer:
	var scroll = ScrollContainer.new()
	scroll.name = tab_name
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 5)
	scroll.add_child(vbox)
	
	# Header
	var header = _create_entry_row("#", tr("LEADERBOARD_HEADER_NAME"), tr("LEADERBOARD_HEADER_SCORE"), true)
	vbox.add_child(header)
	
	# Separator
	var separator = ColorRect.new()
	separator.custom_minimum_size = Vector2(0, 2)
	separator.color = Color(0.9, 0.85, 0.7, 0.5)
	vbox.add_child(separator)
	
	# Placeholder Einträge
	for i in range(max_entries):
		var entry = _create_entry_row(
			str(i + 1),
			tr("LEADERBOARD_WAITING_STEAM"),
			"---"
		)
		entry.name = "Entry_" + str(i)
		vbox.add_child(entry)
	
	# Speichere Referenz zum Aktualisieren
	scroll.set_meta("leaderboard_name", leaderboard_name)
	scroll.set_meta("entries_container", vbox)
	
	return scroll

func _create_entry_row(rank: String, name: String, score: String, is_header: bool = false) -> HBoxContainer:
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 20)
	
	var font_size = 24 if is_header else 20
	var color = Color(0.9, 0.85, 0.7) if is_header else Color(0.8, 0.75, 0.6)
	
	# Rank
	var rank_label = Label.new()
	rank_label.text = rank
	rank_label.custom_minimum_size = Vector2(60, 0)
	rank_label.add_theme_font_size_override("font_size", font_size)
	rank_label.add_theme_color_override("font_color", color)
	row.add_child(rank_label)
	
	# Name
	var name_label = Label.new()
	name_label.text = name
	name_label.custom_minimum_size = Vector2(400, 0)
	name_label.add_theme_font_size_override("font_size", font_size)
	name_label.add_theme_color_override("font_color", color)
	row.add_child(name_label)
	
	# Score
	var score_label = Label.new()
	score_label.text = score
	score_label.custom_minimum_size = Vector2(200, 0)
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	score_label.add_theme_font_size_override("font_size", font_size)
	score_label.add_theme_color_override("font_color", color)
	row.add_child(score_label)
	
	return row

func _load_leaderboards(force := false) -> void:
	for board: String in GodotSteam.LEADERBOARD_NAMES:
		_render_board(board)
		Leaderboards.request_board(board, Steam.LEADERBOARD_DATA_REQUEST_GLOBAL, force, max_entries)

func _on_entries_updated(board: String, mode: int, _entries: Array) -> void:
	if mode == Steam.LEADERBOARD_DATA_REQUEST_GLOBAL:
		_render_board(board)

func _on_state_changed(board: String, mode: int, _message_key: String) -> void:
	if mode == Steam.LEADERBOARD_DATA_REQUEST_GLOBAL:
		_render_board(board)

func _refresh_names() -> void:
	for board: String in GodotSteam.LEADERBOARD_NAMES:
		_render_board(board)

func _render_board(board: String) -> void:
	for tab in tab_container.get_children():
		if tab.get_meta("leaderboard_name") != board:
			continue
		var container: VBoxContainer = tab.get_meta("entries_container")
		var mode := Steam.LEADERBOARD_DATA_REQUEST_GLOBAL
		if Leaderboards.has_cached(board, mode):
			var entries := Leaderboards.get_entries(board, mode)
			_update_entries(container, entries)
			if entries.is_empty():
				container.get_child(2).get_child(1).text = tr("LEADERBOARD_NO_ENTRIES")
		else:
			_update_entries(container, [])
			container.get_child(2).get_child(1).text = tr(Leaderboards.get_state(board, mode))
		return

func _update_entries(container: VBoxContainer, entries: Array):
	if not container:
		print("❌ Container ist null!")
		return
	
	# Hole alle Entry-Nodes (überspringe Header + Separator)
	var all_children = container.get_children()
	
	# Die ersten 2 sind Header + Separator
	var entry_nodes = all_children.slice(2)

	for i in range(entry_nodes.size()):
		var entry_node = entry_nodes[i]
		var labels = entry_node.get_children()
		
		if labels.size() < 3:
			print("⚠️ Entry", i, "hat zu wenige Labels:", labels.size())
			continue

		if i < entries.size():
			var data = entries[i]
			var rank = data.get("global_rank", i + 1)
			var score = data.get("score", 0)
			var steam_id = data.get("steam_id", 0)
			var player_name = Leaderboards.player_name(steam_id)

			labels[0].text = NumberFormat.compact(rank)
			labels[1].text = player_name
			labels[2].text = NumberFormat.compact(score)
			
			# Eigenen Eintrag highlighten
			var row_color = Color(1.0, 0.8, 0.2) if steam_id == GodotSteam.steam_id else Color(0.8, 0.75, 0.6)
			for label in labels:
				label.add_theme_color_override("font_color", row_color)
		else:
			labels[0].text = str(i + 1)
			labels[1].text = "---"
			labels[2].text = "---"
			for label in labels:
				label.add_theme_color_override("font_color", Color(0.8, 0.75, 0.6))

func refresh_leaderboards() -> void:
	_load_leaderboards(true)

func open_full_ui() -> void:
	if _full_ui_node and not _full_ui_node.visible:
		_full_ui_node.open()
