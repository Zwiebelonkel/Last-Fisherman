extends Node
# shader_warmup.gd
# Erstelle als Autoload: Project → Settings → Autoload

var shaders_ready: bool = false

func _ready():
	print("🔥 Shader Warmup startet...")
	_warmup_shaders()

func _warmup_shaders():
	# Erstelle temporäre Dummy-Objekte um Shader zu kompilieren
	var dummy_viewport = SubViewport.new()
	dummy_viewport.size = Vector2i(64, 64)
	add_child(dummy_viewport)
	
	# Lade alle kritischen Shader
	var shaders = [
		"res://shader/buckshot.gdshader",
		"res://shader/sky.gdshader", 
		"res://shader/shader_water.gdshader",
		"res://shader/2DShine.gdshader",
		"res://shader/2DShine.gdshader",
		"res://shader/2DShine.gdshader"
	]
	
	for shader_path in shaders:
		if ResourceLoader.exists(shader_path):
			var shader = load(shader_path)
			print("  ✅ Shader geladen:", shader_path)
	
	# Warte 2 Frames für GPU
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().physics_frame
	
	dummy_viewport.queue_free()
	shaders_ready = true
	print("✅ Alle Shader bereit!")
