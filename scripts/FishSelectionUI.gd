extends Control
class_name FishSelectionUI

signal fish_selected(fish_name: String)
signal cancelled()

@onready var title_label: Label = $Panel/VBoxContainer/TitleLabel
@onready var search_bar: LineEdit = $Panel/VBoxContainer/SearchBar
@onready var fish_list: VBoxContainer = $Panel/VBoxContainer/ScrollContainer/FishList
@onready var cancel_button: Button = $Panel/VBoxContainer/CancelButton
@onready var custom_font := preload("res://fonts/VCR_OSD_MONO_1.001.ttf")

# Expected: Array<Dictionary> from FishDB
var available_fish: Array = []

# ===============================
#  READY
# ===============================
func _ready() -> void:
	cancel_button.pressed.connect(_on_cancel_pressed)
	cancel_button.text = tr("UI_CANCEL")
	search_bar.text_changed.connect(_on_search_changed)
	search_bar.placeholder_text = tr("UI_SEARCH_PLACEHOLDER")
	hide()

# ===============================
#  INPUT (blocks spacebar when UI is open)
# ===============================
func _input(event: InputEvent) -> void:
	if not visible:
		return
	
	# Block spacebar completely when this UI is open
	if event.is_action_pressed("ui_accept"):  # Spacebar
		get_viewport().set_input_as_handled()
		

# ===============================
#  PUBLIC API
# ===============================
func show_fish_selection(fish_array: Array, station_name: String) -> void:
	available_fish = fish_array
	title_label.text = tr("UI_FISH_SELECT_TITLE") % station_name
	search_bar.text = ""
	_rebuild_list("")
	show()
	print("should be visible")
	
	# Wait one frame so spacebar from opening isn't registered
	await get_tree().process_frame
	
	# Activate search field
	search_bar.editable = true
	search_bar.grab_focus()

# ===============================
#  LIST BUILDING
# ===============================
func _rebuild_list(filter_text: String) -> void:
	# Delete old entries
	for child in fish_list.get_children():
		child.queue_free()
	
	filter_text = filter_text.to_lower()
	
	for fish in available_fish:
		# Hard validation
		if not (fish is Dictionary):
			continue
		if not fish.has("name"):
			continue
		
		var fish_name: String = fish["name"]
		
		# Search filter
		if filter_text != "" and not fish_name.to_lower().contains(filter_text):
			continue
		
		fish_list.add_child(_create_fish_entry(fish))

# ===============================
#  SINGLE ENTRY
# ===============================
func _create_fish_entry(fish: Dictionary) -> Control:
	var fish_name: String = fish["name"]
	var icon_path: String = fish.get("icon", "")
	var rarity: int = fish.get("rarity", FishDB.RARITY.NORMAL)
	
	var button := Button.new()
	button.custom_minimum_size = Vector2(260, 48)
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(_on_fish_selected.bind(fish_name))
	
	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_BEGIN
	button.add_child(hbox)
	
	# Icon
	if icon_path != "":
		var icon := TextureRect.new()
		icon.texture = load(icon_path)
		icon.custom_minimum_size = Vector2(32, 32)
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		hbox.add_child(icon)
	
	# Name
	var label := Label.new()
	label.text = fish_name
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_override("font", custom_font)
	label.add_theme_font_size_override("font_size", 18)
	
	# Rarity color from FishDB
	if FishDB.RARITY_DATA.has(rarity):
		label.add_theme_color_override(
			"font_color",
			FishDB.RARITY_DATA[rarity]["color"]
		)
	
	hbox.add_child(label)
	
	return button

# ===============================
#  EVENTS
# ===============================
func _on_search_changed(text: String) -> void:
	_rebuild_list(text)

func _on_fish_selected(fish_name: String) -> void:
	fish_selected.emit(fish_name)
	hide()

func _on_cancel_pressed() -> void:
	cancelled.emit()
	hide()
