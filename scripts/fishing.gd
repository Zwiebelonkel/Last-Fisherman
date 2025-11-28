extends Node3D

# NODE-REFERENCES
@export var rod_tip: Node3D
@export var hook: Node3D
@export var splash: GPUParticles3D
@export var waterplane: Node3D
@export var catch_result_ui: Node
@export var rotation_speed: float = 2.0
@export var camera: Camera3D
@export var fishing_location: String = "forest"  # 🔧 Hier Biom einstellen!
@export var fishbook_ui: Control
@export var options: Control
@export var story_event_panel: Control  # 🆕 Story Event UI
@export var explosion: Node3D

# UI Buttons
@export var journal_button: Button
@export var inventory_button: Button
@export var map_button: Button
@export var left_button: Button
@export var right_button: Button
@export var interact_button: Button

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var ripple_anim: AnimationPlayer = hook.get_node("AnimationPlayer")
@onready var ui_bite_indicator: TextureRect = get_node("../../UI/BiteIndicator")
@onready var catch_ui: Control = get_node("../../UI/CatchUI")
@onready var bar_background: Control = catch_ui.get_node("BarBackground")
@onready var marker: Control = bar_background.get_node("Marker")
@onready var sweet_spot: Control = bar_background.get_node("SweetSpot")
@onready var catch_progress: ProgressBar = catch_ui.get_node("CatchProgress")
@onready var bite_sound: AudioStreamPlayer = get_node("../../Audio/bite")
@onready var cast_sound: AudioStreamPlayer = get_node("../../Audio/cast")
@onready var success_sound: AudioStreamPlayer = get_node("../../Audio/success")
@onready var whoosh_sound: AudioStreamPlayer = get_node("../../Audio/whoosh")

@export var cast_power_ui_scene: PackedScene
var cast_power_ui: Control = null
@export var inventory_ui: Node

signal line_visible(visible: bool)

# STATE MACHINE
enum {
	STATE_IDLE,
	STATE_CHARGING,
	STATE_CASTED,
	STATE_BITE,
	STATE_MINIGAME,
	STATE_ROTATING,
	STATE_STORY_EVENT  # 🆕 Story Event State
}

var state: int = STATE_IDLE
var paused: bool = false

# Cast Power Variables
var cast_power: float = 0.0
var cast_power_speed: float = 3
var max_cast_power: float = 1.0
var min_distance: float = 2.3
var max_distance: float = 20.0
var last_cast_quality: float = 0.0

# Minigame Variables
var marker_pos: float = 0.0
var marker_speed: float = 350.0
var marker_slow_factor: float = 0.3
var input_active: bool = false
var current_fish: Dictionary = {}

# Rotation Variables
var current_rotation: float = 180.0
var target_rotation: float = 180.0
var is_rotating: bool = false

const ROTATION_FISHING: float = 180.0
const ROTATION_SHOP: float = 90.0
const ROTATION_EMPTY_1: float = 0.0
const ROTATION_EMPTY_2: float = 270.0

var hook_start_position: Vector3
var hook_end_position: Vector3

# 🆕 Biom-spezifische Fish List
var current_fish_list: Array = []


func _ready() -> void:
	show_story_event()
	anim.play("idle")
	hook.visible = false
	splash.visible = false
	splash.emitting = false
	ui_bite_indicator.visible = false
	catch_ui.visible = false
	
	if story_event_panel:
		story_event_panel.visible = false
	
	if cast_power_ui_scene:
		cast_power_ui = cast_power_ui_scene.instantiate()
		add_child(cast_power_ui)
	
	setup_buttons()
	load_fish_list()
	
	# Story Fish Signal verbinden
	FishDB.story_fish_caught.connect(_on_story_fish_caught)


