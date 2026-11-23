extends CanvasLayer
## Screen-edge reveal effect. FishDB remains the source of rarity IDs and colors.

const GLOW_SHADER := preload("res://shader/rarity_vignette_glow.gdshader")
const PROFILES := {
	FishDB.RARITY.NORMAL: {
		"glow": 0.24, "hold": 0.35, "pulse": 2.0, "flow": 2.2,
		"flicker": 0.025, "aberration": 0.0, "distortion": 0.0,
	},
	FishDB.RARITY.UNGEWOEHNLICH: {
		"glow": 0.48, "hold": 0.45, "pulse": 2.4, "flow": 2.6,
		"flicker": 0.04, "aberration": 0.0006, "distortion": 0.001,
	},
	FishDB.RARITY.SELTEN: {
		"glow": 0.80, "hold": 0.60, "pulse": 2.8, "flow": 3.0,
		"flicker": 0.07, "aberration": 0.0012, "distortion": 0.0025,
	},
	FishDB.RARITY.EPISCH: {
		"glow": 1.15, "hold": 0.80, "pulse": 3.3, "flow": 3.8,
		"flicker": 0.10, "aberration": 0.0020, "distortion": 0.004,
	},
	FishDB.RARITY.LEGENDAER: {
		"glow": 1.65, "hold": 1.00, "pulse": 3.8, "flow": 4.5,
		"flicker": 0.14, "aberration": 0.0030, "distortion": 0.006,
	},
	FishDB.RARITY.EXOTISCH: {
		"glow": 2.10, "hold": 1.20, "pulse": 4.4, "flow": 5.3,
		"flicker": 0.18, "aberration": 0.0048, "distortion": 0.009,
	},
	FishDB.RARITY.ANTIK: {
		"glow": 1.90, "hold": 1.40, "pulse": 2.2, "flow": 2.4,
		"flicker": 0.035, "aberration": 0.003, "distortion": 0.005,
	},
}

var _rect: ColorRect
var _back_buffer: BackBufferCopy
var _effect_copy: BackBufferCopy
var _material: ShaderMaterial
var _tween: Tween
var _amount := 0.0


func _ready() -> void:
	name = "RarityVignette"
	# Draw over the 3D world, before the scene's filter (layer 0) and UI (layer 1).
	# A separate canvas also keeps the glow independent of the catch card's tilt.
	layer = -1
	_back_buffer = BackBufferCopy.new()
	_back_buffer.name = "ScreenCopy"
	_back_buffer.copy_mode = BackBufferCopy.COPY_MODE_DISABLED
	add_child(_back_buffer)

	_material = ShaderMaterial.new()
	_material.shader = GLOW_SHADER
	_rect = ColorRect.new()
	_rect.name = "EdgeGlow"
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rect.material = _material
	_rect.visible = false
	add_child(_rect)
	_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# Later screen-reading filters must sample the world WITH the glow included.
	_effect_copy = BackBufferCopy.new()
	_effect_copy.name = "EffectCopy"
	_effect_copy.copy_mode = BackBufferCopy.COPY_MODE_DISABLED
	add_child(_effect_copy)
	hide()


func play(fish: Dictionary) -> void:
	stop()
	var rarity := FishDB.get_rarity_safe(fish)
	var profile: Dictionary = PROFILES.get(rarity, PROFILES[FishDB.RARITY.NORMAL])
	_material.set_shader_parameter("rarity_color", FishDB.get_rarity_color(fish))
	_material.set_shader_parameter("glow_strength", profile["glow"])
	_material.set_shader_parameter("pulse_speed", profile["pulse"])
	_material.set_shader_parameter("pulse_amount", 0.22)
	_material.set_shader_parameter("flicker_strength", profile["flicker"])
	_material.set_shader_parameter("flicker_speed", 8.0 + float(rarity) * 2.0)
	_material.set_shader_parameter("aberration_strength", profile["aberration"])
	_material.set_shader_parameter("distortion_strength", profile["distortion"])
	_material.set_shader_parameter("distortion_speed", profile["flow"])
	# First capture the world for our shader, then its result for the scene filters.
	_back_buffer.copy_mode = BackBufferCopy.COPY_MODE_VIEWPORT
	_effect_copy.copy_mode = BackBufferCopy.COPY_MODE_VIEWPORT
	_rect.show()
	show()
	_tween = create_tween()
	_tween.tween_method(_set_amount, 0.0, 1.0, 0.18).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.tween_interval(float(profile["hold"]))
	_tween.tween_method(_set_amount, 1.0, 0.0, 0.65).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_callback(stop)


func stop(fade_duration: float = 0.0) -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = null
	if fade_duration > 0.0 and _amount > 0.0:
		_tween = create_tween()
		_tween.tween_method(_set_amount, _amount, 0.0, fade_duration)
		_tween.tween_callback(stop)
		return
	_set_amount(0.0)
	_rect.hide()
	_back_buffer.copy_mode = BackBufferCopy.COPY_MODE_DISABLED
	_effect_copy.copy_mode = BackBufferCopy.COPY_MODE_DISABLED
	hide()


func _set_amount(amount: float) -> void:
	_amount = amount
	_material.set_shader_parameter("effect_amount", amount)
