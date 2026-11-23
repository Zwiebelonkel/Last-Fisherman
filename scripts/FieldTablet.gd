extends Node
## Reuse the scene's actual UI instances; gameplay references and signals stay valid.

const TABLET_SCENE := preload("res://scenes/FieldTablet.tscn")
const TabletView := preload("res://scripts/FieldTabletView.gd")

var _views: Dictionary = {}
var _scene_id: int = 0
var _tablet: TabletView
var _controller: Node
var _active_kind := ""
var _latest_kind := ""
var _sync_pending := false
var _closed_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_VISIBLE
var _escape_transient := false
var _restore_mouse_pending := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func register_view(instance_id: int, kind: String) -> void:
	var view := instance_from_id(instance_id) as Control
	if not is_instance_valid(view) or not view.is_inside_tree():
		return
	var scene := get_tree().current_scene
	if scene == null or view == scene or not scene.is_ancestor_of(view):
		return
	if scene.get_instance_id() != _scene_id:
		_views.clear()
		_tablet = null
		_controller = null
		_active_kind = ""
		_latest_kind = ""
		_restore_mouse_pending = false
		_escape_transient = false
		_scene_id = scene.get_instance_id()
	if not is_instance_valid(_tablet):
		_tablet = TABLET_SCENE.instantiate() as TabletView
		scene.add_child(_tablet)
	if _view(kind) == view:
		return
	_views[kind] = weakref(view)
	view.set_meta("tablet_screen", true)
	view.reparent(_tablet.screen_viewport, false)
	view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for selector: OptionButton in view.find_children("*", "OptionButton", true, false):
		_tablet.watch_popup(selector.get_popup())
	if kind == "fishbook":
		view.offset_left = 14
		view.offset_top = 14
		view.offset_right = -14
		view.offset_bottom = -14
	else:
		var close_button := view.get_node_or_null("close") as Control
		if close_button != null:
			close_button.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
			close_button.position = Vector2(TabletView.SCREEN_PIXELS.x - 46, 18)
			close_button.size = Vector2(30, 30)
	view.visibility_changed.connect(_on_visibility.bind(kind))
	_controller = _find_controller(scene)
	_on_visibility(kind)

func _view(kind: String) -> Control:
	var reference := _views.get(kind) as WeakRef
	return reference.get_ref() as Control if reference != null else null

func _find_controller(node: Node) -> Node:
	if node.has_method("open_fishbook") and node.has_method("open_inventory"):
		return node
	for child in node.get_children():
		var found := _find_controller(child)
		if found != null:
			return found
	return null

func _on_visibility(kind: String) -> void:
	var view := _view(kind)
	if view != null and view.visible:
		if not is_busy():
			_closed_mouse_mode = Input.mouse_mode
		_latest_kind = kind
	if not _sync_pending:
		_sync_pending = true
		_sync_views.call_deferred()

func _sync_views() -> void:
	_sync_pending = false
	if not is_instance_valid(_tablet):
		return
	var chosen := ""
	var latest := _view(_latest_kind)
	if latest != null and latest.visible:
		chosen = _latest_kind
	else:
		for kind: String in _views:
			var view := _view(kind)
			if view != null and view.visible:
				chosen = kind
				break
	if chosen.is_empty() and not _active_kind.is_empty():
		_restore_mouse_pending = true
	_active_kind = chosen
	if not chosen.is_empty():
		_restore_mouse_pending = false
		for kind: String in _views:
			var view := _view(kind)
			if kind != chosen and view != null and view.visible:
				view.hide()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_tablet.set_open(not chosen.is_empty())

func is_busy() -> bool:
	return is_instance_valid(_tablet) and _tablet.is_busy()

func _process(_delta: float) -> void:
	if not is_instance_valid(_tablet):
		_active_kind = ""
		return
	if _tablet.is_busy():
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif not _active_kind.is_empty():
		_active_kind = ""
	if not _tablet.is_busy() and _tablet.open_amount == 0.0 and _tablet.visible == false:
		if _restore_mouse_pending:
			_restore_mouse_pending = false
			var options: Control = _controller.get("options") if is_instance_valid(_controller) else null
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if options != null and options.visible else _closed_mouse_mode

func close_active() -> void:
	var view := _view(_active_kind)
	if view == null:
		return
	var method := "close_fishbook" if _active_kind == "fishbook" else "close_inventory"
	if is_instance_valid(_controller) and _controller.has_method(method):
		_controller.call(method)
	else:
		view.hide()
	_restore_mouse_pending = true

func _input(event: InputEvent) -> void:
	if not is_busy():
		return
	get_viewport().set_input_as_handled()
	if not _tablet.target_open:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# Test against the actual tilted 3D display, using the same projection as UI input.
		var point := _tablet.screen_position(event.position)
		if not Rect2(Vector2.ZERO, Vector2(TabletView.SCREEN_PIXELS)).has_point(point):
			close_active()
			return
	if event is InputEventKey:
		var key := event as InputEventKey
		if key.keycode == KEY_ESCAPE or key.is_action("pause"):
			if key.pressed and not key.echo:
				var book := _view("fishbook")
				var popup: Control = book.get("detail_popup") if book != null else null
				var selector: OptionButton = book.get("location_selector") if book != null else null
				var dropdown: PopupMenu = selector.get_popup() if selector != null else null
				_escape_transient = false
				if _active_kind == "fishbook" and dropdown != null and dropdown.visible:
					_escape_transient = true
					dropdown.hide()
				elif _active_kind == "fishbook" and popup != null and popup.visible:
					_escape_transient = true
					_tablet.forward_input(event)
			elif not key.pressed:
				if not _escape_transient:
					close_active()
				_escape_transient = false
			return
		if key.pressed and not key.echo:
			if key.is_action("journal") or key.is_action("inventory_toggle"):
				var method := "toggle_fishbook" if key.is_action("journal") else "toggle_inventory"
				if is_instance_valid(_controller) and _controller.has_method(method):
					_controller.call(method)
				return
	_tablet.forward_input(event)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_views.clear()