# 🆕 Lade richtige Fish-Liste basierend auf fishing_location
func load_fish_list() -> void:
	match fishing_location:
		"lake":
			current_fish_list = FishDB.FISH_LAKE
		"city":
			current_fish_list = FishDB.FISH_CITY
		"sewer":
			current_fish_list = FishDB.FISH_SEWER
		"forest":
			current_fish_list = FishDB.FISH_FOREST
		"desert":
			current_fish_list = FishDB.FISH_DESERT
		_:
			current_fish_list = FishDB.FISH_LAKE
			print("⚠️ Unbekanntes Biom, verwende FISH_LAKE")


func setup_buttons() -> void:
	if journal_button:
		journal_button.pressed.connect(toggle_fishbook)
	if inventory_button:
		inventory_button.pressed.connect(toggle_inventory)
	if map_button:
		map_button.pressed.connect(open_map)
	if left_button:
		left_button.pressed.connect(rotate_camera_left)
	if right_button:
		right_button.pressed.connect(rotate_camera_right)
	if interact_button:
		interact_button.pressed.connect(on_interact_pressed)


func _unhandled_input(event: InputEvent) -> void:
	# Story Event blockiert Input
	if state == STATE_STORY_EVENT:
		return
	
	if event.is_action_released("pause"):
		handle_pause_input()
		return
	
	if paused:
		return
	
	if event.is_action_pressed("left"):
		rotate_camera_left()
		return
	if event.is_action_pressed("right"):
		rotate_camera_right()
		return
	if event.is_action_pressed("map_open"):
		Player.update_last_scene("res://scenes/" + fishing_location + ".tscn")
		get_tree().change_scene_to_file("res://scenes/MapScene.tscn")
		return
	if event.is_action_pressed("journal"):
		toggle_fishbook()
		return
	if event.is_action_pressed("inventory_toggle"):
		toggle_inventory()
		return

	if event.is_action_pressed("cast") and abs(current_rotation - ROTATION_SHOP) < 1.0:
		enter_shop()
		return

	if state == STATE_ROTATING:
		return

	if state == STATE_MINIGAME:
		if event.is_action_pressed("cast"):
			input_active = true
		if event.is_action_released("cast"):
			input_active = false

	if event.is_action_pressed("cast"):
		if abs(current_rotation - ROTATION_FISHING) > 1.0:
			return
		match state:
			STATE_IDLE:
				start_charging_cast()
			STATE_CASTED, STATE_BITE:
				reel_pressed()
	
	if event.is_action_released("cast"):
		if state == STATE_CHARGING:
			release_cast()


# [MENU SYSTEM - wie gehabt]
func handle_pause_input() -> void:
	if fishbook_ui and fishbook_ui.visible:
		close_fishbook()
		return
	if inventory_ui and inventory_ui.visible:
		close_inventory()
		return
	if options and options.visible:
		close_options()
		return
	open_options()

func toggle_fishbook() -> void:
	if state == STATE_MINIGAME or state == STATE_BITE:
		return
	if fishbook_ui.visible:
		close_fishbook()
	else:
		open_fishbook()

func toggle_inventory() -> void:
	if inventory_ui.visible:
		close_inventory()
	else:
		open_inventory()

func open_fishbook() -> void:
	close_inventory()
	close_options()
	fishbook_ui.visible = true
	paused = false
	Engine.time_scale = 1

func close_fishbook() -> void:
	fishbook_ui.visible = false
	paused = false
	Engine.time_scale = 1

func open_inventory() -> void:
	close_fishbook()
	close_options()
	inventory_ui.show()
	paused = false
	Engine.time_scale = 1

func close_inventory() -> void:
	inventory_ui.hide()
	paused = false
	Engine.time_scale = 1

func open_options() -> void:
	close_fishbook()
	close_inventory()
	options.show()
	paused = true
	Engine.time_scale = 0

func close_options() -> void:
	options.hide()
	paused = false
	Engine.time_scale = 1


