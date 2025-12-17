extends Control

# UI Elements
@onready var close_button: Button = $Panel/CloseButton
@onready var stats_container: VBoxContainer = $Panel/ScrollContainer/StatsContainer
@onready var total_label: Label = $Panel/TotalLabel
@onready var bait_level_label: Label = $Panel/BaitLevelLabel

func _ready() -> void:
	print("📊 Stats UI bereit!")
	close_button.pressed.connect(hide)
	visibility_changed.connect(_on_visibility_changed)
	hide()

func _on_visibility_changed() -> void:
	if visible:
		update_stats()

func show_stats() -> void:
	update_stats()
	show()

func update_stats() -> void:
	for child in stats_container.get_children():
		child.queue_free()
	
	var bait_level := Player.upgrade_bait
	bait_level_label.text = "Köder Level: " + str(bait_level)
	
	var spawn_chances := _calculate_spawn_chances(bait_level)
	var catch_stats := _get_catch_statistics()
	
	_create_section_header("📊 SPAWN-CHANCEN & FÄNGE")
	
	var total_caught := 0
	
	for rarity in FishDB.RARITY_DATA.keys():
		var rarity_data = FishDB.RARITY_DATA[rarity]
		var rarity_name: String = rarity_data["name"]
		var rarity_color: Color = rarity_data["color"]
		var caught_count: int = catch_stats.get(rarity, 0)
		var spawn_chance: float = spawn_chances.get(rarity, 0.0)
		
		total_caught += caught_count
		_create_stat_entry(rarity_name, rarity_color, caught_count, spawn_chance)
	
	if total_caught == 0:
		total_label.text = "Noch keine Fische gefangen - Los geht's! 🎣"
	else:
		total_label.text = "Insgesamt gefangen: " + str(total_caught) + " Fische"
	
	_create_spacer()
	_create_section_header("🗺️ BIOM-FORTSCHRITT")
	_create_biome_completion_stats()
	
	_create_spacer()
	_create_section_header("🏆 GEWICHTSREKORDE (Top 5)")
	_create_weight_records()
	
	_create_spacer()
	_create_section_header("🎣 MEISTGEFANGENE FISCHE (Top 5)")
	_create_most_caught_fish()
	
	_create_spacer()
	_create_section_header("🪝 KÖDER-INVENTAR")
	_create_bait_inventory()
	
	_create_spacer()
	_create_section_header("⚙️ UPGRADES")
	_create_upgrade_status()

func _create_biome_completion_stats() -> void:
	var biome_names = {
		"lake": "🌊 See",
		"city": "🏙️ Stadt",
		"sewer": "🚽 Kanalisation",
		"forest": "🌲 Wald",
		"desert": "🏜️ Wüste",
		"iceland": "🧊 Island"
	}
	
	for biome in Player.completed_biomes.keys():
		var is_complete: bool = Player.completed_biomes[biome]
		var biome_display: String = biome_names.get(biome, biome.capitalize())
		var biome_fish_list = Player.get_biome_fish_list(biome)
		var total_fish: int = biome_fish_list.size()
		var caught_fish: int = 0
		
		for fish in biome_fish_list:
			if Player.caught_fish_species.has(fish["name"]):
				caught_fish += 1
		
		var progress_text := "%s: %d/%d" % [biome_display, caught_fish, total_fish]
		var status_icon := "✅" if is_complete else "⏳"
		var color := Color.GREEN if is_complete else Color.GRAY
		
		_create_simple_entry(status_icon + " " + progress_text, color)

func _create_weight_records() -> void:
	var records: Array = []
	
	for fish_name in Player.fish_weight_records.keys():
		records.append({
			"name": fish_name,
			"weight": Player.fish_weight_records[fish_name]
		})
	
	records.sort_custom(func(a, b): return a["weight"] > b["weight"])
	
	var count := 0
	for record in records:
		if count >= 5:
			break
		var text := "%d. %s: %.2f kg" % [count + 1, record["name"], record["weight"]]
		_create_simple_entry(text, Color(1, 0.8, 0.1))
		count += 1
	
	if records.is_empty():
		_create_simple_entry("Noch keine Rekorde", Color.GRAY)

func _create_most_caught_fish() -> void:
	var catch_counts: Array = []
	
	for fish_name in Player.fish_catch_count.keys():
		catch_counts.append({
			"name": fish_name,
			"count": Player.fish_catch_count[fish_name]
		})
	
	catch_counts.sort_custom(func(a, b): return a["count"] > b["count"])
	
	var count := 0
	for fish_data in catch_counts:
		if count >= 5:
			break
		var text := "%d. %s: %dx gefangen" % [count + 1, fish_data["name"], fish_data["count"]]
		_create_simple_entry(text, Color(0.3, 1, 0.3))
		count += 1
	
	if catch_counts.is_empty():
		_create_simple_entry("Noch keine Fänge", Color.GRAY)

