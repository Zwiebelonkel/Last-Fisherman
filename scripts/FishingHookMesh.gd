@tool
extends MeshInstance3D
## A small steel J-hook, built once and shared by every bobber instance.

const SIDES: int = 8
static var _shared_mesh: ArrayMesh


func _init() -> void:
	if not _shared_mesh:
		var surface := SurfaceTool.new()
		surface.begin(Mesh.PRIMITIVE_TRIANGLES)
		# The shaft starts just inside the bottom of the bobber ball.
		var points := PackedVector3Array([
			Vector3(0.0, -0.54, 0.0),
			Vector3(0.0, -0.76, 0.0),
			Vector3(0.0, -0.98, 0.0),
		])
		var radii := PackedFloat32Array([0.022, 0.022, 0.022])
		for step in range(1, 17):
			var angle: float = PI + PI * float(step) / 16.0
			points.append(Vector3(0.16 + cos(angle) * 0.16, -0.98 + sin(angle) * 0.16, 0.0))
			radii.append(0.022)
		points.append(Vector3(0.32, -0.89, 0.0))
		radii.append(0.015)
		points.append(Vector3(0.30, -0.81, 0.0))
		radii.append(0.001)
		_append_tube(surface, points, radii)
		# A short backwards-facing barb below the tapered hook point.
		_append_tube(surface, PackedVector3Array([
			Vector3(0.316, -0.875, 0.0), Vector3(0.265, -0.935, 0.0),
		]), PackedFloat32Array([0.012, 0.001]))
		_shared_mesh = surface.commit()
	mesh = _shared_mesh


static func _append_tube(surface: SurfaceTool, points: PackedVector3Array, radii: PackedFloat32Array) -> void:
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	for ring in range(points.size()):
		var before: Vector3 = points[maxi(ring - 1, 0)]
		var after: Vector3 = points[mini(ring + 1, points.size() - 1)]
		var tangent := (after - before).normalized()
		var side := Vector3(tangent.y, -tangent.x, 0.0)
		for segment in range(SIDES):
			var angle: float = TAU * float(segment) / float(SIDES)
			var normal := side * cos(angle) + Vector3.BACK * sin(angle)
			vertices.append(points[ring] + normal * radii[ring])
			normals.append(normal)
	for ring in range(points.size() - 1):
		for segment in range(SIDES):
			var a: int = ring * SIDES + segment
			var b: int = ring * SIDES + (segment + 1) % SIDES
			var c: int = a + SIDES
			var d: int = b + SIDES
			for index in [a, c, b, b, c, d]:
				surface.set_normal(normals[index])
				surface.add_vertex(vertices[index])
