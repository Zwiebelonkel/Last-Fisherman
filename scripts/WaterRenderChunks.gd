extends RefCounted
## Keep shader coordinates intact while allowing native per-view frustum culling.

const CHUNK_SIZE := 50.0
const MIN_VERTICES := 30000
const STATE := &"water_render_chunks"
const IS_CHUNK := &"water_render_chunk"

class AdaptiveDraw extends Node:
	var source: MeshInstance3D
	var chunks: Array[MeshInstance3D]
	var original_layers: int
	var combined := true
	var elapsed := 0.0

	func _process(delta: float) -> void:
		elapsed += delta
		if elapsed >= 0.1:
			elapsed = 0.0
			refresh()

	func refresh() -> void:
		var camera := source.get_viewport().get_camera_3d()
		if camera == null:
			return
		var planes := camera.get_frustum()
		var visible_count := 0
		for chunk: MeshInstance3D in chunks:
			var box: AABB = source.global_transform * chunk.mesh.get_aabb().grow(chunk.extra_cull_margin)
			var center := box.get_center()
			var half_size := box.size * 0.5
			var outside := false
			for plane: Plane in planes:
				if plane.distance_to(center) > plane.normal.abs().dot(half_size):
					outside = true
					break
			if not outside:
				visible_count += 1
		var fraction := float(visible_count) / chunks.size()
		# Keep one draw when most water is in view. Partitioning then adds CPU
		# overhead without skipping much geometry. Hysteresis prevents churn.
		if fraction >= 0.8:
			combined = true
		elif fraction <= 0.65:
			combined = false
		source.layers = original_layers if combined else 0
		for chunk: MeshInstance3D in chunks:
			chunk.visible = not combined
		# Both modes contain the entire surface. Native per-camera culling still
		# decides what is drawn, including tablet cameras and shadow passes.


func apply(node: MeshInstance3D) -> void:
	if node.has_meta(IS_CHUNK):
		return
	var state: Dictionary = node.get_meta(STATE, {})
	if not state.is_empty() and state.mesh == node.mesh:
		_sync_instances(node, state)
		return
	if not state.is_empty():
		node.layers = state.layers
		state.controller.free()
		for chunk: MeshInstance3D in state.chunks:
			chunk.free()
		node.remove_meta(STATE)
	var plane := node.mesh as PlaneMesh
	if plane == null or plane.orientation != PlaneMesh.FACE_Y or (plane.subdivide_width + 2) * (plane.subdivide_depth + 2) < MIN_VERTICES:
		return
	var columns := plane.subdivide_width + 1
	var rows := plane.subdivide_depth + 1
	var divisions := Vector2i(mini(columns, ceili(plane.size.x / CHUNK_SIZE)), mini(rows, ceili(plane.size.y / CHUNK_SIZE)))
	if divisions.x * divisions.y <= 1:
		return
	var source := plane.surface_get_arrays(0)
	var chunks: Array[MeshInstance3D] = []
	for z in range(divisions.y):
		for x in range(divisions.x):
			var start := Vector2i(x * columns / divisions.x, z * rows / divisions.y)
			var end := Vector2i((x + 1) * columns / divisions.x, (z + 1) * rows / divisions.y)
			var mesh := _slice_mesh(source, columns, start, end)
			var chunk := MeshInstance3D.new()
			chunk.name = "WaterPatch_%d_%d" % [x, z]
			chunk.set_meta(IS_CHUNK, true)
			chunk.mesh = mesh
			# Vertices and UVs stay in the original plane's coordinate system:
			# waves, refraction and normals therefore meet exactly at patch edges.
			chunk.sorting_use_aabb_center = true
			node.add_child(chunk)
			chunks.append(chunk)
	var controller := AdaptiveDraw.new()
	controller.name = "WaterDrawSelector"
	controller.source = node
	controller.chunks = chunks
	controller.original_layers = node.layers
	node.add_child(controller)
	state = {"mesh": plane, "layers": node.layers, "chunks": chunks, "controller": controller}
	node.set_meta(STATE, state)
	_sync_instances(node, state)


func _sync_instances(node: MeshInstance3D, state: Dictionary) -> void:
	var material := node.get_active_material(0)
	var margin := maxf(2.0, node.extra_cull_margin)
	if material is ShaderMaterial:
		var noise: Variant = material.get_shader_parameter("noise_amp")
		var height: Variant = material.get_shader_parameter("wave_height")
		if noise is float:
			margin = maxf(margin, absf(noise) * (absf(height) if height is float else 1.0) + 1.0)
	for chunk: MeshInstance3D in state.chunks:
		chunk.layers = state.layers
		chunk.material_override = material
		chunk.material_overlay = node.material_overlay
		chunk.cast_shadow = node.cast_shadow
		chunk.gi_mode = node.gi_mode
		chunk.extra_cull_margin = margin
		chunk.ignore_occlusion_culling = node.ignore_occlusion_culling
		chunk.transparency = node.transparency
		chunk.visibility_range_begin = node.visibility_range_begin
		chunk.visibility_range_end = node.visibility_range_end
		chunk.visibility_range_begin_margin = node.visibility_range_begin_margin
		chunk.visibility_range_end_margin = node.visibility_range_end_margin
		chunk.visibility_range_fade_mode = node.visibility_range_fade_mode
	# Keep the parent, transform and gameplay water-height references alive.
	state.controller.refresh()


func _slice_mesh(source: Array, columns: int, start: Vector2i, end: Vector2i) -> ArrayMesh:
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	var width := end.x - start.x + 1
	var depth := end.y - start.y + 1
	for slot in [Mesh.ARRAY_VERTEX, Mesh.ARRAY_NORMAL, Mesh.ARRAY_TANGENT, Mesh.ARRAY_TEX_UV, Mesh.ARRAY_TEX_UV2, Mesh.ARRAY_COLOR]:
		if source[slot] == null or source[slot].is_empty():
			continue
		var values: Variant = source[slot].slice(0, 0)
		var stride := 4 if slot == Mesh.ARRAY_TANGENT else 1
		for row in range(start.y, end.y + 1):
			var first := (row * (columns + 1) + start.x) * stride
			values.append_array(source[slot].slice(first, first + width * stride))
		arrays[slot] = values
	var indices := PackedInt32Array()
	indices.resize((width - 1) * (depth - 1) * 6)
	var source_indices: PackedInt32Array = source[Mesh.ARRAY_INDEX]
	var cursor := 0
	for z in range(depth - 1):
		for x in range(width - 1):
			var original := ((start.y + z) * columns + start.x + x) * 6
			for corner in range(6):
				var index := source_indices[original + corner]
				indices[cursor] = (index / (columns + 1) - start.y) * width + index % (columns + 1) - start.x
				cursor += 1
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh
