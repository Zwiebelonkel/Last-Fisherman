extends CanvasLayer
## A brief burst of the existing rain-on-camera effect, owned by the location.

const RAIN := preload("res://shader/screen_rain.gdshader")
const LIFETIME: float = 3.8
const APPEAR_DURATION: float = 0.14

var _material: ShaderMaterial
var _before: BackBufferCopy
var _after: BackBufferCopy
var _rect: ColorRect
var _age: float = 0.0
var _active: bool = false


func _ready() -> void:
	name = "CatchLensSplash"
	# Include droplets in subsequent rarity effects, pixelation and CRT filters.
	layer = -2
	_before = BackBufferCopy.new()
	_before.copy_mode = BackBufferCopy.COPY_MODE_DISABLED
	add_child(_before)
	_material = ShaderMaterial.new()
	_material.shader = RAIN
	_material.set_shader_parameter("frequency", 2.0)
	_material.set_shader_parameter("size", 0.009)
	_material.set_shader_parameter("splash_mode", true)
	_material.set_shader_parameter("splash_density", 0.3)
	_rect = ColorRect.new()
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rect.material = _material
	add_child(_rect)
	_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_after = BackBufferCopy.new()
	_after.copy_mode = BackBufferCopy.COPY_MODE_DISABLED
	add_child(_after)
	stop()


func play() -> void:
	_age = 0.0
	_active = true
	_material.set_shader_parameter("splash_seed", randf() * 100.0)
	_material.set_shader_parameter("splash_age", 0.0)
	_material.set_shader_parameter("effect_amount", 0.0)
	_material.set_shader_parameter("splash_growth", 0.0)
	_before.copy_mode = BackBufferCopy.COPY_MODE_VIEWPORT
	_after.copy_mode = BackBufferCopy.COPY_MODE_VIEWPORT
	show()
	set_process(true)


func _process(delta: float) -> void:
	_age += delta
	if _age >= LIFETIME:
		stop()
		return
	var growth := smoothstep(0.0, APPEAR_DURATION, _age)
	var amount := growth * (1.0 - smoothstep(0.5, LIFETIME, _age))
	_material.set_shader_parameter("splash_growth", growth)
	_material.set_shader_parameter("splash_age", _age)
	_material.set_shader_parameter("effect_amount", amount)


func stop() -> void:
	_active = false
	_material.set_shader_parameter("effect_amount", 0.0)
	_before.copy_mode = BackBufferCopy.COPY_MODE_DISABLED
	_after.copy_mode = BackBufferCopy.COPY_MODE_DISABLED
	hide()
	set_process(false)
