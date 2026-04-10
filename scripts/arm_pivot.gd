extends Node2D

@onready var arm:        Sprite2D          = $Arm
@onready var barrel_end: Node2D            = $BarrelEnd
@onready var shot:       AudioStreamPlayer = $"../shot"
@onready var hitbox:     Area2D            = $"../hitbox"
@onready var body:       Sprite2D          = $"../Body"
@onready var music:      AudioStreamPlayer = $"../music"
@onready var music2:     AudioStreamPlayer = $"../music2"
@onready var headshot:   AudioStreamPlayer = $"../headshot"

@onready var bad_ending:   AnimatedSprite2D = $"../BadEnding"
@onready var bad_ending2:  AnimatedSprite2D = $"../BadEnding2"
@onready var good_ending:  Sprite2D = $"../GoodEnding"
@onready var good_ending2: AnimatedSprite2D = $"../GoodEnding2"
@onready var good_ending3: AnimatedSprite2D = $"../GoodEnding3"

const VCR_FONT_PATH: String = "res://fonts/VCR_OSD_MONO_1.001.ttf"
const NEXT_SCENE:    String = "res://scenes/endingScreen.tscn"
const SCENE_DELAY:   float  = 4.0

var localized_texts := {
	"bad_text": {
		"de":
"Es war nie jemand da.\nKein Gegner. Kein Fremder. Kein Ausweg.\n\n" +
"Nur du.\nVon Anfang an.\n\n" +
"Du hast gekämpft…\ngegen etwas, das dich nie verlassen hat.\n\n" +
"Dein Spiegelbild.\nDeine Gedanken.\nDein eigener Schatten.\n\n" +
"Und am Ende… hast du gewonnen.\nAber es gab nie etwas zu besiegen.\n\n" +
"In dem Moment, in dem du abgedrückt hast…\nhast du dich selbst getroffen.\n\n" +
"Kein Geräusch. Kein Widerstand.\n\nNur Stille.\n\n" +
"Und zum ersten Mal…\nbist du wirklich allein.",

		"en":
"There was never anyone there.\nNo enemy. No stranger. No escape.\n\n" +
"Only you.\nFrom the very beginning.\n\n" +
"You fought…\nagainst something that never left you.\n\n" +
"Your reflection.\nYour thoughts.\nYour own shadow.\n\n" +
"And in the end… you won.\nBut there was never anything to defeat.\n\n" +
"In the moment you pulled the trigger…\nyou shot yourself.\n\n" +
"No sound. No resistance.\n\nOnly silence.\n\n" +
"And for the first time…\nyou are truly alone."
	},

	"good_text": {
		"de":
"Du hörst sie noch. Die Stimmen.\nLeise… aber da.\n\n" +
"Doch diesmal… kontrollieren sie dich nicht mehr.\n\n" +
"Du hast verstanden,\ndass sie nie von außen kamen.\n\nSie waren du.\n\n" +
"Und zum ersten Mal…\nläufst du nicht mehr davon.\n\n" +
"Du bleibst stehen. Du siehst hin.\nDu akzeptierst.\n\n" +
"Du hast dich selbst gefunden.\n\n…\n\n" +
"Aber die Welt hat sich nicht verändert.\nSie ist immer noch leer. Kalt. Verlassen.\n\n" +
"Niemand wartet auf dich.\nNiemand kommt zurück.\n\n" +
"Doch diesmal… bist du nicht mehr verloren.\n\nDu gehst weiter.\n\nAllein.",

		"en":
"You can still hear them. The voices.\nQuiet… but there.\n\n" +
"But this time… they no longer control you.\n\n" +
"You understood\nthat they never came from the outside.\n\nThey were you.\n\n" +
"And for the first time…\nyou stop running.\n\n" +
"You stand still. You look.\nYou accept.\n\n" +
"You found yourself.\n\n…\n\n" +
"But the world hasn’t changed.\nIt is still empty. Cold. Abandoned.\n\n" +
"No one is waiting for you.\nNo one is coming back.\n\n" +
"But this time… you are no longer lost.\n\nYou keep walking.\n\nAlone."
	}
}

var _recoil:      float = 0.0
var _wobble_time: float = 0.0
var _game_over:   bool  = false

# Eigener CanvasLayer über dem CRT-Filter — Labels werden hier rein verschoben
var _text_canvas: CanvasLayer

func get_text(key: String) -> String:
	var current_lang = Player.current_language
	
	if localized_texts.has(key) and localized_texts[key].has(current_lang):
		return localized_texts[key][current_lang]
	elif localized_texts.has(key) and localized_texts[key].has("de"):
		return localized_texts[key]["de"]
	
	return key
