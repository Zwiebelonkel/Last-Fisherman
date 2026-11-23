extends CanvasLayer
## Actual 3D housing with the existing Controls rendered onto its screen.

const SCREEN_SIZE := Vector2(2.30, 1.4375)
const SCREEN_PIXELS := Vector2i(1024, 640)
const SCREEN_SHADER := preload("res://shader/tablet_screen.gdshader")
const FONT := preload("res://fonts/VCR_OSD_MONO_1.001.ttf")

@export_group("Tablet Pose")
## Neutral orientation after the opening animation, in degrees.
@export var resting_rotation_degrees := Vector3.ZERO

@export_group("Mouse Tilt")
@export var mouse_tilt_enabled := true
## Maximum turn towards the left/right side of the window.
@export_range(0.0, 20.0, 0.1) var mouse_tilt_horizontal_degrees := 4.0
## Maximum turn towards the top/bottom of the window.
@export_range(0.0, 20.0, 0.1) var mouse_tilt_vertical_degrees := 3.0
## Higher values follow the cursor faster, independently of game time scale.
@export_range(0.1, 30.0, 0.1) var mouse_tilt_follow_speed := 9.0
## Fraction of the distance from the window centre to its edge needed for full tilt.
@export_range(0.1, 1.0, 0.01) var mouse_tilt_range := 0.85
## Central area where the tablet stays straight, as a fraction of the tilt range.
@export_range(0.0, 0.5, 0.01) var mouse_tilt_dead_zone := 0.05

@export_group("Background Blur")
@export var background_blur_enabled := true
## Blur radius in window pixels; the tablet and its interface stay sharp.
@export_range(0.0, 48.0, 0.5) var background_blur_pixels := 18.0
## Resolution of the additional world camera relative to the game window.
@export_range(0.25, 1.0, 0.05) var background_capture_scale := 0.5

@onready var screen_viewport: SubViewport = $ScreenViewport
@onready var render_viewport: SubViewport = $RenderContainer/RenderViewport
@onready var render_container: SubViewportContainer = $RenderContainer
@onready var camera: Camera3D = $RenderContainer/RenderViewport/Camera3D
@onready var pivot: Node3D = $RenderContainer/RenderViewport/Tablet
@onready var dimmer: ColorRect = $Dimmer
@onready var background: TextureRect = $BlurredBackground
@onready var background_viewport: SubViewport = $BackgroundViewport
@onready var background_camera: Camera3D = $BackgroundViewport/Camera3D
@onready var background_blur_viewport: SubViewport = $BackgroundBlurViewport
@onready var background_camera_image: TextureRect = $BackgroundBlurViewport/CameraImage

var screen_mesh: MeshInstance3D
var open_amount := 0.0
var target_open := false
var _last_tick: int = 0
var _mouse_inside := false
var _last_screen_position := Vector2.ZERO
var _pressed_buttons := 0
var _mouse_tilt_degrees := Vector3.ZERO
var _window_mouse_position := Vector2.ZERO

func _ready() -> void:
	screen_viewport.size = SCREEN_PIXELS
	_window_mouse_position = get_viewport().get_mouse_position()
	_build_tablet()
	background_camera_image.texture = background_viewport.get_texture()
	background.texture = background_blur_viewport.get_texture()
	_set_background_active(false)
	get_viewport().size_changed.connect(_resize_camera)
	_resize_camera()
	_last_tick = Time.get_ticks_usec()
	_apply_pose()
	hide()
	screen_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	render_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED

func set_open(value: bool) -> void:
	if value and not is_busy():
		_mouse_tilt_degrees = Vector3.ZERO
	target_open = value
	if value:
		_update_background()
		show()
		screen_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		render_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	else:
		_release_mouse_buttons()

func is_busy() -> bool:
	return target_open or open_amount > 0.0

func _input(event: InputEvent) -> void:
	# Keep tilt and screen hit testing in the same window coordinate space.
	if event is InputEventMouse:
		_window_mouse_position = event.position

