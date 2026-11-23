extends Node3D
## Shared color and rarity glow in the shop, on the rod and on the water.

const GLOW_SHADER := preload("res://shader/bait_glow.gdshader")

const BAIT_COLORS := {
	"Common": Color(0.4, 0.4, 0.4),
	"Uncommon": Color(0.4, 0.8, 0.4),
	"Rare": Color(0.3, 0.5, 1.0),
	"Epic": Color(0.7, 0.3, 1.0),
	"Legendary": Color(1.0, 0.6, 0.0),
	"Exotic": Color(1.0, 0.2, 0.5),
}

# Keep the surface colored; the soft halo supplies the visible light spill.
const BAIT_GLOW := {
	"Common": Vector2(0.18, 0.30),
	"Uncommon": Vector2(0.25, 0.42),
	"Rare": Vector2(0.34, 0.55),
	"Epic": Vector2(0.45, 0.70),
	"Legendary": Vector2(0.60, 0.90),
	"Exotic": Vector2(0.80, 1.15),
}

# Energy and world-space reach of the small, actual light on the bobber.
const BAIT_LIGHT := {
	"Common": Vector2(0.45, 0.50),
	"Uncommon": Vector2(0.60, 0.58),
	"Rare": Vector2(0.80, 0.66),
	"Epic": Vector2(1.00, 0.74),
	"Legendary": Vector2(1.25, 0.82),
	"Exotic": Vector2(1.50, 0.90),
}

var _body_material: StandardMaterial3D
var _bait_type: String = "__unset__"
var _glow: MeshInstance3D
var _glow_material: ShaderMaterial
var _light: OmniLight3D
var _glow_enabled: bool = true


func _ready() -> void:
	var body := get_node("base") as MeshInstance3D
	_body_material = body.get_active_material(0).duplicate() as StandardMaterial3D
	body.material_override = _body_material
	_glow_material = ShaderMaterial.new()
	_glow_material.shader = GLOW_SHADER
	var halo_mesh := QuadMesh.new()
	halo_mesh.size = Vector2(1.85, 1.85)
	_glow = MeshInstance3D.new()
	_glow.name = "BaitGlow"
	_glow.mesh = halo_mesh
	_glow.material_override = _glow_material
	_glow.position = body.position
	_glow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_glow)
	_light = OmniLight3D.new()
	_light.name = "BaitLight"
	_light.position = body.position
	# Gameplay uses a 0.055-scale bobber; keep the light's reach in meters.
	_light.set_disable_scale(true)
	_light.omni_attenuation = 1.5
	_light.shadow_enabled = false
	_light.light_volumetric_fog_energy = 0.0
	add_child(_light)
	var player := get_node_or_null("/root/Player")
	set_bait_glow_enabled(bool(player.get("glow_enabled")) if player else true)
	sync_equipped_bait()


func sync_equipped_bait() -> void:
	var player := get_node_or_null("/root/Player")
	set_bait_type(str(player.get("active_bait")) if player else "")


func set_bait_type(bait_type: String) -> void:
	if _bait_type == bait_type or not _body_material:
		return
	_bait_type = bait_type
	var color: Color = BAIT_COLORS.get(bait_type, Color.RED)
	_body_material.albedo_color = color
	_body_material.emission = color if BAIT_COLORS.has(bait_type) else Color.BLACK
	var strength: Vector2 = BAIT_GLOW.get(bait_type, Vector2.ZERO)
	_body_material.emission_energy_multiplier = strength.x
	_glow_material.set_shader_parameter("glow_color", color.lightened(0.12))
	_glow_material.set_shader_parameter("glow_strength", strength.y)
	var light_strength: Vector2 = BAIT_LIGHT.get(bait_type, Vector2(0.0, 0.5))
	_light.light_color = color
	_light.light_energy = light_strength.x
	_light.omni_range = light_strength.y
	_apply_glow_visibility()


func set_bait_glow_enabled(enabled: bool) -> void:
	_glow_enabled = enabled
	_apply_glow_visibility()


func _apply_glow_visibility() -> void:
	var enabled := _glow_enabled and BAIT_COLORS.has(_bait_type)
	if _body_material:
		_body_material.emission_enabled = enabled
	if is_instance_valid(_glow):
		_glow.visible = enabled
	if is_instance_valid(_light):
		_light.visible = enabled