# ---------------------------------------------------------------------------
# Ready: Labels aus dem gefilterten Tree raus, in eigenen CanvasLayer rein
# ---------------------------------------------------------------------------
func _ready() -> void:
	_text_canvas = CanvasLayer.new()
	_text_canvas.layer = 20
	get_tree().current_scene.add_child.call_deferred(_text_canvas)
	await get_tree().process_frame
	_lift_label($"../BadEnding2/BadEndingText")
	_lift_label($"../GoodEnding3/GoodEnding")


func _lift_label(label: RichTextLabel) -> void:
	if label == null:
		push_error("_lift_label: Label nicht gefunden!")
		return
	var saved_pos := label.global_position
	label.get_parent().remove_child(label)
	_text_canvas.add_child(label)
	label.global_position    = saved_pos
	label.visible_characters = 0


# ---------------------------------------------------------------------------
# Label holen (jetzt im _text_canvas)
# ---------------------------------------------------------------------------
func _get_bad_label() -> RichTextLabel:
	return _text_canvas.get_node_or_null("BadEndingText") as RichTextLabel

func _get_good_label() -> RichTextLabel:
	return _text_canvas.get_node_or_null("GoodEnding") as RichTextLabel


# ---------------------------------------------------------------------------
# Font + Kontrastfarbe
# ---------------------------------------------------------------------------
func _style_label(label: RichTextLabel, node: Node) -> void:
	if label == null:
		push_error("_style_label: label ist null!")
		return
	label.bbcode_enabled     = false
	label.scroll_active      = false
	label.visible_characters = 0
	label.text               = ""

	for child in label.get_children():
		if child is VScrollBar:
			child.visible = false

	var font := load(VCR_FONT_PATH) as FontFile
	if font:
		label.add_theme_font_override("normal_font", font)
		label.add_theme_font_size_override("normal_font_size", 18)

	# Textur je nach Node-Typ holen
	var tex: Texture2D
	if node is Sprite2D:
		tex = node.texture
	elif node is AnimatedSprite2D:
		var frames: SpriteFrames = node.sprite_frames
		if frames:
			tex = frames.get_frame_texture(node.animation, node.frame)

	if tex == null:
		return
	var img: Image = tex.get_image()
	if img == null:
		return
	img.convert(Image.FORMAT_RGBA8)
	var lum_sum: float = 0.0
	var w: int = img.get_width()
	var h: int = img.get_height()
	for xi in range(10):
		for yi in range(10):
			var px: int = int(xi * (w - 1) / 9.0)
			var py: int = int(yi * (h - 1) / 9.0)
			var c: Color = img.get_pixel(px, py)
			lum_sum += c.r * 0.299 + c.g * 0.587 + c.b * 0.114
	var avg_lum: float = lum_sum / 100.0
	label.add_theme_color_override("default_color",
		Color.BLACK if avg_lum > 0.5 else Color.WHITE)
# ---------------------------------------------------------------------------
# Typewriter
# ---------------------------------------------------------------------------
func _typewrite(label: RichTextLabel, full_text: String, cps: float = 20.0) -> void:
	label.text = full_text
	label.visible_characters = 0
	label.scroll_active = false

	var total: int = full_text.length()
	var elapsed: float = 0.0

	while label.visible_characters < total:
		await get_tree().process_frame
		elapsed += get_process_delta_time()

		label.visible_characters = mini(int(elapsed * cps), total)

		# 🔥 AUTO SCROLL
		label.scroll_to_line(label.get_line_count())


# ---------------------------------------------------------------------------
# Fade
# ---------------------------------------------------------------------------
func _fade_in(node: CanvasItem, duration: float = 0.8) -> void:
	node.modulate.a = 0.0
	node.visible    = true
	await get_tree().process_frame
	var tw := create_tween()
	tw.tween_property(node, "modulate:a", 1.0, duration)
	await tw.finished

func _fade_out(node: CanvasItem, duration: float = 0.4) -> void:
	var tw := create_tween()
	tw.tween_property(node, "modulate:a", 0.0, duration)
	await tw.finished
	node.visible = false


# ---------------------------------------------------------------------------
# Prozess / Input
# ---------------------------------------------------------------------------
func _process(delta: float) -> void:
	if _game_over:
		return
	var mouse  := get_global_mouse_position()
	var angle  := (mouse - global_position).angle()
	_recoil      = lerpf(_recoil, 0.0, delta * 12.0)
	_wobble_time += delta
	var wobble   := sin(_wobble_time * 1.3) * 0.018 + sin(_wobble_time * 2.7) * 0.009
	rotation     = angle + PI + _recoil + wobble
	arm.flip_v   = mouse.x > global_position.x


func _unhandled_input(event: InputEvent) -> void:
	if _game_over:
		return
	if event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT \
			and event.pressed:
		await shoot()