func _process(_delta: float) -> void:
	var now := Time.get_ticks_usec()
	var delta := minf(float(now - _last_tick) / 1000000.0, 0.1)
	_last_tick = now
	if not is_busy():
		return
	open_amount = move_toward(open_amount, 1.0 if target_open else 0.0, delta / 0.46)
	_update_background()
	_update_mouse_tilt(delta)
	_apply_pose()
	if not target_open and open_amount == 0.0:
		hide()
		if _mouse_inside:
			screen_viewport.notify_mouse_exited()
		_mouse_inside = false
		_mouse_tilt_degrees = Vector3.ZERO
		_set_background_active(false)
		screen_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
		render_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED

func _set_background_active(active: bool) -> void:
	background.visible = active
	var mode := SubViewport.UPDATE_ALWAYS if active else SubViewport.UPDATE_DISABLED
	background_viewport.render_target_update_mode = mode
	background_blur_viewport.render_target_update_mode = mode

func _update_background() -> void:
	var source := get_viewport().get_camera_3d()
	if not background_blur_enabled or not is_instance_valid(source):
		_set_background_active(false)
		return
	# A separate camera shares the active map, never the tablet's isolated 3D world.
	if background_viewport.world_3d != source.get_world_3d():
		background_viewport.world_3d = source.get_world_3d()
	background_camera.global_transform = source.global_transform
	background_camera.projection = source.projection
	background_camera.keep_aspect = source.keep_aspect
	background_camera.fov = source.fov
	background_camera.size = source.size
	background_camera.frustum_offset = source.frustum_offset
	background_camera.near = source.near
	background_camera.far = source.far
	background_camera.h_offset = source.h_offset
	background_camera.v_offset = source.v_offset
	background_camera.cull_mask = source.cull_mask
	background_camera.environment = source.environment
	background_camera.attributes = source.attributes
	var window_size := get_viewport().get_visible_rect().size
	var capture_size := Vector2i((window_size * clampf(background_capture_scale, 0.25, 1.0)).max(Vector2.ONE))
	if background_viewport.size != capture_size:
		background_viewport.size = capture_size
		background_blur_viewport.size = capture_size
	var horizontal := background_camera_image.material as ShaderMaterial
	var vertical := background.material as ShaderMaterial
	horizontal.set_shader_parameter("radius_pixels", background_blur_pixels * float(capture_size.x) / maxf(window_size.x, 1.0))
	vertical.set_shader_parameter("radius_pixels", background_blur_pixels * float(capture_size.y) / maxf(window_size.y, 1.0))
	_set_background_active(true)

func _update_mouse_tilt(delta: float) -> void:
	var target := Vector3.ZERO
	if mouse_tilt_enabled and target_open:
		# Use the fixed window centre so the moving mesh cannot feed back into its tilt.
		var rect := render_container.get_global_rect()
		var half_range := rect.size * 0.5 * maxf(mouse_tilt_range, 0.1)
		var offset := _window_mouse_position - rect.get_center()
		var horizontal := _tilt_axis(offset.x / maxf(half_range.x, 1.0))
		var vertical := _tilt_axis(offset.y / maxf(half_range.y, 1.0))
		# Positive X looks down; positive Y looks right. Roll remains neutral.
		target = Vector3(vertical * mouse_tilt_vertical_degrees, horizontal * mouse_tilt_horizontal_degrees, 0.0)
	var weight := 1.0 - exp(-maxf(mouse_tilt_follow_speed, 0.1) * delta)
	_mouse_tilt_degrees = _mouse_tilt_degrees.lerp(target, weight)

func _tilt_axis(value: float) -> float:
	var dead_zone := clampf(mouse_tilt_dead_zone, 0.0, 0.5)
	return signf(value) * clampf((absf(value) - dead_zone) / (1.0 - dead_zone), 0.0, 1.0)

func _apply_pose() -> void:
	var eased := 1.0 - pow(1.0 - open_amount, 3.0)
	pivot.position = Vector3(0.06, -2.05, -0.18).lerp(Vector3.ZERO, eased)
	pivot.rotation_degrees = Vector3(82.0, -11.0, -8.0).lerp(resting_rotation_degrees + _mouse_tilt_degrees, eased)
	background.modulate.a = eased
	dimmer.color.a = eased * 0.18

func _resize_camera() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	var aspect := viewport_size.x / maxf(viewport_size.y, 1.0)
	# Keep the entire physical tablet in view in both wide and narrow windows.
	camera.position.z = maxf(2.55, 1.48 / maxf(aspect, 0.1) / tan(deg_to_rad(camera.fov * 0.5)))