func _create_bait_inventory() -> void:
	var has_baits := false
	
	for rarity in Player.bait_inventory.keys():
		var amount: int = Player.bait_inventory[rarity]
		
		if amount > 0:
			has_baits = true
			var text := "%s Köder: %d Stück" % [rarity, amount]
			var color := _get_rarity_color_by_name(rarity)
			_create_simple_entry(text, color)
	
	if Player.has_active_bait():
		var active_text := "🎣 AKTIV: %s Köder" % Player.active_bait
		_create_simple_entry(active_text, Color(1, 1, 0.3))
		has_baits = true
	
	if not has_baits:
		_create_simple_entry("Kein Köder vorhanden", Color.GRAY)

func _create_upgrade_status() -> void:
	var upgrades = {
		"⚡ Grip": Player.upgrade_grip,
		"🎣 Köder": Player.upgrade_bait,
		"🪢 Leine": Player.upgrade_line
	}
	
	for upgrade_name in upgrades.keys():
		var level: int = upgrades[upgrade_name]
		var text := "%s: Level %d" % [upgrade_name, level]
		_create_simple_entry(text, Color(0.7, 0.9, 1.0))

func _get_rarity_color_by_name(rarity_name: String) -> Color:
	var rarity_map = {
		"Uncommon": FishDB.RARITY.UNGEWOEHNLICH,
		"Rare": FishDB.RARITY.SELTEN,
		"Epic": FishDB.RARITY.EPISCH,
		"Legendary": FishDB.RARITY.LEGENDAER,
		"Exotic": FishDB.RARITY.EXOTISCH
	}
	
	var rarity_enum = rarity_map.get(rarity_name, FishDB.RARITY.NORMAL)
	return FishDB.RARITY_DATA[rarity_enum]["color"]

func _create_section_header(title: String) -> void:
	var header := Label.new()
	header.text = title
	header.add_theme_font_size_override("font_size", 26)
	header.add_theme_color_override("font_color", Color(1, 0.8, 0.1))
	header.custom_minimum_size = Vector2(0, 40)
	header.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	stats_container.add_child(header)
	
	var separator := HSeparator.new()
	separator.custom_minimum_size = Vector2(0, 3)
	stats_container.add_child(separator)

func _create_spacer() -> void:
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 30)
	stats_container.add_child(spacer)

func _create_simple_entry(text: String, color: Color) -> void:
	var label := Label.new()
	label.text = "  • " + text
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", color)
	label.custom_minimum_size = Vector2(0, 30)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	stats_container.add_child(label)

func _calculate_spawn_chances(bait_level: int) -> Dictionary:
	var rarity_weights: Dictionary = {}
	
	for rarity in FishDB.RARITY_DATA.keys():
		var base_spawn: float = FishDB.RARITY_DATA[rarity]["spawn_chance"]
		var boosted_spawn: float = FishDB._calculate_rarity_boost(base_spawn, rarity, bait_level)
		rarity_weights[rarity] = boosted_spawn
	
	var total_weight: float = FishDB._sum_weights(rarity_weights)
	var percentages: Dictionary = {}
	
	for rarity in rarity_weights.keys():
		percentages[rarity] = (rarity_weights[rarity] / total_weight) * 100.0
	
	return percentages

func _get_catch_statistics() -> Dictionary:
	var stats: Dictionary = {}
	
	for rarity in FishDB.RARITY_DATA.keys():
		stats[rarity] = 0
	
	for fish_name in Player.fish_catch_count.keys():
		var count = Player.fish_catch_count[fish_name]
		var biome := Player.get_fish_biome(fish_name)
		if biome == "":
			continue
		
		var fish_list := Player.get_biome_fish_list(biome)
		for fish in fish_list:
			if fish["name"] == fish_name:
				var rarity: int = fish["rarity"]
				stats[rarity] = stats.get(rarity, 0) + count
				break
	
	return stats

func _create_stat_entry(rarity_name: String, rarity_color: Color, caught: int, chance: float) -> void:
	var entry := HBoxContainer.new()
	entry.custom_minimum_size = Vector2(0, 50)
	
	var color_box := ColorRect.new()
	color_box.color = rarity_color
	color_box.custom_minimum_size = Vector2(15, 50)
	entry.add_child(color_box)
	
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(20, 0)
	entry.add_child(spacer)
	
	var name_label := Label.new()
	name_label.text = rarity_name
	name_label.custom_minimum_size = Vector2(180, 0)
	name_label.add_theme_font_size_override("font_size", 22)
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	entry.add_child(name_label)
	
	var caught_label := Label.new()
	caught_label.text = "Gefangen: " + str(caught)
	caught_label.custom_minimum_size = Vector2(180, 0)
	caught_label.add_theme_font_size_override("font_size", 20)
	caught_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	entry.add_child(caught_label)
	
	var chance_label := Label.new()
	chance_label.text = "Chance: " + str(snappedf(chance, 0.1)) + "%"
	chance_label.custom_minimum_size = Vector2(200, 0)
	chance_label.add_theme_font_size_override("font_size", 20)
	chance_label.add_theme_color_override("font_color", Color(0.7, 0.9, 1.0))
	chance_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	entry.add_child(chance_label)
	
	stats_container.add_child(entry)
	
	var separator := HSeparator.new()
	stats_container.add_child(separator)
