extends MeshInstance3D
## Shared solid fish silhouette for the detail viewer and the catch flight.

@export_range(0.04, 0.5, 0.01) var depth: float = 0.22

const MAX_MASK_SIZE: int = 96
const ALPHA_CUTOFF: float = 0.5

var _material: ShaderMaterial
var texture_region := Rect2(0.0, 0.0, 1.0, 1.0)
var slice_region := Vector2(0.0, 1.0)


func set_texture(texture: Texture2D, is_shiny: bool = false) -> void:
	if texture == null:
		texture = preload("res://assets/fish/unknown.png")
	if _material == null:
		_material = ShaderMaterial.new()
		_material.shader = preload("res://shader/fish_icon_preview.gdshader")
		material_override = _material
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_material.set_shader_parameter("fish_texture", texture)
	_material.set_shader_parameter("shiny_enabled", is_shiny)
	mesh = _create_silhouette_mesh(texture)


func set_cooked(amount: float, burned: float = 0.0) -> void:
	if _material != null:
		_material.set_shader_parameter("cooked_amount", clampf(amount, 0.0, 1.0))
		_material.set_shader_parameter("burned_amount", clampf(burned, 0.0, 1.0))


func _create_silhouette_mesh(texture: Texture2D) -> ArrayMesh:
	var image := texture.get_image()
	if image == null or image.is_empty():
		return null
	if image.is_compressed():
		image.decompress()
	var longest: int = maxi(image.get_width(), image.get_height())
	if longest > MAX_MASK_SIZE:
		var ratio: float = float(MAX_MASK_SIZE) / float(longest)
		image.resize(maxi(1, roundi(image.get_width() * ratio)), maxi(1, roundi(image.get_height() * ratio)), Image.INTERPOLATE_NEAREST)
	var width: int = image.get_width()
	var height: int = image.get_height()
	var mask := PackedByteArray()
	mask.resize(width * height)
	var min_x: int = width
	var min_y: int = height
	var max_x: int = -1
	var max_y: int = -1
	for y in range(height):
		for x in range(width):
			if image.get_pixel(x, y).a >= ALPHA_CUTOFF:
				mask[y * width + x] = 1
				min_x = mini(min_x, x)
				max_x = maxi(max_x, x)
				min_y = mini(min_y, y)
				max_y = maxi(max_y, y)
	if max_x < 0:
		return null
	# The mesh is centered on opaque pixels; retain their position in the full
	# texture so its landing can match the catch card, including transparent padding.
	texture_region = Rect2(
		Vector2(float(min_x) / width, float(min_y) / height),
		Vector2(float(max_x - min_x + 1) / width, float(max_y - min_y + 1) / height)
	)
	# Cut using the full fish's coordinates, preserving the proportions and
	# center of every piece. Boundary walls also close the fresh cut faces.
	var first_column := min_x + roundi((max_x - min_x + 1) * slice_region.x)
	var last_column := min_x + roundi((max_x - min_x + 1) * slice_region.y)
	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			if x < first_column or x >= last_column:
				mask[y * width + x] = 0
	var pixel_size: float = 2.0 / float(maxi(max_x - min_x + 1, max_y - min_y + 1))
	var center := Vector2(min_x + max_x + 1, min_y + max_y + 1) * 0.5
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var half_depth: float = depth * 0.5
	for y in range(min_y, max_y + 1):
		var x: int = min_x
		while x <= max_x:
			if mask[y * width + x] == 0:
				x += 1
				continue
			var first: int = x
			while x <= max_x and mask[y * width + x] != 0:
				x += 1
			# Merge each solid row into one front/back quad; holes stay open.
			var left: float = (first - center.x) * pixel_size
			var right: float = (x - center.x) * pixel_size
			var top: float = (center.y - y) * pixel_size
			var bottom: float = (center.y - y - 1.0) * pixel_size
			var uv := PackedVector2Array([
				Vector2(float(first) / width, float(y) / height),
				Vector2(float(x) / width, float(y) / height),
				Vector2(float(x) / width, float(y + 1) / height),
				Vector2(float(first) / width, float(y + 1) / height),
			])
			_add_quad(surface, PackedVector3Array([
				Vector3(left, top, half_depth), Vector3(right, top, half_depth),
				Vector3(right, bottom, half_depth), Vector3(left, bottom, half_depth),
			]), uv, Vector3.BACK, 1.0)
			_add_quad(surface, PackedVector3Array([
				Vector3(right, top, -half_depth), Vector3(left, top, -half_depth),
				Vector3(left, bottom, -half_depth), Vector3(right, bottom, -half_depth),
			]), PackedVector2Array([uv[1], uv[0], uv[3], uv[2]]), Vector3.FORWARD, 1.0)
	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			if mask[y * width + x] == 0:
				continue
			var left: float = (x - center.x) * pixel_size
			var right: float = (x + 1.0 - center.x) * pixel_size
			var top: float = (center.y - y) * pixel_size
			var bottom: float = (center.y - y - 1.0) * pixel_size
			# Only the silhouette boundary gets walls, never interior pixel seams.
			if y == 0 or mask[(y - 1) * width + x] == 0:
				_add_quad(surface, PackedVector3Array([
					Vector3(left, top, -half_depth), Vector3(right, top, -half_depth),
					Vector3(right, top, half_depth), Vector3(left, top, half_depth),
				]), _wall_uv(image, x, y, Vector2i.DOWN), Vector3.UP, 0.82)
			if y == height - 1 or mask[(y + 1) * width + x] == 0:
				_add_quad(surface, PackedVector3Array([
					Vector3(left, bottom, half_depth), Vector3(right, bottom, half_depth),
					Vector3(right, bottom, -half_depth), Vector3(left, bottom, -half_depth),
				]), _wall_uv(image, x, y, Vector2i.UP), Vector3.DOWN, 0.52)
			if x == 0 or mask[y * width + x - 1] == 0:
				_add_quad(surface, PackedVector3Array([
					Vector3(left, top, -half_depth), Vector3(left, top, half_depth),
					Vector3(left, bottom, half_depth), Vector3(left, bottom, -half_depth),
				]), _wall_uv(image, x, y, Vector2i.RIGHT), Vector3.LEFT, 0.66)
			if x == width - 1 or mask[y * width + x + 1] == 0:
				_add_quad(surface, PackedVector3Array([
					Vector3(right, top, half_depth), Vector3(right, top, -half_depth),
					Vector3(right, bottom, -half_depth), Vector3(right, bottom, half_depth),
				]), _wall_uv(image, x, y, Vector2i.LEFT), Vector3.RIGHT, 0.7)
	surface.index()
	return surface.commit()


func _wall_uv(image: Image, x: int, y: int, inward: Vector2i) -> PackedVector2Array:
	# Borrow the adjacent body color so the black outline does not fill every side.
	# The front/back outline itself remains the unchanged original texture.
	var pixel := Vector2i(x, y)
	for step in range(1, 4):
		var candidate: Vector2i = Vector2i(x, y) + inward * step
		if candidate.x < 0 or candidate.y < 0 or candidate.x >= image.get_width() or candidate.y >= image.get_height():
			break
		var color := image.get_pixelv(candidate)
		if color.a < ALPHA_CUTOFF:
			break
		if maxf(color.r, maxf(color.g, color.b)) > 0.12:
			pixel = candidate
			break
	var uv := Vector2((pixel.x + 0.5) / image.get_width(), (pixel.y + 0.5) / image.get_height())
	return PackedVector2Array([uv, uv, uv, uv])


func _add_quad(surface: SurfaceTool, vertices: PackedVector3Array, uv: PackedVector2Array, normal: Vector3, brightness: float) -> void:
	for index in [0, 1, 2, 0, 2, 3]:
		surface.set_normal(normal)
		surface.set_uv(uv[index])
		surface.set_color(Color(brightness, brightness, brightness, 1.0))
		surface.add_vertex(vertices[index])