# [ROTATION SYSTEM - wie gehabt]
func rotate_camera_left() -> void:
	if is_rotating:
		return
	whoosh_sound.play()
	if current_rotation == ROTATION_FISHING:
		target_rotation = ROTATION_EMPTY_2
	elif current_rotation == ROTATION_EMPTY_2:
		target_rotation = ROTATION_EMPTY_1
	elif current_rotation == ROTATION_EMPTY_1:
		target_rotation = ROTATION_SHOP
	elif current_rotation == ROTATION_SHOP:
		target_rotation = ROTATION_FISHING
	reset_line()
	start_rotation()

func rotate_camera_right() -> void:
	if is_rotating:
		return
	whoosh_sound.play()
	if current_rotation == ROTATION_FISHING:
		target_rotation = ROTATION_SHOP
	elif current_rotation == ROTATION_SHOP:
		target_rotation = ROTATION_EMPTY_1
	elif current_rotation == ROTATION_EMPTY_1:
		target_rotation = ROTATION_EMPTY_2
	elif current_rotation == ROTATION_EMPTY_2:
		target_rotation = ROTATION_FISHING
	reset_line()
	start_rotation()

func start_rotation() -> void:
	state = STATE_ROTATING
	is_rotating = true
	if state == STATE_MINIGAME:
		catch_ui.visible = false

func _process(delta: float) -> void:
	if state == STATE_ROTATING:
		update_rotation(delta)
	elif state == STATE_MINIGAME:
		update_catch_minigame(delta)
	elif state == STATE_CHARGING:
		update_cast_power(delta)

func update_rotation(delta: float) -> void:
	var rotation_step = rotation_speed * delta
	var diff = target_rotation - current_rotation
	if diff > 180.0:
		diff -= 360.0
	elif diff < -180.0:
		diff += 360.0
	if abs(diff) < rotation_step:
		current_rotation = target_rotation
	elif diff > 0:
		current_rotation += rotation_step
	else:
		current_rotation -= rotation_step
	if current_rotation >= 360.0:
		current_rotation -= 360.0
	elif current_rotation < 0.0:
		current_rotation += 360.0
	if camera:
		camera.rotation.y = deg_to_rad(current_rotation)
	if abs(current_rotation - target_rotation) < 0.5:
		current_rotation = target_rotation
		is_rotating = false
		if current_rotation == ROTATION_FISHING:
			state = STATE_IDLE
		else:
			state = STATE_ROTATING

func enter_shop() -> void:
	Player.update_last_scene("res://scenes/" + fishing_location + ".tscn")
	get_tree().change_scene_to_file("res://scenes/shop_inside.tscn")

func open_map() -> void:
	Player.update_last_scene("res://scenes/" + fishing_location + ".tscn")
	get_tree().change_scene_to_file("res://scenes/MapScene.tscn")

func on_interact_pressed() -> void:
	if abs(current_rotation - ROTATION_SHOP) < 1.0:
		enter_shop()
		return
	if abs(current_rotation - ROTATION_FISHING) < 1.0:
		match state:
			STATE_IDLE:
				start_charging_cast()
			STATE_CHARGING:
				release_cast()
			STATE_CASTED, STATE_BITE:
				reel_pressed()


# [CAST SYSTEM - wie gehabt]
func start_charging_cast() -> void:
	state = STATE_CHARGING
	cast_power = 0.0
	if cast_power_ui and cast_power_ui.has_method("show_power"):
		cast_power_ui.show_power(0.0)

func update_cast_power(delta: float) -> void:
	cast_power += cast_power_speed * delta
	if cast_power > max_cast_power:
		cast_power = max_cast_power
		cast_power_speed *= -1.0
	elif cast_power < 0.0:
		cast_power = 0.0
		cast_power_speed *= -1.0
	if cast_power_ui and cast_power_ui.has_method("show_power"):
		cast_power_ui.show_power(cast_power)

