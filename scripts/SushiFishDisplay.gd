extends Control
## Stable slices of one fish: add cuts without repartitioning existing pieces.

const MAX_PIECES: int = 8
const GAP: float = 9.0

var texture: Texture2D
var source_rect: Rect2
var cut_count: int = 0
var _gap: float = 0.0
var _cut_flash: float = 0.0
var _board: StyleBoxFlat


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_board = StyleBoxFlat.new()
	_board.bg_color = Color("493629")
	_board.border_color = Color("8e6c46")
	_board.set_border_width_all(2)
	_board.set_corner_radius_all(7)
	resized.connect(queue_redraw)


func set_fish(value: Texture2D) -> void:
	texture = value
	cut_count = 0
	_gap = 0.0
	_cut_flash = 0.0
	if texture != null:
		var image := texture.get_image()
		if image != null:
			if image.is_compressed():
				image.decompress()
			source_rect = Rect2(image.get_used_rect())
		else:
			source_rect = Rect2(Vector2.ZERO, texture.get_size())
	queue_redraw()


func set_cut_count(value: int) -> void:
	value = clampi(value, 0, MAX_PIECES - 1)
	if value == cut_count:
		return
	cut_count = value
	_cut_flash = 1.0
	queue_redraw()


func _process(delta: float) -> void:
	var target_gap := GAP if cut_count > 0 else 0.0
	if is_equal_approx(_gap, target_gap) and _cut_flash <= 0.0:
		return
	_gap = lerpf(_gap, target_gap, 1.0 - exp(-18.0 * delta))
	_cut_flash = maxf(0.0, _cut_flash - delta * 6.0)
	queue_redraw()


func get_piece_rects() -> Array[Rect2]:
	var result: Array[Rect2] = []
	var start := source_rect.position.x
	for i in range(cut_count + 1):
		var end := source_rect.end.x if i == cut_count else source_rect.position.x + source_rect.size.x * float(i + 1) / MAX_PIECES
		result.append(Rect2(start, source_rect.position.y, end - start, source_rect.size.y))
		start = end
	return result


func _draw() -> void:
	if _board != null:
		draw_style_box(_board, Rect2(Vector2.ZERO, size))
	if texture == null or source_rect.size.x <= 0.0 or source_rect.size.y <= 0.0:
		return
	# Reserve gap space up front so slices never shrink as more cuts are made.
	var zoom := minf(maxf(1.0, size.x - 28.0 - GAP * (MAX_PIECES - 1)) / source_rect.size.x, maxf(1.0, size.y - 26.0) / source_rect.size.y)
	var total_width := source_rect.size.x * zoom + _gap * cut_count
	var origin := Vector2((size.x - total_width) * 0.5, (size.y - source_rect.size.y * zoom) * 0.5)
	var pieces := get_piece_rects()
	for i in range(pieces.size()):
		var piece: Rect2 = pieces[i]
		var destination := Rect2(origin + Vector2((piece.position.x - source_rect.position.x) * zoom + _gap * i, 0.0), piece.size * zoom)
		draw_texture_rect_region(texture, Rect2(destination.position + Vector2(0.0, 3.0), destination.size), piece, Color(0.0, 0.0, 0.0, 0.3))
		draw_texture_rect_region(texture, destination, piece)
		if _cut_flash > 0.0 and i == cut_count - 1:
			var x := destination.end.x + _gap * 0.5
			draw_line(Vector2(x, 10.0), Vector2(x, size.y - 10.0), Color(1.0, 0.93, 0.75, _cut_flash * 0.8), 2.0)
