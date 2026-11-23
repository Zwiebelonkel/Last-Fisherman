extends MeshInstance3D
## Samples the same displaced grid triangles that the water shader renders.

const DEFAULT_WAVES: Array[Vector4] = [
	Vector4(0.3, 4.0, 0.2, 0.6), Vector4(-0.26, -0.19, 0.01, 0.47),
	Vector4(-7.67, 5.63, 0.1, 0.38), Vector4(-0.42, -1.63, 0.1, 0.28),
	Vector4(1.66, 0.07, 0.15, 1.81), Vector4(1.2, 1.14, 0.01, 0.33),
	Vector4(-1.6, 7.3, 0.11, 0.73), Vector4(-0.42, -1.63, 0.15, 1.52)
]

var surface_time: float = 0.0
var _material: ShaderMaterial
var _cached_mesh: Mesh
var _base_positions := PackedVector3Array()
var _kind: String = ""
var _origin := Vector3.ZERO
var _step := Vector2.ONE
var _cells := Vector2i.ONE
var _diagonal_ad: bool = false
var _waves: Array[Vector4] = []
var _height: float = 1.0
var _speed: float = 1.0
var _time_factor: float = 2.5
var _noise_zoom: float = 2.0
var _noise_amp: float = 1.0
var _amplitude: float = 1.0
var _level: float = 0.0
var _detail: int = 0
var _noise_cache: Dictionary = {}
var _vertices: Dictionary = {}
var _refresh_elapsed: float = 0.0


func _ready() -> void:
	process_priority = -30
	refresh_surface()


func _process(delta: float) -> void:
	surface_time = fmod(surface_time + delta, 3600.0)
	_refresh_elapsed += delta
	if mesh != _cached_mesh or get_active_material(0) != _material or _refresh_elapsed >= 0.25:
		refresh_surface()
	_vertices.clear()
	if _material:
		_material.set_shader_parameter("surface_time", _float32(surface_time))


func _parameter(name: StringName, fallback: Variant) -> Variant:
	var value: Variant = _material.get_shader_parameter(name)
	return fallback if value == null else value


func refresh_surface() -> void:
	var geometry_changed: bool = mesh != _cached_mesh or _base_positions.is_empty()
	_refresh_elapsed = 0.0
	_vertices.clear()
	_noise_cache.clear()
	_cached_mesh = mesh
	_material = get_active_material(0) as ShaderMaterial
	if _material == null or _material.shader == null or not mesh is PlaneMesh:
		_kind = "flat"
		return
	var code: String = _material.shader.code
	_kind = "simple" if _material.shader.resource_path.ends_with("/water_performance.gdshader") else "gerstner"
	_height = float(_parameter(&"wave_height", 1.0)) if code.contains("uniform float wave_height") else 1.0
	_speed = float(_parameter(&"wave_speed", 1.0)) if code.contains("uniform float wave_speed") else 1.0
	_time_factor = float(_parameter(&"time_factor", 2.5))
	if absf(_time_factor) < 0.001:
		_time_factor = -0.001 if _time_factor < 0.0 else 0.001
	_noise_zoom = float(_parameter(&"noise_zoom", 2.0))
	_noise_amp = float(_parameter(&"noise_amp", 1.0))
	_amplitude = float(_parameter(&"wave_amplitude_multiplier", 1.0)) if code.contains("wave_amplitude_multiplier") else 1.0
	_level = float(_parameter(&"level_offset", 0.0)) if _kind == "simple" else float(_parameter(&"water_level", 0.0))
	_detail = int(_parameter(&"detail_level", 0))
	_waves.clear()
	for i in range(DEFAULT_WAVES.size()):
		_waves.append(_parameter(StringName("wave_%d" % (i + 1)), DEFAULT_WAVES[i]))
	var plane := mesh as PlaneMesh
	_cells = Vector2i(plane.subdivide_width + 1, plane.subdivide_depth + 1)
	if geometry_changed:
		var arrays: Array = plane.surface_get_arrays(0)
		_base_positions = arrays[Mesh.ARRAY_VERTEX]
		var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
		_origin = _base_positions[0]
		_step = Vector2((_base_positions[_cells.x].x - _origin.x) / _cells.x,
			(_base_positions[-1].z - _origin.z) / _cells.y)
		_diagonal_ad = indices.slice(0, 3).has(0) and indices.slice(0, 3).has(_cells.x + 2)
	_material.set_shader_parameter("surface_time", _float32(surface_time))


func get_surface_position(world_position: Vector3) -> Vector3:
	return sample_surface(world_position).position


