extends Control
class_name DrinksMinigame

signal minigame_finished(success: bool)
signal minigame_cancelled()

const GRID_COLS: int = 4
const GRID_ROWS: int = 3
const TIME_LIMIT: float = 8.0

# Alle möglichen Items im Grid
const ALL_ITEMS: Array[String] = [
	"🍺", "🧃", "🥤", "☕", "🍵", "🧋", "🍹", "🍸",
	"🥛", "💧", "🧊", "🍾"
]
# Das richtige Getränk das der Kunde bestellt hat
const TARGET_DRINK: String = "🥤"  # Wird von außen gesetzt via set_target()

var target_item: String = TARGET_DRINK
var elapsed: float = 0.0
var active: bool = false
var grid_items: Array[String] = []

@onready var grid_container: GridContainer = $Panel/VBox/GridContainer
@onready var timer_label: Label = $Panel/VBox/TimerLabel
@onready var hint_label: Label = $Panel/VBox/HintLabel
@onready var target_display: Label = $Panel/VBox/TargetDisplay

func _ready() -> void:
	visible = false

func set_target(drink_emoji: String) -> void:
	target_item = drink_emoji

func start() -> void:
	elapsed = 0.0
	active = true
	visible = true
	_build_grid()
	hint_label.text = tr("DRINKS_MINI_HINT")
	target_display.text = tr("DRINKS_MINI_TARGET") % target_item

func _build_grid() -> void:
	# Grid leeren
	for child in grid_container.get_children():
		child.queue_free()
	
	grid_items.clear()
	
	var total = GRID_COLS * GRID_ROWS
	
	# Sicherstellen dass target mindestens einmal vorkommt
	grid_items.append(target_item)
	
	# Rest mit random Items auffüllen
	for i in range(total - 1):
		var others = ALL_ITEMS.filter(func(x): return x != target_item)
		grid_items.append(others[randi() % others.size()])
	
	grid_items.shuffle()
	
	# Buttons erstellen
	for item in grid_items:
		var btn = Button.new()
		btn.text = item
		btn.custom_minimum_size = Vector2(64, 64)
		btn.add_theme_font_size_override("font_size", 28)
		btn.pressed.connect(_on_item_pressed.bind(item))
		grid_container.add_child(btn)

func _process(delta: float) -> void:
	if not active:
		return
	elapsed += delta
	var remaining = TIME_LIMIT - elapsed
	timer_label.text = "%.1f" % max(0.0, remaining)
	
	if elapsed >= TIME_LIMIT:
		_finish(false)

func _on_item_pressed(item: String) -> void:
	if not active:
		return
	_finish(item == target_item)

func _finish(success: bool) -> void:
	active = false
	visible = false
	minigame_finished.emit(success)
	

func cancel() -> void:
	if active:
		active = false
		visible = false
		minigame_cancelled.emit()
