extends Node3D
# LeaderboardDisplay.gd
# Hänge dieses Script an einen Node3D in deiner Hub-Szene

@export var board_position := Vector3(-3.0, 2.0, -2.0)  # Position der Tafel
@export var board_size := Vector2(2.0, 1.5)  # Größe der Tafel
@export var max_entries := 10  # Anzahl der angezeigten Einträge

var leaderboard_ui: SubViewport
var leaderboard_panel: Control
var entries_container: VBoxContainer
var tab_container: TabContainer
var tab_timer: Timer

func _ready():
	print("📊 LeaderboardDisplay startet...")
	
	# ✅ SIGNAL VOR ALLEM ANDEREN
	if not Steam.leaderboard_scores_downloaded.is_connected(_on_leaderboard_downloaded):
		Steam.leaderboard_scores_downloaded.connect(_on_leaderboard_downloaded)

	await get_tree().process_frame
	_create_leaderboard_display()
	_wait_for_steam_and_load()
	_start_tab_rotation()

# 🔧 NEU: Warte auf Steam Initialisierung
func _wait_for_steam_and_load() -> void:
	print("⏳ Warte auf GodotSteam Initialisierung...")
	
	# Prüfe ob Steam bereits bereit ist
	if GodotSteam.initialization_complete and GodotSteam.leaderboards.size() >= GodotSteam.expected_leaderboards:
		print("✅ Steam bereits bereit!")
		_load_leaderboards()
		return
	
	# Wenn nicht, warte auf das Signal
	if not GodotSteam.leaderboards_loaded.is_connected(_on_steam_ready):
		GodotSteam.leaderboards_loaded.connect(_on_steam_ready)
	
	print("⏳ Warte auf leaderboards_loaded Signal...")

func _on_steam_ready() -> void:
	print("✅ Steam Signal empfangen - lade Leaderboards...")
	await get_tree().create_timer(0.2).timeout  # Kurze Pause für Stabilität
	_load_leaderboards()

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
	title.text = "LEADERBOARDS"
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
	var fish_tab = _create_leaderboard_tab("Most Fish Caught", "fish_total")
	tab_container.add_child(fish_tab)
	
	# Money Earned Tab
	var money_tab = _create_leaderboard_tab("Most Money Earned", "money_total")
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
	var header = _create_entry_row("#", "Name", "Score", true)
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
			"Waiting for Steam...",
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

func _load_leaderboards():
	print("🔍 _load_leaderboards() gestartet")
	
	if not GodotSteam.steam_ready:
		print("⚠️ Steam nicht bereit - kann Leaderboards nicht laden")
		return
	
	if GodotSteam.leaderboards.is_empty():
		print("⚠️ Keine Leaderboards verfügbar")
		return
	
	print("📋 Verfügbare Leaderboards:", GodotSteam.leaderboards.keys())
	
	# Lade beide Leaderboards
	_request_leaderboard_data("fish_total")
	await get_tree().create_timer(0.5).timeout
	_request_leaderboard_data("money_total")

func _request_leaderboard_data(leaderboard_name: String):
	if not GodotSteam.leaderboards.has(leaderboard_name):
		print("⚠️ Leaderboard nicht verfügbar:", leaderboard_name)
		return
	
	var handle = GodotSteam.leaderboards[leaderboard_name]
	
	print("📥 Requesting leaderboard data:", leaderboard_name, "| Handle:", handle)
	
	Steam.downloadLeaderboardEntries(
	0,                          # start_index
	max_entries - 1,            # end_index
	Steam.LEADERBOARD_DATA_REQUEST_GLOBAL,
	handle                       # leaderboard_handle
	)


func _on_leaderboard_downloaded(a, b = null, c = null) -> void:
	var leaderboard_handle := -1
	var results: Array = []

	# 🔍 Parameter analysieren
	for v in [a, b, c]:
		if v is int and leaderboard_handle == -1:
			leaderboard_handle = v
		elif v is Array:
			results = v
		elif v is Dictionary:
			# manche Versionen packen alles in ein Dict
			if v.has("leaderboard"):
				leaderboard_handle = int(v["leaderboard"])
			if v.has("results"):
				results = v["results"]

	if leaderboard_handle <= 0:
		print("❌ Kein gültiger Leaderboard-Handle:", a, b, c)
		return

	if results.is_empty():
		print("ℹ️ Keine Leaderboard-Daten")
		return

	var leaderboard_name := Steam.getLeaderboardName(leaderboard_handle)
	print("🏆 Leaderboard geladen:", leaderboard_name, " Einträge:", results.size())

	# Debug-Ausgabe
	for i in range(results.size()):
		var r = results[i]
		print("%02d | #%d | %s | %d" % [
			i + 1,
			r.get("global_rank", i + 1),
			Steam.getFriendPersonaName(r["steam_id"]),
			r.get("score", 0)
		])

	# UI aktualisieren
	for tab in tab_container.get_children():
		if tab.get_meta("leaderboard_name") == leaderboard_name:
			_update_entries(tab.get_meta("entries_container"), results)
			break

func _apply_rows_to_tabs(leaderboard_name: String, rows: Array) -> void:
	if rows.is_empty():
		print("ℹ️ Keine Daten:", leaderboard_name)
		return

	for tab in tab_container.get_children():
		if tab.get_meta("leaderboard_name") == leaderboard_name:
			_update_entries(tab.get_meta("entries_container"), rows)
			break

func _show_empty_state(container: VBoxContainer):
	var entry_nodes = container.get_children().slice(2)
	
	for i in range(entry_nodes.size()):
		var entry_node = entry_nodes[i]
		var labels = entry_node.get_children()
		labels[0].text = str(i + 1)
		labels[1].text = "No entries yet"
		labels[2].text = "---"
	
	print("ℹ️ Empty state angezeigt")

func _update_entries(container: VBoxContainer, entries: Array):
	var entry_nodes = container.get_children().slice(2)

	for i in range(entry_nodes.size()):
		var entry_node = entry_nodes[i]
		var labels = entry_node.get_children()

		if i < entries.size():
			var data = entries[i]
			var rank = data.get("global_rank", i + 1)
			var score = data.get("score", 0)
			var steam_id = data.get("steam_id", 0)
			var player_name = Steam.getFriendPersonaName(steam_id) if steam_id != 0 else "Unknown"

			labels[0].text = str(rank)
			labels[1].text = player_name
			labels[2].text = str(score)

			# Eigenen Eintrag highlighten
			if steam_id == GodotSteam.steam_id:
				for label in labels:
					label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2))
		else:
			labels[0].text = str(i + 1)
			labels[1].text = "---"
			labels[2].text = "---"

	print("✅ Leaderboard aktualisiert mit", entries.size(), "Einträgen")

func refresh_leaderboards():
	"""Manueller Refresh - kann von außen aufgerufen werden"""
	if GodotSteam.initialization_complete:
		_load_leaderboards()
	else:
		print("⚠️ Steam noch nicht bereit für Refresh")