# ---------------------------------------------------------------------------
# Schuss
# ---------------------------------------------------------------------------
func shoot() -> void:
	shot.play()
	_recoil = -0.18
	_spawn_flash()
	_spawn_smoke()
	await _check_hit()


func _check_hit() -> void:
	var dir   := Vector2.LEFT.rotated(rotation)
	var from  := barrel_end.global_position
	var to    := from + dir * 2000.0
	_draw_ray(from, to)

	var space := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(from, to)
	query.collide_with_areas = true
	var result := space.intersect_ray(query)

	if result and result.collider == hitbox:
		await _start_bad_ending()
	else:
		await _start_good_ending()


# ---------------------------------------------------------------------------
# Bad Ending
# ---------------------------------------------------------------------------
func _start_bad_ending() -> void:
	_game_over = true
	music.pitch_scale = 0.75
	headshot.play()
	body.visible = false
	arm.visible  = false

	# BadEnding Animation einmalig starten
	bad_ending.frame = 0
	bad_ending.play("default")
	await _fade_in(bad_ending, 0.8)
	await get_tree().create_timer(3.0).timeout
	await _fade_out(bad_ending, 0.4)

	# BadEnding2 Animation einmalig starten
	bad_ending2.sprite_frames.set_animation_loop("default", false)
	bad_ending2.frame = 0
	bad_ending2.play("default")

	var lbl := _get_bad_label()
	_style_label(lbl, bad_ending2)
	await _fade_in(bad_ending2, 0.6)
	if lbl:
		lbl.visible = true
		await _typewrite(lbl, get_text("bad_text"), 18.0)

	await get_tree().create_timer(SCENE_DELAY).timeout
	SteamAchievements.unlock("ACH_COMPLETE_GAME2")
	get_tree().change_scene_to_file(NEXT_SCENE)
# ---------------------------------------------------------------------------
# Good Ending
# ---------------------------------------------------------------------------
func _start_good_ending() -> void:
	_game_over = true
	music.stop()
	music2.play()
	body.visible = false
	arm.visible  = false

	await _fade_in(good_ending, 0.8)
	await get_tree().create_timer(3.0).timeout
	await _fade_out(good_ending, 0.4)

	good_ending2.frame = 0
	good_ending2.play("default")
	await _fade_in(good_ending2, 0.8)
	await get_tree().create_timer(3.0).timeout
	await _fade_out(good_ending2, 0.4)

	var lbl := _get_good_label()
	_style_label(lbl, good_ending3)
	good_ending3.frame = 0
	good_ending3.play("default")
	await _fade_in(good_ending3, 0.8)
	if lbl:
		lbl.visible = true
		await _typewrite(lbl, get_text("good_text"), 18.0)

	await get_tree().create_timer(SCENE_DELAY).timeout
	SteamAchievements.unlock("ACH_COMPLETE_GAME")
	get_tree().change_scene_to_file(NEXT_SCENE)

# ---------------------------------------------------------------------------
# Visuals
# ---------------------------------------------------------------------------
func _draw_ray(from: Vector2, to: Vector2) -> void:
	var line := Line2D.new()
	line.add_point(from)
	line.add_point(to)
	line.width         = 2.0
	line.default_color = Color(1, 0.2, 0.2, 0.8)
	get_tree().current_scene.add_child(line)
	var tw := create_tween()
	tw.tween_property(line, "modulate:a", 0.0, 0.15)
	tw.tween_callback(line.queue_free)


func _spawn_flash() -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = 10
	get_tree().current_scene.add_child(canvas)
	var flash := ColorRect.new()
	flash.color = Color(1, 1, 1, 0.6)
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(flash)
	var tw := create_tween()
	tw.tween_property(flash, "color:a", 0.0, 0.12)
	tw.tween_callback(canvas.queue_free)


func _spawn_smoke() -> void:
	var particles := CPUParticles2D.new()
	add_child(particles)
	particles.position             = barrel_end.position
	particles.emitting             = true
	particles.one_shot             = true
	particles.explosiveness        = 0.7
	particles.lifetime             = 1.8
	particles.amount               = 18
	var mouse := get_global_mouse_position()
	var dir   := (mouse - barrel_end.global_position).normalized()
	particles.direction            = dir
	particles.spread               = 20.0
	particles.initial_velocity_min = 18.0
	particles.initial_velocity_max = 45.0
	particles.gravity              = Vector2(0, -12)
	particles.scale_amount_min     = 3.0
	particles.scale_amount_max     = 7.0
	var grad := Gradient.new()
	grad.set_color(0, Color(0.7, 0.7, 0.7, 0.6))
	grad.set_color(1, Color(0.4, 0.4, 0.4, 0.0))
	particles.color_ramp = grad
	await get_tree().create_timer(particles.lifetime + 0.5).timeout
	particles.queue_free()
