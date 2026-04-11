extends CanvasLayer

@export var shader_path: String = "res://shader/ps1_jitter.gdshader"
@export var layer_index: int = 100

var _overlay: ColorRect

func _ready() -> void:
    layer = layer_index
    _overlay = ColorRect.new()
    _overlay.name = "PS1JitterOverlay"
    _overlay.anchor_left = 0.0
    _overlay.anchor_top = 0.0
    _overlay.anchor_right = 1.0
    _overlay.anchor_bottom = 1.0
    _overlay.offset_left = 0.0
    _overlay.offset_top = 0.0
    _overlay.offset_right = 0.0
    _overlay.offset_bottom = 0.0
    _overlay.color = Color(1, 1, 1, 1)
    _overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

    var shader := load(shader_path) as Shader
    if shader:
        var mat := ShaderMaterial.new()
        mat.shader = shader
        _overlay.material = mat

    add_child(_overlay)
