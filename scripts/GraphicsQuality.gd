extends RefCounted
## Applies saved performance settings to authored scene nodes without changing assets.

const WATER_SHADER := preload("res://shader/water_performance.gdshader")
const MATERIAL_SOURCES := &"graphics_texture_sources"
const WaterChunks := preload("res://scripts/WaterRenderChunks.gd")
var water_chunks := WaterChunks.new()

class TextureSource extends RefCounted:
	var image: Image
	var original: WeakRef
	var active: Texture2D
	var level := -1

var _sources: Dictionary = {}
var _global_key := ""


func apply_global(root: Window, settings: Node) -> void:
	root.scaling_3d_scale = settings.resolution_scale
	Engine.max_fps = settings.frame_limit
	for id: int in _sources.keys():
		if _sources[id].get_ref() == null:
			_sources.erase(id)
	var quality: int = settings.shadow_quality
	var key := str(quality)
	if key == _global_key:
		return
	_global_key = key
	var authored_size := int(ProjectSettings.get_setting("rendering/lights_and_shadows/directional_shadow/size", 4096))
	var authored_filter := int(ProjectSettings.get_setting("rendering/lights_and_shadows/directional_shadow/soft_shadow_filter_quality", 2))
	var atlas_size: int = [512, 1024, 2048, authored_size][quality]
	RenderingServer.directional_shadow_atlas_set_size(atlas_size, quality < 3 or bool(ProjectSettings.get_setting("rendering/lights_and_shadows/directional_shadow/16_bits", true)))
	RenderingServer.directional_soft_shadow_filter_set_quality([0, 0, 1, authored_filter][quality])
	RenderingServer.positional_soft_shadow_filter_set_quality([0, 0, 1, int(ProjectSettings.get_setting("rendering/lights_and_shadows/positional_shadow/soft_shadow_filter_quality", 2))][quality])
	root.positional_shadow_atlas_size = [512, 1024, 2048, int(ProjectSettings.get_setting("rendering/lights_and_shadows/positional_shadow/atlas_size", 4096))][quality]


func apply_node(node: Node, settings: Node) -> void:
	if node is Light3D:
		_apply_light(node, settings.shadow_quality)
	if node is GPUParticles3D or node is GPUParticles2D:
		if not node.has_meta("graphics_particle_ratio"):
			node.set_meta("graphics_particle_ratio", node.amount_ratio)
		node.amount_ratio = float(node.get_meta("graphics_particle_ratio")) * [0.25, 0.5, 1.0][settings.particle_quality]
	if node is Camera3D and node.get_viewport() == settings.get_tree().root:
		if not node.has_meta("graphics_original_far"):
			node.set_meta("graphics_original_far", node.far)
		var authored_far := float(node.get_meta("graphics_original_far"))
		node.far = minf(authored_far, [80.0, 160.0, authored_far][settings.view_distance])
	if node is CanvasLayer and node.get_script() != null and node.get_script().resource_path == "res://scripts/FieldTabletView.gd":
		node.background_blur_enabled = settings.tablet_blur_enabled
	# The separate tablet/preview viewports retain sharp UI and fish icons.
	if node is MeshInstance3D and node.mesh != null and node.mesh.get_surface_count() > 0 and node.get_viewport() == settings.get_tree().root:
		if node.has_meta(WaterChunks.IS_CHUNK):
			return
		_apply_water(node, settings.water_quality)
		for surface in range(node.mesh.get_surface_count()):
			_apply_material(node.get_active_material(surface), settings.texture_quality)
		if node.has_meta("graphics_water_source"):
			water_chunks.apply(node)


func _apply_light(light: Light3D, quality: int) -> void:
	if not light.has_meta("graphics_original_shadows"):
		light.set_meta("graphics_original_shadows", light.shadow_enabled)
	light.shadow_enabled = bool(light.get_meta("graphics_original_shadows")) and quality > 0
	if light is DirectionalLight3D:
		if not light.has_meta("graphics_shadow_distance"):
			light.set_meta("graphics_shadow_distance", light.directional_shadow_max_distance)
			light.set_meta("graphics_shadow_mode", light.directional_shadow_mode)
		var distance := float(light.get_meta("graphics_shadow_distance"))
		light.directional_shadow_max_distance = minf(distance, [20.0, 30.0, 60.0, distance][quality])
		light.directional_shadow_mode = [0, 0, 1, int(light.get_meta("graphics_shadow_mode"))][quality]


