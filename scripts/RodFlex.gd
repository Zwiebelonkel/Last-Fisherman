extends MeshInstance3D
## Bend the shaft and its fixed line with the same curve as the guides and line anchor.

var _guides: Array[Node3D] = []
var _rest_positions := PackedVector3Array()
var _strand: MeshInstance3D


func set_pull(world_bend: Vector3) -> void:
	if _strand == null:
		if world_bend.is_zero_approx():
			return
		_strand = $line
		_add_bend_shapes(self, Transform3D.IDENTITY)
		_add_bend_shapes(_strand, _strand.transform)
		for guide: Node3D in [$RodTip, $holder, $holder2, $holder3]:
			_guides.append(guide)
			_rest_positions.append(guide.position)
	var bend := global_basis.inverse() * world_bend
	bend.y = 0.0
	for part: MeshInstance3D in [self, _strand]:
		part.set_blend_shape_value(0, bend.x)
		part.set_blend_shape_value(1, bend.z)
	for i in _guides.size():
		var rest := _rest_positions[i]
		_guides[i].position = rest + bend * _weight(rest.y)


func _weight(height: float) -> float:
	# The hand and reel sit below the flexing section.
	return pow(maxf(height + 0.1, 0.0) / 1.1, 2.0)


func _add_bend_shapes(part: MeshInstance3D, shaft_space: Transform3D) -> void:
	var source := part.mesh
	var arrays := source.surface_get_arrays(0)
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var deformed := ArrayMesh.new()
	deformed.blend_shape_mode = Mesh.BLEND_SHAPE_MODE_RELATIVE
	var shapes: Array[Array] = []
	for axis: Vector3 in [Vector3.RIGHT, Vector3.BACK]:
		deformed.add_blend_shape("BendX" if shapes.is_empty() else "BendZ")
		var shape := []
		shape.resize(Mesh.ARRAY_MAX)
		var offsets := PackedVector3Array()
		for vertex in vertices:
			offsets.append(shaft_space.basis.inverse() * axis * _weight((shaft_space * vertex).y))
		shape[Mesh.ARRAY_VERTEX] = offsets
		var normals := PackedVector3Array()
		normals.resize(vertices.size())
		shape[Mesh.ARRAY_NORMAL] = normals
		var tangents := PackedFloat32Array()
		tangents.resize(vertices.size() * 4)
		shape[Mesh.ARRAY_TANGENT] = tangents
		shapes.append(shape)
	deformed.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays, shapes)
	deformed.surface_set_material(0, source.surface_get_material(0))
	part.mesh = deformed
