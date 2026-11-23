extends Node
## Keep likely next scenes alive without instantiating gameplay in the background.
## Only one speculative request runs at a time; travel requests start immediately.

const MENU := "res://scenes/mainMenu.tscn"
const BEACH := "res://scenes/MainScene.tscn"
const MAP := "res://scenes/MapScene.tscn"
const SHOP := "res://scenes/shop_inside.tscn"
const LOCATION_SCENES := {
	"lake": BEACH,
	"city": "res://scenes/city.tscn",
	"sewer": "res://scenes/sewer.tscn",
	"forest": "res://scenes/forest.tscn",
	"desert": "res://scenes/ödland.tscn",
	"iceland": "res://scenes/iceland.tscn",
	"home": "res://scenes/hub.tscn",
	"van": "res://scenes/fischbude.tscn",
}

var _cache: Dictionary = {}
var _requests: Dictionary = {}
var _failures: Dictionary = {}
var _queue: Array[String] = []
var _wanted: Array[String] = []
var _context_path := ""
var _context_id: int = 0
var _destination := ""
var _foreground_path := ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(_delta: float) -> void:
	_sync_context()

	for path: String in _requests.keys():
		var status := ResourceLoader.load_threaded_get_status(path)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			# Calling get before LOADED would block the main thread.
			var packed := ResourceLoader.load_threaded_get(path) as PackedScene
			_requests.erase(path)
			if packed == null:
				_failures[path] = ERR_FILE_CORRUPT
				push_warning("Background scene is not a PackedScene: " + path)
			elif _should_keep(path):
				_cache[path] = packed
				print("[ScenePreloader] Ready: ", path)
		elif status != ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			_requests.erase(path)
			_failures[path] = ERR_CANT_OPEN
			push_warning("Could not load scene in background: " + path)

	# Finish obsolete requests too, but discard their resources instead of
	# accumulating every visited biome in RAM.
	if _requests.is_empty() and not _queue.is_empty():
		_begin_request(_queue.pop_front())


func _sync_context() -> void:
	var current := get_tree().current_scene
	if is_instance_valid(current) and current.is_node_ready():
		if current.get_instance_id() != _context_id:
			_context_id = current.get_instance_id()
			_context_path = current.scene_file_path
			_destination = ""
			if _foreground_path == _context_path:
				_foreground_path = ""
			# Retain the scene being left for an immediate map -> back trip.
			var packed := ResourceLoader.get_cached_ref(_context_path) as PackedScene
			if packed != null:
				_cache[_context_path] = packed
			_update_plan()


func request_scene(path: String) -> Error:
	_foreground_path = path
	_queue.erase(path)
	# A deliberate retry may recover from a failed speculative request.
	_failures.erase(path)
	return _begin_request(path)


func get_scene_status(path: String, progress: Array = []) -> int:
	progress.clear()
	if _cache.has(path):
		progress.append(1.0)
		return ResourceLoader.THREAD_LOAD_LOADED
	if _failures.has(path):
		return ResourceLoader.THREAD_LOAD_FAILED
	if _requests.has(path):
		# Only advertise LOADED once _process has collected and retained it.
		var status := ResourceLoader.load_threaded_get_status(path, progress)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			return ResourceLoader.THREAD_LOAD_IN_PROGRESS
		return status
	if path in _queue:
		progress.append(0.0)
		return ResourceLoader.THREAD_LOAD_IN_PROGRESS
	return ResourceLoader.THREAD_LOAD_INVALID_RESOURCE


func get_scene(path: String) -> PackedScene:
	return _cache.get(path) as PackedScene


func finish_request(path: String) -> void:
	# A transition resumes on process_frame before this node's next _process.
	# Observe the new scene before trimming its PackedScene reference.
	_sync_context()
	if _foreground_path == path:
		_foreground_path = ""
	_trim_cache()


func prefetch_destination(path: String) -> void:
	if _context_path != MAP or path == _destination:
		return
	_destination = path
	_update_plan()


func _begin_request(path: String) -> Error:
	if _cache.has(path) or _requests.has(path):
		return OK
	var cached := ResourceLoader.get_cached_ref(path) as PackedScene
	if cached != null:
		_cache[path] = cached
		return OK
	if not ResourceLoader.exists(path, "PackedScene"):
		_failures[path] = ERR_FILE_NOT_FOUND
		return ERR_FILE_NOT_FOUND
	# Extra subthreads can compete with rendering; keep speculative loading light.
	var error := ResourceLoader.load_threaded_request(path, "PackedScene", false)
	if error == OK:
		_requests[path] = true
		print("[ScenePreloader] Loading: ", path)
	else:
		_failures[path] = error
	return error


func _update_plan() -> void:
	_wanted.clear()
	match _context_path:
		"res://scenes/SplashScreen.tscn":
			_wanted.assign([MENU])
		MENU:
			_wanted.assign([Player.last_scene, MAP, "res://scenes/credits.tscn"])
		MAP:
			if not _destination.is_empty():
				_wanted.append(_destination)
			_wanted.append(Player.last_scene)
			_wanted.append(MENU)
		SHOP:
			_wanted.assign([Player.last_scene, MAP, MENU])
		"res://scenes/event_echo.tscn":
			_wanted.assign(["res://scenes/NoteView.tscn", MAP, MENU])
		"res://scenes/NoteView.tscn":
			_wanted.assign(["res://scenes/dialog1.tscn", MAP])
		"res://scenes/dialog1.tscn", "res://scenes/dialog2.tscn":
			_wanted.assign([MAP])
		"res://scenes/ending.tscn":
			_wanted.assign(["res://scenes/decision.tscn", MAP])
		"res://scenes/decision.tscn":
			_wanted.assign(["res://scenes/endingScreen.tscn"])
		"res://scenes/endingScreen.tscn", "res://scenes/credits.tscn":
			_wanted.assign([MENU])
		_:
			if _context_path in LOCATION_SCENES.values():
				_wanted.assign([MAP, MENU])
				if _context_path in [BEACH, LOCATION_SCENES.city, LOCATION_SCENES.sewer,
						LOCATION_SCENES.forest, LOCATION_SCENES.desert, LOCATION_SCENES.iceland]:
					_wanted.insert(1, SHOP)
			elif _context_path == "res://scenes/void.tscn":
				_wanted.assign([MAP])

	_queue.clear()
	for path in _wanted:
		if path != _context_path and not _cache.has(path) and not _requests.has(path):
			if not _failures.has(path) and path not in _queue:
				_queue.append(path)
	_trim_cache()


func _should_keep(path: String) -> bool:
	return path == _context_path or path == _foreground_path or path in _wanted


func _trim_cache() -> void:
	for path: String in _cache.keys():
		if not _should_keep(path):
			_cache.erase(path)