func screen_position(window_position: Vector2, allow_outside := false) -> Vector2:
	var local_mouse := (window_position - render_container.global_position) / render_container.size * Vector2(render_viewport.size)
	var ray_origin := camera.project_ray_origin(local_mouse)
	var ray_direction := camera.project_ray_normal(local_mouse)
	var plane := Plane(screen_mesh.global_basis.z.normalized(), screen_mesh.global_position)
	var hit: Variant = plane.intersects_ray(ray_origin, ray_direction)
	if hit == null:
		return Vector2(-1, -1)
	var point: Vector3 = screen_mesh.to_local(hit)
	var uv := Vector2(point.x / SCREEN_SIZE.x + 0.5, 0.5 - point.y / SCREEN_SIZE.y)
	if not allow_outside and (uv.x < 0.0 or uv.x > 1.0 or uv.y < 0.0 or uv.y > 1.0):
		return Vector2(-1, -1)
	return uv * Vector2(SCREEN_PIXELS)

func window_position(screen_point: Vector2) -> Vector2:
	var uv := screen_point / Vector2(SCREEN_PIXELS)
	var point := screen_mesh.to_global(Vector3((uv.x - 0.5) * SCREEN_SIZE.x, (0.5 - uv.y) * SCREEN_SIZE.y, 0.0))
	return camera.unproject_position(point) / Vector2(render_viewport.size) * render_container.size + render_container.global_position

func forward_input(event: InputEvent) -> void:
	if event is InputEventMouse:
		var mouse := event as InputEventMouse
		_window_mouse_position = mouse.position
		var point := screen_position(mouse.position, true)
		var inside := Rect2(Vector2.ZERO, Vector2(SCREEN_PIXELS)).has_point(point) and open_amount >= 0.99
		if inside != _mouse_inside:
			_mouse_inside = inside
			if inside:
				screen_viewport.notify_mouse_entered()
			else:
				screen_viewport.notify_mouse_exited()
		if not inside and _pressed_buttons == 0:
			return
		if mouse is InputEventMouseButton:
			var button := mouse as InputEventMouseButton
			if button.pressed and not inside:
				return
			if button.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE, MOUSE_BUTTON_XBUTTON1, MOUSE_BUTTON_XBUTTON2]:
				var mask := 1 << (int(button.button_index) - 1)
				if button.pressed:
					_pressed_buttons |= mask
				else:
					_pressed_buttons &= ~mask
		var forwarded := mouse.duplicate() as InputEventMouse
		forwarded.position = point
		forwarded.global_position = point
		forwarded.button_mask = _pressed_buttons
		if forwarded is InputEventMouseMotion:
			forwarded.relative = point - _last_screen_position
		_last_screen_position = point
		screen_viewport.push_input(forwarded, true)
	elif event is InputEventKey:
		screen_viewport.push_input(event.duplicate(), true)

func watch_popup(popup: PopupMenu) -> void:
	if not popup.popup_hide.is_connected(_on_popup_hidden):
		popup.popup_hide.connect(_on_popup_hidden, CONNECT_DEFERRED)

func _on_popup_hidden() -> void:
	# The embedded popup receives the opener's release instead of the UI viewport.
	# Clear that mouse capture once the popup has actually left the input path.
	_release_mouse_buttons(true)

func _release_mouse_buttons(release_opener := false) -> void:
	# A drag may end beyond the screen or while the device is being lowered.
	for button in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE, MOUSE_BUTTON_XBUTTON1, MOUSE_BUTTON_XBUTTON2]:
		if (_pressed_buttons & (1 << (int(button) - 1))) or (release_opener and button == MOUSE_BUTTON_LEFT):
			var release := InputEventMouseButton.new()
			release.button_index = button
			release.position = _last_screen_position
			release.global_position = _last_screen_position
			screen_viewport.push_input(release, true)
	_pressed_buttons = 0

