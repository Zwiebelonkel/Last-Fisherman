extends Node3D

# Aquarium Einstellungen
@export var aquarium_size := Vector3(10, 6, 5)  # Breite, Höhe, Tiefe
@export var fish_scale := 0.4  # Größe der 2D-Sprites
@export var spawn_padding := 1.0  # Abstand zu Wänden
@export var max_fish := 50  # Maximum Anzahl Fische (Performance)

# Spawn-Bereich
var min_bounds: Vector3
var max_bounds: Vector3

# Alle aktiven Fische im Aquarium
var active_fish: Dictionary = {}  # {"FischID": Sprite3D_Node}

func _ready() -> void:
	# Berechne Grenzen
	min_bounds = -aquarium_size / 2 + Vector3.ONE * spawn_padding
	max_bounds = aquarium_size / 2 - Vector3.ONE * spawn_padding
	
	# Verbinde Player-Signal
	Player.fish_caught.connect(_on_fish_caught)
	
	# Spawne alle bereits gefangenen Fische
	spawn_all_caught_fish()
	
	print("🐠 Aquarium initialisiert mit %d Fischen" % active_fish.size())

func spawn_all_caught_fish() -> void:
	# ✅ FIX: Player.caught_fish_species speichert jetzt IDs statt Namen
	for fish_id in Player.caught_fish_species.keys():
		if Player.caught_fish_species[fish_id]:
			spawn_fish_by_id(fish_id)

# ✅ FIX: Umbenennung von spawn_fish_by_name zu spawn_fish_by_id
func spawn_fish_by_id(fish_id: String) -> void:
	# Prüfe ob Fisch bereits im Aquarium ist
	if active_fish.has(fish_id):
		var fish_name := _get_display_name_for_id(fish_id)
		print("🐟 %s ist bereits im Aquarium" % fish_name)
		return
	
	# Prüfe Maximum
	if active_fish.size() >= max_fish:
		print("⚠️ Aquarium voll! Maximum %d Fische erreicht" % max_fish)
		return
	
	# ✅ FIX: Hole Fisch-Daten via ID
	var fish_data := FishDB.get_fish_by_id(fish_id)
	if fish_data.is_empty():
		print("⚠️ Fisch nicht gefunden für ID:", fish_id)
		return
	
	spawn_fish(fish_data)

# ✅ HELPER: Hole Display-Namen für Logging
func _get_display_name_for_id(fish_id: String) -> String:
	var fish_data := FishDB.get_fish_by_id(fish_id)
	if fish_data.is_empty():
		return fish_id
	return FishDB.get_fish_name(fish_data)

func spawn_fish(fish_data: Dictionary) -> void:
	# ✅ FIX: Hole ID statt Name
	var fish_id: String = fish_data.get("id", "")
	if fish_id == "":
		print("⚠️ Fish ohne ID kann nicht gespawnt werden")
		return
	
	# Erstelle Sprite3D
	var fish_sprite = Sprite3D.new()
	fish_sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	fish_sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	fish_sprite.pixel_size = 0.01
	fish_sprite.shaded = false  # Keine 3D-Beleuchtung
	
	# ✅ FIX: Icon über FishDB.get_fish_icon()
	fish_sprite.texture = FishDB.get_fish_icon(fish_data)
	
	# 🎨 Größe basierend auf Rarity
	var rarity = fish_data.get("rarity", FishDB.RARITY.NORMAL)
	var size_multiplier = get_size_for_rarity(rarity)
	fish_sprite.scale = Vector3.ONE * fish_scale * size_multiplier
	
	# 🎨 Farb-Modulation für Rarity
	var rarity_color = FishDB.get_rarity_color(fish_data)
	fish_sprite.modulate = rarity_color.lerp(Color.WHITE, 0.5)  # 50% Mix mit Weiß
	
	# Zufällige Startposition
	fish_sprite.position = get_random_position()
	
	# Script hinzufügen für Bewegung
	var script = load("res://scripts/AquariumFish.gd")
	if script:
		fish_sprite.set_script(script)
		
		# ✅ FIX: Bewegungsparameter setzen mit ID und Display-Namen
		fish_sprite.set("target_position", get_random_position())
		fish_sprite.set("movement_speed", randf_range(0.3, 1.5))
		fish_sprite.set("min_bounds", min_bounds)
		fish_sprite.set("max_bounds", max_bounds)
		fish_sprite.set("fish_id", fish_id)  # ✅ Speichere ID
		fish_sprite.set("fish_display_name", FishDB.get_fish_name(fish_data))  # ✅ Display
		fish_sprite.set("rarity", rarity)
	
	# 💡 Licht für seltene Fische
	if rarity >= FishDB.RARITY.LEGENDAER:
		var light = OmniLight3D.new()
		light.light_color = rarity_color
		light.light_energy = 1.5
		light.omni_range = 1.5
		light.omni_attenuation = 2.0
		fish_sprite.add_child(light)
	
	# Zur Scene hinzufügen
	add_child(fish_sprite)
	active_fish[fish_id] = fish_sprite
	
	# ✅ FIX: Logging mit Display-Namen
	var fish_name := FishDB.get_fish_name(fish_data)
	var rarity_key := FishDB.get_rarity_name_key(fish_data)
	print("🐟 Spawned: %s (Rarity: %s)" % [fish_name, tr(rarity_key)])

func get_size_for_rarity(rarity: int) -> float:
	match rarity:
		FishDB.RARITY.NORMAL:
			return 0.7
		FishDB.RARITY.UNGEWOEHNLICH:
			return 0.85
		FishDB.RARITY.SELTEN:
			return 1.0
		FishDB.RARITY.EPISCH:
			return 1.2
		FishDB.RARITY.LEGENDAER:
			return 1.5
		FishDB.RARITY.EXOTISCH:
			return 1.8
		FishDB.RARITY.ANTIK:
			return 2.0
	return 1.0

func get_random_position() -> Vector3:
	return Vector3(
		randf_range(min_bounds.x, max_bounds.x),
		randf_range(min_bounds.y, max_bounds.y),
		randf_range(min_bounds.z, max_bounds.z)
	)

# 🆕 Wird aufgerufen wenn neuer Fisch gefangen wurde
# ✅ FIX: Parameter ist jetzt fish_id
func _on_fish_caught(fish_id: String) -> void:
	var fish_name := _get_display_name_for_id(fish_id)
	print("🎣 Aquarium: Neuer Fisch gefangen:", fish_name)
	spawn_fish_by_id(fish_id)
