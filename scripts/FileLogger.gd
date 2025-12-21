extends Node
# Autoload: FileLogger

const LOG_FILE = "user://steam_debug.log"
var file: FileAccess = null

func _ready():
	file = FileAccess.open(LOG_FILE, FileAccess.WRITE)
	if file:
		log_msg("========================================")
		log_msg("STEAM DEBUG LOG")
		log_msg("Zeit: " + Time.get_datetime_string_from_system())
		log_msg("Executable: " + OS.get_executable_path())
		log_msg("User Data: " + OS.get_user_data_dir())
		log_msg("========================================")
	else:
		push_error("❌ Konnte Log-Datei nicht öffnen!")

func log_msg(message: String) -> void:
	if file:
		var timestamp := Time.get_ticks_msec()
		var line := "[%d] %s" % [timestamp, message]
		file.store_line(line)
		file.flush()
		print(line)
		
func log(message: String) -> void:
	log_msg(message)
	
func _exit_tree():
	if file:
		log_msg("========================================")
		log_msg("APPLICATION EXIT")
		log_msg("========================================")
		file.close()

func _notification(what: int):
	if what == NOTIFICATION_CRASH and file:
		log_msg("❌❌❌ CRASH DETECTED ❌❌❌")
		file.flush()