func _apply_water(node: MeshInstance3D, quality: int) -> void:
	if not node.has_meta("graphics_water_source"):
		var material := node.get_active_material(0) as ShaderMaterial
		if material == null or material.shader == null:
			return
		# Four locations still store their older water shader inside the scene.
		if not material.shader.resource_path.ends_with("/shader_water.gdshader") and not (node.name == &"WaterPlane" and material.get_shader_parameter("normalmap_a") is Texture2D):
			return
		node.set_meta("graphics_water_source", {"mesh": node.mesh, "material": material, "override": node.material_override, "cast_shadow": node.cast_shadow})
	if int(node.get_meta("graphics_water_quality", -1)) == quality:
		return
	var source: Dictionary = node.get_meta("graphics_water_source")
	if quality == 2:
		node.mesh = source.mesh
		node.material_override = source.override
	else:
		var mesh: Mesh = source.mesh
		if mesh is PlaneMesh:
			var reduced := mesh.duplicate() as PlaneMesh
			var subdivisions := 32 if quality == 0 else 96
			reduced.subdivide_width = mini(reduced.subdivide_width, subdivisions)
			reduced.subdivide_depth = mini(reduced.subdivide_depth, subdivisions)
			node.mesh = reduced
		var material := ShaderMaterial.new()
		material.shader = WATER_SHADER
		var original: ShaderMaterial = source.material
		var color: Variant = original.get_shader_parameter("base_water_color")
		if color is Vector3:
			color = Color(color.x, color.y, color.z)
		if color is Color:
			material.set_shader_parameter("water_color", color)
		for parameter: String in ["wave_height", "wave_speed"]:
			var value: Variant = original.get_shader_parameter(parameter)
			if value is float or value is int:
				material.set_shader_parameter(parameter, value)
		# The original FBM displaces the average surface away from local zero.
		# Retain that mean level so calm water does not swallow the fishing dock.
		var noise_amplitude: Variant = original.get_shader_parameter("noise_amp")
		var height_scale: Variant = original.get_shader_parameter("wave_height")
		if noise_amplitude is float:
			material.set_shader_parameter("level_offset", noise_amplitude * (float(height_scale) if height_scale is float else 1.0) * 0.4921875)
		material.set_shader_parameter("detail_level", quality)
		material.set_shader_parameter("detail_normal", original.get_shader_parameter("normalmap_a"))
		node.material_override = material
		node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	if quality == 2:
		node.cast_shadow = source.cast_shadow
	node.set_meta("graphics_water_quality", quality)


func _apply_material(material: Material, quality: int) -> void:
	if material == null:
		return
	if quality == 0 and not material.has_meta(MATERIAL_SOURCES):
		return
	var slots: Dictionary = material.get_meta(MATERIAL_SOURCES, {})
	if material is BaseMaterial3D:
		for slot in range(BaseMaterial3D.TEXTURE_MAX):
			var texture: Texture2D = material.get_texture(slot)
			var replacement := _texture_for_slot(slots, slot, texture, quality)
			if replacement != texture:
				material.set_texture(slot, replacement)
	elif material is ShaderMaterial and material.shader != null:
		for uniform: Dictionary in material.shader.get_shader_uniform_list():
			var name: StringName = uniform.name
			var value: Variant = material.get_shader_parameter(name)
			if value is Texture2D:
				var replacement := _texture_for_slot(slots, name, value, quality)
				if replacement != value:
					material.set_shader_parameter(name, replacement)
	if not slots.is_empty():
		material.set_meta(MATERIAL_SOURCES, slots)


func _texture_for_slot(slots: Dictionary, slot: Variant, texture: Texture2D, quality: int) -> Texture2D:
	if texture == null or texture is ViewportTexture or texture is NoiseTexture2D or texture is GradientTexture1D or texture is GradientTexture2D:
		return texture
	var source: TextureSource = slots.get(slot)
	if source == null:
		if quality == 0 or maxi(texture.get_width(), texture.get_height()) < 256:
			return texture
		var cached: WeakRef = _sources.get(texture.get_instance_id())
		source = cached.get_ref() as TextureSource if cached != null else null
		if source == null:
			var image := texture.get_image()
			if image == null or image.is_empty():
				return texture
			# Preserve GPU compression: select an existing lower mip chain without
			# relying on Image.compress(), which is unavailable in exported games.
			if image.is_compressed() and not image.has_mipmaps():
				return texture
			source = TextureSource.new()
			source.image = image
			source.original = weakref(texture)
			_sources[texture.get_instance_id()] = weakref(source)
		slots[slot] = source
	if source.level != quality:
		var original := source.original.get_ref() as Texture2D
		if quality == 0:
			source.active = original if original != null else ImageTexture.create_from_image(source.image)
		else:
			var image := source.image
			var reduced: Image
			if image.has_mipmaps():
				var mip := mini(quality, image.get_mipmap_count())
				reduced = Image.create_from_data(maxi(1, image.get_width() >> mip), maxi(1, image.get_height() >> mip), image.get_mipmap_count() > mip, image.get_format(), image.get_data().slice(image.get_mipmap_offset(mip)))
			else:
				reduced = image.duplicate() as Image
				reduced.resize(maxi(1, image.get_width() >> quality), maxi(1, image.get_height() >> quality), Image.INTERPOLATE_LANCZOS)
				reduced.generate_mipmaps()
			source.active = ImageTexture.create_from_image(reduced)
		source.level = quality
		_sources[source.active.get_instance_id()] = weakref(source)
	return source.active