func _material(color: Color, metallic := 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = metallic
	material.roughness = 0.82
	return material

func _mesh(mesh: Mesh, material: Material, position: Vector3) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	instance.position = position
	pivot.add_child(instance)
	return instance

func _box(size: Vector3, position: Vector3, material: Material) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	return _mesh(mesh, material, position)

func _plate(width: float, height: float, depth: float, radius: float, material: Material, position := Vector3.ZERO) -> void:
	# Rounded extruded silhouette, including bevelled edges and real side walls.
	var outline: Array[Vector2] = []
	for corner in range(4):
		var center := Vector2(width * 0.5 - radius, height * 0.5 - radius)
		if corner in [1, 2]: center.x = -center.x
		if corner in [2, 3]: center.y = -center.y
		for segment in range(9):
			var angle := float(corner) * PI * 0.5 + float(segment) / 8.0 * PI * 0.5
			outline.append(center + Vector2(cos(angle), sin(angle)) * radius)
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(outline.size()):
		var a := outline[i]
		var b := outline[(i + 1) % outline.size()]
		for z in [-depth * 0.5, depth * 0.5]:
			var normal := Vector3.BACK if z > 0 else Vector3.FORWARD
			var triangle: Array = [Vector2.ZERO, b, a] if z > 0 else [Vector2.ZERO, a, b]
			for p: Vector2 in triangle:
				surface.set_normal(normal)
				surface.set_uv(Vector2(p.x / width + 0.5, p.y / height + 0.5))
				surface.add_vertex(Vector3(p.x, p.y, z))
		var a_front := Vector3(a.x * 0.99, a.y * 0.99, depth * 0.5)
		var b_front := Vector3(b.x * 0.99, b.y * 0.99, depth * 0.5)
		var a_back := Vector3(a.x, a.y, -depth * 0.5)
		var b_back := Vector3(b.x, b.y, -depth * 0.5)
		for p: Vector3 in [a_front, a_back, b_front, b_front, a_back, b_back]:
			surface.set_normal(Vector3(a.x / width, a.y / height, 0.0).normalized())
			surface.set_uv(Vector2(p.x / width + 0.5, p.y / height + 0.5))
			surface.add_vertex(p)
	_mesh(surface.commit(), material, position)

func _build_tablet() -> void:
	var worn := _material(Color("808080"))
	var rubber := _material(Color("252720"))
	rubber.cull_mode = BaseMaterial3D.CULL_DISABLED
	var black := _material(Color("080b09"))
	black.cull_mode = BaseMaterial3D.CULL_DISABLED
	var steel := _material(Color("777467"), 0.7)
	_plate(2.67, 1.82, 0.13, 0.14, rubber)
	_plate(2.59, 1.75, 0.035, 0.11, worn, Vector3(0, 0, 0.071))
	_plate(2.39, 1.53, 0.026, 0.05, black, Vector3(0, 0.045, 0.098))
	var display_material := ShaderMaterial.new()
	display_material.shader = SCREEN_SHADER
	display_material.set_shader_parameter("screen_texture", screen_viewport.get_texture())
	var quad := QuadMesh.new()
	quad.size = SCREEN_SIZE
	screen_mesh = _mesh(quad, display_material, Vector3(0, 0.045, 0.114))
	screen_mesh.name = "TabletScreen"
	for x in [-1.225, 1.225]:
		for y in [-0.79, 0.79]:
			var screw := CylinderMesh.new()
			screw.top_radius = 0.024
			screw.bottom_radius = 0.024
			screw.height = 0.008
			var bolt := _mesh(screw, steel, Vector3(x, y, 0.096))
			bolt.rotation.x = PI * 0.5
			var slot := _box(Vector3(0.028, 0.005, 0.002), Vector3(x, y, 0.102), black)
			slot.rotation.z = x + y
	for i in range(7):
		_box(Vector3(0.012, 0.026, 0.004), Vector3((i - 3) * 0.027, 0.827, 0.095), black)
	_box(Vector3(0.026, 0.17, 0.04), Vector3(1.34, 0.4, 0.0), steel)
	_box(Vector3(0.026, 0.1, 0.04), Vector3(1.34, 0.18, 0.0), rubber)
	var brand := Label3D.new()
	brand.text = ""
	brand.font = FONT
	brand.font_size = 40
	brand.pixel_size = 0.0007
	brand.modulate = Color("9b9d84")
	brand.outline_size = 0
	brand.no_depth_test = false
	brand.position = Vector3(-0.34, -0.8, 0.098)
	pivot.add_child(brand)
