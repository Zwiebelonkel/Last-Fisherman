extends SubViewportContainer
## Shop display of the actual fishing bobber, with its own rarity and lighting.

@export_enum("Common", "Uncommon", "Rare", "Epic", "Legendary", "Exotic") var bait_type: String = "Common"
@export_range(0.0, 90.0, 1.0) var rotation_speed: float = 32.0

@onready var preview_viewport: SubViewport = $SubViewport
@onready var turntable: Node3D = $SubViewport/Display/Turntable
@onready var bait: Node3D = $SubViewport/Display/Turntable/Bait


func _ready() -> void:
	bait.set_bait_type(bait_type)
	visibility_changed.connect(_update_visibility)
	_update_visibility()


func _process(delta: float) -> void:
	# A scrolled-out card should not keep rendering a separate 3D world.
	var displayed := _is_inside_clip()
	preview_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS if displayed else SubViewport.UPDATE_DISABLED
	if displayed:
		turntable.rotation.y = wrapf(turntable.rotation.y + deg_to_rad(rotation_speed) * delta, -PI, PI)


func _update_visibility() -> void:
	var displayed := is_visible_in_tree()
	set_process(displayed)
	preview_viewport.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE if displayed else SubViewport.UPDATE_DISABLED


func _is_inside_clip() -> bool:
	var preview_rect := get_global_rect()
	var ancestor := get_parent()
	while ancestor:
		if ancestor is Control and ancestor.clip_contents:
			if not preview_rect.intersects(ancestor.get_global_rect()):
				return false
		ancestor = ancestor.get_parent()
	return true