func release_cast() -> void:
	if cast_power_ui and cast_power_ui.has_method("hide_power"):
		cast_power_ui.hide_power()
	var power_quality = 1.0 - abs(cast_power - 1.0)
	last_cast_quality = power_quality
	cast_line(power_quality)

func cast_line(power: float = 1.0) -> void:
	cast_sound.play()
	state = STATE_CASTED
	ui_bite_indicator.visible = false
	anim.play("cast")
	camera.start_screenshake(0.01,0.3)
	await anim.animation_finished

	var x = randf_range(-2.0, 2.0)
	var distance = lerp(min_distance, max_distance, power)
	var z = distance
	var water_height = 0.05
	if waterplane:
		water_height = waterplane.global_position.y
	
	hook.position = Vector3(x, water_height, z)
	hook.visible = true
	hook_start_position = hook.global_position
	var direction_to_rod = (rod_tip.global_position - hook.global_position).normalized()
	direction_to_rod.y = 0
	hook_end_position = rod_tip.global_position - direction_to_rod * min_distance
	hook_end_position.y = water_height

	splash.position = Vector3(x, water_height, z)
	splash.visible = true
	splash.emitting = true
	splash.restart()
	ripple_anim.play("ripple")
	anim.play("idle")
	start_bite_timer()
	emit_signal("line_visible", true)

func reel_pressed() -> void:
	match state:
		STATE_CASTED:
			reset_line()
		STATE_BITE:
			ui_bite_indicator.visible = false
			start_catch_minigame()

func reset_line() -> void:
	state = STATE_IDLE
	anim.play("reel")
	await anim.animation_finished
	hook.visible = false
	splash.visible = false
	splash.emitting = false
	ui_bite_indicator.visible = false
	anim.play("idle")
	emit_signal("line_visible", false)
	catch_ui.hide()

func start_bite_timer() -> void:
	var wait_time := randf_range(5, 20)
	var modifier := 1.0 + (Player.upgrade_line - 1) * 0.35
	wait_time /= modifier
	await get_tree().create_timer(wait_time).timeout
	if state != STATE_CASTED:
		return
	state = STATE_BITE
	show_bite_indicator()
	start_bite_window()

func start_bite_window() -> void:
	var max_reaction_time := 2.0
	await get_tree().create_timer(max_reaction_time).timeout
	if state == STATE_BITE:
		ui_bite_indicator.visible = false
		state = STATE_CASTED
		start_bite_timer()

func show_bite_indicator() -> void:
	splash.restart()
	bite_sound.play()
	ui_bite_indicator.visible = true
	while state == STATE_BITE:
		ui_bite_indicator.modulate.a = 1.0
		await get_tree().create_timer(0.2).timeout
		if state != STATE_BITE:
			break
		ui_bite_indicator.modulate.a = 0.2
		await get_tree().create_timer(0.2).timeout


# [MINIGAME mit Story-Fish Support]
func start_catch_minigame() -> void:
	state = STATE_MINIGAME
	catch_ui.visible = true
	anim.play("fight")
	camera.start_screenshake(0.1,1)
	splash.emitting = true

	var quality_bonus = int(last_cast_quality * 2)
	var effective_bait = Player.upgrade_bait + quality_bonus
	
	# 🆕 Biom mitgeben für Story-Fish Check
	current_fish = FishDB.get_random_from_list(current_fish_list, effective_bait, fishing_location)
	
	var difficulty = FishDB.get_fish_difficulty(current_fish)
	marker_speed = FishDB.get_marker_speed_for_fish(current_fish)
	
	print("Gefangen: ", current_fish["name"], " | Rarity:", current_fish["rarity"])

	catch_progress.value = 50.0
	marker_pos = 0.0
	marker.position.x = 0.0

