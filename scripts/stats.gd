extends Control

# UI Elements
@onready var close_button: Button = $Panel/CloseButton
@onready var stats_container: VBoxContainer = $Panel/ScrollContainer/StatsContainer
@onready var total_label: Label = $Panel/TotalLabel
@onready var bait_level_label: Label = $Panel/BaitLevelLabel
@onready var title_label: Label = $Panel/TitleLabel

func _ready() -> void:
	print("📊 Stats UI bereit!")
	close_button.pressed.connect(hide)
	visibility_changed.connect(_on_visibility_changed)
	_update_static_labels()
	hide()

func _update_static_labels() -> void:
	# Statische Labels übersetzen
	title_label.text = tr("STATS_TITLE")
	close_button.text = tr("STATS_CLOSE")

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
	bait_level_label.text = tr("STATS_BAIT_LEVEL").format({"level": str(bait_level)})
	
	var spawn_chances := _calculate_spawn_chances(bait_level)
	var catch_stats := _get_catch_statistics()
	
	_create_section_header(tr("STATS_HEADER_SPAWN_CHANCES"))
	
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
		total_label.text = tr("STATS_NO_FISH_YET")
	else:
		total_label.text = tr("STATS_TOTAL_CAUGHT").format({"count": str(total_caught)})
	
	_create_spacer()
	_create_section_header(tr("STATS_HEADER_BIOME_PROGRESS"))
	_create_biome_completion_stats()
	
	_create_spacer()
	_create_section_header(tr("STATS_HEADER_WEIGHT_RECORDS"))
	_create_weight_records()
	
	_create_spacer()
	_create_section_header(tr("STATS_HEADER_MOST_CAUGHT"))
	_create_most_caught_fish()
	
	_create_spacer()
	_create_section_header(tr("STATS_HEADER_BAIT_INVENTORY"))
	_create_bait_inventory()
	
	_create_spacer()
	_create_section_header(tr("STATS_HEADER_UPGRADES"))
	_create_upgrade_status()

func _create_biome_completion_stats() -> void:
	var biome_keys = {
		"lake": "BIOME_LAKE",
		"city": "BIOME_CITY",
		"sewer": "BIOME_SEWER",
		"forest": "BIOME_FOREST",
		"desert": "BIOME_DESERT",
		"iceland": "BIOME_ICELAND"
	}
	
	for biome in Player.completed_biomes.keys():
		var is_complete: bool = Player.completed_biomes[biome]
		var biome_display: String = tr(biome_keys.get(biome, biome.to_upper()))
		var biome_fish_list = Player.get_biome_fish_list(biome)
		var total_fish: int = biome_fish_list.size()
		var caught_fish: int = 0
		
		for fish in biome_fish_list:
			var fish_name = FishDB.get_translated_name(fish) if fish.has("name_key") else fish["name"]
			if Player.caught_fish_species.has(fish_name):
				caught_fish += 1
		
		var progress_text := tr("STATS_BIOME_PROGRESS").format({
			"biome": biome_display,
			"caught": str(caught_fish),
			"total": str(total_fish)
		})
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
		var text := tr("STATS_WEIGHT_ENTRY").format({
			"rank": str(count + 1),
			"name": record["name"],
			"weight": "%.2f" % record["weight"]
		})
		_create_simple_entry(text, Color(1, 0.8, 0.1))
		count += 1
	
	if records.is_empty():
		_create_simple_entry(tr("STATS_NO_RECORDS"), Color.GRAY)

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
		var text := tr("STATS_CAUGHT_ENTRY").format({
			"rank": str(count + 1),
			"name": fish_data["name"],
			"count": str(fish_data["count"])
		})
		_create_simple_entry(text, Color(0.3, 1, 0.3))
		count += 1
	
	if catch_counts.is_empty():
		_create_simple_entry(tr("STATS_NO_CATCHES"), Color.GRAY)

func _create_bait_inventory() -> void:
	var has_baits := false
	
	for rarity in Player.bait_inventory.keys():
		var amount: int = Player.bait_inventory[rarity]
		
		if amount > 0:
			has_baits = true
			var text := tr("STATS_BAIT_AMOUNT").format({
				"rarity": rarity,
				"amount": str(amount)
			})
			var color := _get_rarity_color_by_name(rarity)
			_create_simple_entry(text, color)
	
	if Player.has_active_bait():
		var active_text := tr("STATS_ACTIVE_BAIT").format({"bait": Player.active_bait})
		_create_simple_entry(active_text, Color(1, 1, 0.3))
		has_baits = true
	
	if not has_baits:
		_create_simple_entry(tr("STATS_NO_BAIT"), Color.GRAY)

func _create_upgrade_status() -> void:
	var upgrades = {
		"UPGRADE_GRIP": Player.upgrade_grip,
		"UPGRADE_BAIT": Player.upgrade_bait,
		"UPGRADE_LINE": Player.upgrade_line
	}
	
	for upgrade_key in upgrades.keys():
		var level: int = upgrades[upgrade_key]
		var upgrade_name := tr(upgrade_key)
		var text := tr("STATS_UPGRADE_LEVEL").format({
			"name": upgrade_name,
			"level": str(level)
		})
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
			var current_fish_name = FishDB.get_translated_name(fish) if fish.has("name_key") else fish["name"]
			if current_fish_name == fish_name:
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
	caught_label.text = tr("STATS_CAUGHT").format({"count": str(caught)})
	caught_label.custom_minimum_size = Vector2(180, 0)
	caught_label.add_theme_font_size_override("font_size", 20)
	caught_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	entry.add_child(caught_label)
	
	var chance_label := Label.new()
	chance_label.text = tr("STATS_CHANCE").format({"chance": str(snappedf(chance, 0.1))})
	chance_label.custom_minimum_size = Vector2(200, 0)
	chance_label.add_theme_font_size_override("font_size", 20)
	chance_label.add_theme_color_override("font_color", Color(0.7, 0.9, 1.0))
	chance_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	entry.add_child(chance_label)
	
	stats_container.add_child(entry)
	
	var separator := HSeparator.new()
	stats_container.add_child(separator)
