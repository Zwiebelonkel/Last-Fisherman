extends HSlider
@export var audio_bus_name: String
var audio_bus_id

func _ready() -> void:
	audio_bus_id = AudioServer.get_bus_index(audio_bus_name)
	
	# Lade gespeicherten Wert
	match audio_bus_name:
		"Master":
			value = Player.master_volume
		"Music":
			value = Player.music_volume
		"SFX":
			value = Player.sfx_volume

func _on_value_changed(new_value: float) -> void:
	var db = linear_to_db(new_value)
	AudioServer.set_bus_volume_db(audio_bus_id, db)
	
	# Speichere Wert
	match audio_bus_name:
		"Master":
			Player.master_volume = new_value
		"Music":
			Player.music_volume = new_value
		"SFX":
			Player.sfx_volume = new_value
	
	Player.save_settings()