func sample_surface(world_position: Vector3) -> Dictionary:
	if mesh != _cached_mesh or get_active_material(0) != _material:
		refresh_surface()
	if _kind == "flat" or absf(_step.x * _step.y) < 0.000001:
		return {"position": Vector3(world_position.x, global_position.y, world_position.z), "normal": Vector3.UP}
	var local := to_local(world_position)
	var cell := Vector2i(floori((local.x - _origin.x) / _step.x), floori((local.z - _origin.z) / _step.y))
	cell.x = clampi(cell.x, 0, _cells.x - 1)
	cell.y = clampi(cell.y, 0, _cells.y - 1)
	var result: Dictionary = _sample_cell(cell, world_position)
	if not result.is_empty():
		return result
	# Horizontal Gerstner displacement can move the rendered cell across its old boundary.
	for z in range(-1, 2):
		for x in range(-1, 2):
			var neighbor := cell + Vector2i(x, z)
			if neighbor == cell or neighbor.x < 0 or neighbor.y < 0 or neighbor.x >= _cells.x or neighbor.y >= _cells.y:
				continue
			result = _sample_cell(neighbor, world_position)
			if not result.is_empty():
				return result
	# Outside the authored water footprint, retain the nearest surface's height.
	return _sample_cell(cell, world_position, false)


func _sample_cell(cell: Vector2i, point: Vector3, inside_only: bool = true) -> Dictionary:
	var a := _vertex(cell)
	var b := _vertex(cell + Vector2i(1, 0))
	var c := _vertex(cell + Vector2i(0, 1))
	var d := _vertex(cell + Vector2i(1, 1))
	var first: Dictionary = _triangle(a, b, d if _diagonal_ad else c, point, true)
	if not first.is_empty():
		return first
	return _triangle(a if _diagonal_ad else b, d, c, point, inside_only)


func _triangle(a: Vector3, b: Vector3, c: Vector3, point: Vector3, inside_only: bool) -> Dictionary:
	var edge_b := Vector2(b.x - a.x, b.z - a.z)
	var edge_c := Vector2(c.x - a.x, c.z - a.z)
	var offset := Vector2(point.x - a.x, point.z - a.z)
	var determinant: float = edge_b.cross(edge_c)
	if absf(determinant) < 0.0000001:
		return {}
	var u: float = offset.cross(edge_c) / determinant
	var v: float = edge_b.cross(offset) / determinant
	if inside_only and (u < -0.0001 or v < -0.0001 or u + v > 1.0001):
		return {}
	var normal := (b - a).cross(c - a).normalized()
	if normal.y < 0.0:
		normal = -normal
	return {"position": Vector3(point.x, a.y + (b.y - a.y) * u + (c.y - a.y) * v, point.z), "normal": normal}


func _vertex(cell: Vector2i) -> Vector3:
	if _vertices.has(cell):
		return _vertices[cell]
	var vertex: Vector3 = _base_positions[cell.y * (_cells.x + 1) + cell.x]
	var time: float = _float32(surface_time)
	if _kind == "simple":
		var scaled: float = _float32(time * _speed)
		var strength: float = _height * (0.075 if _detail > 0 else 0.04)
		vertex.y += _level + (sin(vertex.x * 0.22 + scaled * 0.8) + sin(vertex.z * 0.18 - scaled * 0.65)) * strength
	else:
		time = _float32(_float32(time * _speed) / _time_factor)
		var position := Vector2(vertex.x, vertex.z)
		var dynamic: float = 1.0 + 0.5 * sin(time + position.length() * 0.1)
		var displacement := Vector3.ZERO
		for wave: Vector4 in _waves:
			if absf(wave.w) < 0.00001:
				continue
			var direction := Vector2(wave.x, wave.y).normalized()
			var k: float = TAU / wave.w
			var phase: float = k * (direction.dot(position) - sqrt(9.81 / k) * time)
			var amplitude: float = wave.z * dynamic * _height / k
			displacement += Vector3(direction.x * amplitude * cos(phase), amplitude * sin(phase), direction.y * amplitude * cos(phase))
		if not _noise_cache.has(cell):
			_noise_cache[cell] = _fbm(position * (_noise_zoom / 50.0))
		displacement.y += float(_noise_cache[cell]) * _noise_amp * _height
		vertex += displacement
		vertex.y = vertex.y * _amplitude + _level
	var world := to_global(vertex)
	_vertices[cell] = world
	return world


static func _float32(value: float) -> float:
	return PackedFloat32Array([value])[0]


static func _hash(cell: Vector2) -> float:
	var x: int = int(cell.x) & 0xffffffff
	var y: int = int(cell.y) & 0xffffffff
	var h: int = (x * 374761393 + y * 668265263) & 0xffffffff
	h = ((h ^ (h >> 13)) * 1274126177) & 0xffffffff
	h = h ^ (h >> 16)
	return float(h & 16777215) / 16777215.0


static func _noise(position: Vector2) -> float:
	var cell := position.floor()
	var fraction := position - cell
	fraction = fraction * fraction * (Vector2(3.0, 3.0) - fraction * 2.0)
	return lerpf(lerpf(_hash(cell), _hash(cell + Vector2.RIGHT), fraction.x),
		lerpf(_hash(cell + Vector2.DOWN), _hash(cell + Vector2.ONE), fraction.x), fraction.y)


static func _fbm(position: Vector2) -> float:
	var height: float = 0.0
	var amplitude: float = 0.5
	var frequency: float = 3.0
	for octave in range(6):
		height += _noise(position * frequency) * amplitude
		amplitude *= 0.5
		frequency *= 2.0
	return height
