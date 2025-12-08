extends Sprite3D

# Bewegung
var target_position: Vector3 = Vector3.ZERO
var movement_speed: float = 1.0
var rotation_speed: float = 2.0

# Grenzen
var min_bounds: Vector3 = Vector3(-5, -3, -2.5)
var max_bounds: Vector3 = Vector3(5, 3, 2.5)

# Fish Info
var fish_name: String = ""
var rarity: int = 0

# Idle Animation
var idle_timer: float = 0.0
var idle_amplitude: float = 0.05
var idle_frequency: float = 1.5

# Ziel-Wechsel Timer
var target_change_timer: float = 0.0
var target_change_interval: float = 3.0  # Alle 5 Sekunden neues Ziel

func _ready() -> void:
	# Setze initiales Ziel
	if target_position == Vector3.ZERO:
		target_position = get_new_target()
	
	# Randomisiere Timer
	target_change_timer = randf_range(0, target_change_interval)
	
	# Füge zur Gruppe hinzu für Schwarm-Verhalten
	add_to_group("aquarium_fish")

func _process(delta: float) -> void:
	# Timer für Ziel-Wechsel
	target_change_timer -= delta
	if target_change_timer <= 0:
		target_position = get_new_target()
		target_change_timer = target_change_interval
	
	# Bewege Fisch zu Zielposition
	var direction = (target_position - position).normalized()
	var distance = position.distance_to(target_position)
	
	if distance > 0.2:
		# Bewegen
		var move_delta = direction * movement_speed * delta
		position += move_delta
		
		# Drehe Fisch in Bewegungsrichtung (nur Y-Achse)
		if direction.length() > 0.01:
			var target_rotation = atan2(-direction.x, -direction.z)
			rotation.y = lerp_angle(rotation.y, target_rotation, rotation_speed * delta)
	
	# Idle Bobbing Animation (auf und ab)
	idle_timer += delta
	var bob_offset = sin(idle_timer * idle_frequency) * idle_amplitude
	position.y += bob_offset * delta * 10.0  # *10 für sichtbarere Bewegung
	
	# Clamp Position innerhalb Grenzen
	position.x = clamp(position.x, min_bounds.x, max_bounds.x)
	position.y = clamp(position.y, min_bounds.y, max_bounds.y)
	position.z = clamp(position.z, min_bounds.z, max_bounds.z)

func get_new_target() -> Vector3:
	# 30% Chance für Schwarm-Verhalten
	if randf() < 0.01:
		var nearby_fish = get_nearby_fish(3.0)
		if nearby_fish.size() > 0:
			# Schwimme zu nahegelegenen Fischen
			var center = Vector3.ZERO
			for fish in nearby_fish:
				center += fish.position
			center /= nearby_fish.size()
			
			# Füge etwas Zufall hinzu
			center += Vector3(
				randf_range(-1, 1),
				randf_range(-0.5, 0.5),
				randf_range(-1, 1)
			)
			return center
	
	# Ansonsten: Zufällige Position
	return Vector3(
		randf_range(min_bounds.x, max_bounds.x),
		randf_range(min_bounds.y, max_bounds.y),
		randf_range(min_bounds.z, max_bounds.z)
	)

func get_nearby_fish(radius: float) -> Array:
	var nearby = []
	var all_fish = get_tree().get_nodes_in_group("aquarium_fish")
	
	for fish in all_fish:
		if fish != self:
			var dist = position.distance_to(fish.position)
			if dist < radius:
				nearby.append(fish)
	
	return nearby
