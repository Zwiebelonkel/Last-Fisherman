extends Node
## One download queue for both hub views. Steam callbacks contain no filter ID,
## so filters must be associated with the request that actually started them.

signal entries_updated(board: String, mode: int, entries: Array)
signal state_changed(board: String, mode: int, message_key: String)
signal player_names_updated

const DOWNLOAD_TIMEOUT_MSEC := 12000
const WAIT_TIMEOUT_MSEC := 60000
const MAX_ATTEMPTS := 3
const CACHE_AGE_MSEC := 30000

var _cache: Dictionary = {}
var _states: Dictionary = {}
var _queue: Array[Dictionary] = []
var _active: Dictionary = {}
var _waiting_names: Dictionary = {}
var _api: Object

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	GodotSteam.leaderboards_loaded.connect(_on_steam_ready)

func _connect_api() -> void:
	if _api != null or GodotSteam.steam_api == null:
		return
	_api = GodotSteam.steam_api
	_api.leaderboard_scores_downloaded.connect(_on_downloaded)
	_api.persona_state_change.connect(_on_persona_changed)

func _process(_delta: float) -> void:
	_connect_api()
	var now := Time.get_ticks_msec()
	if not _active.is_empty() and now >= int(_active.deadline):
		_retry_download()
	if not _active.is_empty() or _queue.is_empty():
		return
	var request: Dictionary = _queue[0]
	if not GodotSteam.steam_ready:
		if GodotSteam.initialization_complete or now >= int(request.wait_deadline):
			_queue.pop_front()
			_set_state(request, "LEADERBOARD_STEAM_UNAVAILABLE")
		return
	var handle := int(GodotSteam.leaderboards.get(request.board, 0))
	if handle <= 0:
		if GodotSteam.initialization_complete or now >= int(request.wait_deadline):
			_queue.pop_front()
			_set_state(request, "LEADERBOARD_UNAVAILABLE")
		else:
			_queue.append(_queue.pop_front())
		return
	if now < int(request.retry_at):
		_queue.append(_queue.pop_front())
		return
	_queue.pop_front()
	_active = request
	_active.handle = handle
	_active.deadline = now + DOWNLOAD_TIMEOUT_MSEC
	_active.attempts = int(_active.attempts) + 1
	_set_state(_active, "LEADERBOARD_LOADING")
	var count: int = _active.count
	var start := 1
	var end := count
	if int(_active.mode) == Steam.LEADERBOARD_DATA_REQUEST_GLOBAL_AROUND_USER:
		start = -floori(float(count) / 2.0)
		end = start + count - 1
	_api.downloadLeaderboardEntries(start, end, int(_active.mode), handle)

func request_board(board: String, mode: int, force := false, count := 10) -> void:
	if board not in GodotSteam.LEADERBOARD_NAMES:
		return
	count = clampi(count, 1, 100)
	var key := cache_key(board, mode)
	if not force and _cache.has(key):
		var cached: Dictionary = _cache[key]
		if Time.get_ticks_msec() - int(cached.time) < CACHE_AGE_MSEC and int(cached.count) >= count:
			entries_updated.emit(board, mode, cached.entries)
			return
	if not _active.is_empty() and _active.key == key and int(_active.count) >= count:
		return
	for queued in _queue:
		if queued.key == key:
			queued.count = maxi(int(queued.count), count)
			return
	var request := {
		"key": key, "board": board, "mode": mode, "count": count,
		"attempts": 0, "retry_at": 0,
		"wait_deadline": Time.get_ticks_msec() + WAIT_TIMEOUT_MSEC,
	}
	_queue.append(request)
	_set_state(request, "LEADERBOARD_LOADING" if GodotSteam.steam_ready else "LEADERBOARD_WAITING_STEAM")
	if GodotSteam.steam_ready and int(GodotSteam.leaderboards.get(board, 0)) <= 0:
		GodotSteam.ensure_leaderboards()

func has_cached(board: String, mode: int) -> bool:
	return _cache.has(cache_key(board, mode))

func get_entries(board: String, mode: int) -> Array:
	return _cache.get(cache_key(board, mode), {}).get("entries", [])

func get_state(board: String, mode: int) -> String:
	return _states.get(cache_key(board, mode), "LEADERBOARD_WAITING_STEAM")

func cache_key(board: String, mode: int) -> String:
	return "%s:%d" % [board, mode]

func _set_state(request: Dictionary, message_key: String) -> void:
	_states[request.key] = message_key
	state_changed.emit(request.board, int(request.mode), message_key)

func _on_downloaded(_message: String, handle: int, entries: Array) -> void:
	if _active.is_empty():
		return
	if handle <= 0:
		_retry_download()
		return
	if handle != int(_active.handle):
		return
	var request := _active
	_active = {}
	var rows := entries.duplicate(true)
	rows.sort_custom(func(a: Dictionary, b: Dictionary): return int(a.get("global_rank", 0)) < int(b.get("global_rank", 0)))
	rows = rows.slice(0, int(request.count))
	_cache[request.key] = {"entries": rows, "count": request.count, "time": Time.get_ticks_msec()}
	_set_state(request, "LEADERBOARD_NO_ENTRIES" if rows.is_empty() else "")
	for entry: Dictionary in rows:
		var steam_id := int(entry.get("steam_id", 0))
		if steam_id > 0 and not _waiting_names.has(steam_id):
			_waiting_names[steam_id] = true
			if not _api.requestUserInformation(steam_id, true):
				_waiting_names.erase(steam_id)
	entries_updated.emit(request.board, int(request.mode), rows)

func _retry_download() -> void:
	var request := _active
	_active = {}
	if int(request.attempts) < MAX_ATTEMPTS:
		request.retry_at = Time.get_ticks_msec() + 500
		_queue.append(request)
	else:
		_set_state(request, "LEADERBOARD_UNAVAILABLE")

func player_name(steam_id: int) -> String:
	if _api != null and steam_id > 0:
		var value: String = _api.getFriendPersonaName(steam_id)
		if not value.is_empty() and value not in ["[unknown]", "[unassigned]"]:
			return value
	return tr("LEADERBOARD_UNKNOWN_PLAYER")

func _on_persona_changed(steam_id: int, _flags: int) -> void:
	if _waiting_names.has(steam_id):
		var value: String = _api.getFriendPersonaName(steam_id)
		if not value.is_empty() and value not in ["[unknown]", "[unassigned]"]:
			_waiting_names.erase(steam_id)
		player_names_updated.emit()

func _on_steam_ready() -> void:
	if not GodotSteam.steam_ready:
		return
	# Requests made before a delayed Steam login get another chance.
	for key: String in _states.keys():
		if _states[key] in ["LEADERBOARD_STEAM_UNAVAILABLE", "LEADERBOARD_WAITING_STEAM"]:
			var parts := key.split(":")
			request_board(parts[0], int(parts[1]))
