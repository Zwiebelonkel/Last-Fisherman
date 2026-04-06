extends SpotLight3D

@export_group("Flicker Settings")
@export var flicker_speed: float = 20.0
@export var flicker_intensity: float = 0.4
@export var base_energy: float = 1.0
@export var min_energy: float = 0.3

@export_group("Random Outage")
@export var enable_outage: bool = true
@export var outage_chance: float = 0.002
@export var outage_duration_min: float = 0.05
@export var outage_duration_max: float = 0.25

var _noise: FastNoiseLite
var _noise_offset: float = 0.0
var _in_outage: bool = false
var _outage_timer: float = 0.0

func _ready() -> void:
	_noise = FastNoiseLite.new()
	_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	_noise.frequency = 0.5
	_noise.seed = randi()

func _process(delta: float) -> void:
	if _in_outage:
		_outage_timer -= delta
		if _outage_timer <= 0.0:
			_in_outage = false
		return

	if enable_outage and randf() < outage_chance:
		_in_outage = true
		_outage_timer = randf_range(outage_duration_min, outage_duration_max)
		light_energy = 0.0
		return

	_noise_offset += delta * flicker_speed
	var noise_val: float = _noise.get_noise_1d(_noise_offset)  # -1..1
	var t: float = (noise_val + 1.0) * 0.5                     # 0..1
	light_energy = lerpf(min_energy, base_energy, t) * flicker_intensity + base_energy * (1.0 - flicker_intensity)