func update_catch_minigame(delta: float) -> void:
	var current_speed = marker_speed
	var t := catch_progress.value / 100.0
	var new_pos := hook_start_position.lerp(hook_end_position, t)
	new_pos.y = hook_start_position.y
	hook.global_position = new_pos

	if input_active:
		current_speed *= marker_slow_factor

	marker_pos += current_speed * delta
	var max_x := bar_background.size.x - marker.size.x

	if marker_pos >= max_x:
		marker_pos = max_x
		marker_speed *= -1.0
	elif marker_pos <= 0.0:
		marker_pos = 0.0
		marker_speed *= -1.0

	marker.position.x = marker_pos

	var in_spot := marker.position.x >= sweet_spot.position.x \
		and marker.position.x <= sweet_spot.position.x + sweet_spot.size.x

	if in_spot:
		var grip_multiplier := 1.0 + (Player.upgrade_grip - 1) * 0.05
		catch_progress.value += 40.0 * grip_multiplier * delta
		if splash:
			splash.global_position = hook.global_position
			if not splash.emitting:
				splash.emitting = true
		camera.start_screenshake(0.03,0.2)
	else:
		catch_progress.value = max(0.0, catch_progress.value - 25.0 * delta)
		if splash and splash.emitting:
			splash.emitting = false

	if catch_progress.value >= 100.0:
		end_catch_minigame(true)
	elif catch_progress.value <= 0.0:
		end_catch_minigame(false)

func end_catch_minigame(success: bool) -> void:
	camera.start_screenshake(0.4,0.3)
	if success:
		var fish = current_fish
		
		# 🆕 Check ob Story-Fisch
		var is_story_fish = fish.get("rarity") == FishDB.RARITY.STORY
		
		if is_story_fish:
			# Story-Fisch → Event triggern
			handle_story_fish_caught(fish)
		else:
			# Normaler Fisch
			Inventory.add_fish(fish)
			Player.caught_fish_species[fish["name"]] = true
			
			# 🆕 Zähle Fänge im Biom
			increment_biome_catches()
			
			success_sound.play()
			if catch_result_ui:
				catch_result_ui.show_fish(fish)
			Player.save_game()
	else:
		print("Fisch entwischt! (", current_fish["name"], ")")

	catch_ui.visible = false
	await reset_line()


# 🆕 Biom-Fang Counter erhöhen
func increment_biome_catches() -> void:
	var catches_key = "catches_" + fishing_location
	var current = Player.get(catches_key) if Player.get(catches_key) != null else 0
	Player.set(catches_key, current + 1)
	print("📊 Fänge in", fishing_location, ":", current + 1)


# 🆕 Story-Fisch Event Handler
func handle_story_fish_caught(fish: Dictionary) -> void:
	print("🌟 STORY-FISCH GEFANGEN:", fish["name"])
	
	state = STATE_STORY_EVENT
	
	# Markiere als gefangen
	Player.caught_fish_species[fish["name"]] = true
	FishDB.emit_signal("story_fish_caught", fishing_location, fish)
	
	# Zeige Story Event
	show_story_event()


# 🆕 Story Event UI anzeigen
func show_story_event() -> void:
	var ani = $"../../Explosion/Sketchfab_Scene/AnimationPlayer"
	explosion.show()
	ani.play("explosion")
	camera.start_screenshake(0.3,6)
	
	

func _on_story_event_continue() -> void:
	story_event_panel.visible = false
	
	# Optional: Zur Event-Scene wechseln
	var story_fish = FishDB.get_story_fish(fishing_location)
	if story_fish.has("event_scene"):
		Player.update_last_scene("res://scenes/" + fishing_location + ".tscn")
		get_tree().change_scene_to_file(story_fish["event_scene"])
	else:
		state = STATE_IDLE


func _on_story_fish_caught(biome: String, fish: Dictionary) -> void:
	print("📢 Story Event für", biome, "abgeschlossen!")
	# Hier könntest du weitere Reaktionen einfügen


func trigger_splash_burst() -> void:
	if not splash:
		return
	splash.emitting = true
	await get_tree().create_timer(0.15).timeout
	if splash and state == STATE_MINIGAME:
		splash.emitting = false
