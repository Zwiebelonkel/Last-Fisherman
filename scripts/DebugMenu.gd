extends CanvasLayer

const NumberFormat = preload("res://scripts/NumberFormat.gd")
## In MapScene den Knoten DebugMenu waehlen und Enabled deaktivieren.
## Release-Exporte sperren das Menue zusaetzlich automatisch.

## Einziger Schalter fuer Menue, F8 und Debug-Aktionen. Release-Builds bleiben gesperrt.
@export var enabled: bool = true:
	set(value):
		enabled = value
		if is_node_ready():
			_update_enabled()

@onready var open_button: Button = $Screen/OpenButton
@onready var overlay: Control = $Screen/Overlay
@onready var tabs: TabContainer = $Screen/Overlay/Panel/Margin/Content/Tabs
@onready var status: Label = $Screen/Overlay/Panel/Margin/Content/Status

var money_input: SpinBox
var balance_label: Label
var rarity_inputs: Dictionary = {}
var upgrade_inputs: Dictionary = {}
var rarity_summary: Label

signal values_changed


func _ready() -> void:
	if not _allowed():
		FishDB.clear_debug_rarity_weights()
		queue_free()
		return
	_build_money_tab()
	_build_rarity_tab()
	_build_upgrade_tab()
	open_button.pressed.connect(toggle_menu)
	$Screen/Overlay/Panel/Margin/Content/Header/Close.pressed.connect(close_menu)
	overlay.hide()
	_update_enabled()


func _allowed() -> bool:
	return enabled and OS.is_debug_build()


func _update_enabled() -> void:
	open_button.visible = _allowed()
	set_process_input(_allowed())
	if not _allowed():
		close_menu()
		FishDB.clear_debug_rarity_weights()


func _input(event: InputEvent) -> void:
	if not _allowed() or not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.keycode == KEY_F8:
		toggle_menu()
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_ESCAPE and overlay.visible:
		close_menu()
		get_viewport().set_input_as_handled()


func toggle_menu() -> void:
	if not _allowed():
		return
	if overlay.visible:
		close_menu()
	else:
		_refresh_fields()
		overlay.show()
		$Screen/Overlay/Panel/Margin/Content/Header/Close.grab_focus()


func close_menu() -> void:
	overlay.hide()
	get_viewport().gui_release_focus()


func _tab(title: String) -> VBoxContainer:
	var scroll := ScrollContainer.new()
	scroll.name = title
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	tabs.add_child(scroll)
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 12)
	scroll.add_child(box)
	return box


func _label(parent: Node, text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(label)
	return label


func _number(parent: Node, title: String, minimum: float, maximum: float, step_value: float = 1.0) -> SpinBox:
	var row := HBoxContainer.new()
	parent.add_child(row)
	var label := _label(row, title)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var input := SpinBox.new()
	input.custom_minimum_size.x = 210
	input.min_value = minimum
	input.max_value = maximum
	input.step = step_value
	input.update_on_text_changed = true
	input.get_line_edit().select_all_on_focus = true
	row.add_child(input)
	return input


func _button(parent: Node, title: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = title
	button.custom_minimum_size.y = 38
	button.pressed.connect(action)
	parent.add_child(button)
	return button


func _build_money_tab() -> void:
	var box := _tab("Geld")
	balance_label = _label(box, "")
	money_input = _number(box, "Betrag ($)", 0, 1_000_000_000_000_000)
	money_input.value = 10000
	_button(box, "Betrag zum Guthaben hinzufügen", _add_money)
	_button(box, "Guthaben auf diesen Betrag setzen", _set_money)
	_label(box, "Geldänderungen werden im Spielstand gespeichert.")


func _build_rarity_tab() -> void:
	var box := _tab("Raritäten")
	_label(box, "Gewichte werden auf 100 % normiert. Die Debug-Verteilung ersetzt Köder- und Upgrade-Boni.")
	for rarity: int in FishDB.RARITY_DATA:
		var data: Dictionary = FishDB.RARITY_DATA[rarity]
		var input := _number(box, tr(data["name_key"]), 0, 100, 0.01)
		input.get_parent().get_child(0).modulate = data["color"]
		input.value_changed.connect(func(_value: float) -> void: _update_rarity_summary())
		rarity_inputs[rarity] = input
	rarity_summary = _label(box, "")
	_button(box, "Debug-Verteilung anwenden", _apply_rarities)
	_button(box, "Standardwerte wiederherstellen", _reset_rarities)
	_label(box, "Gilt bis zum Spielneustart. Nur am Angelort verfügbare Fänge zählen; abgeschlossene Storyobjekte bleiben ausgeschlossen. Ist keine gewählte Rarität verfügbar, gelten die normalen Chancen.")


func _build_upgrade_tab() -> void:
	var box := _tab("Upgrades")
	upgrade_inputs["upgrade_grip"] = _number(box, "Griff / Grip", 1, 1000000)
	upgrade_inputs["upgrade_bait"] = _number(box, "Köder / Bait", 1, 1000000)
	upgrade_inputs["upgrade_line"] = _number(box, "Schnur / Line", 1, 1000000)
	_button(box, "Upgrade-Stufen übernehmen", _apply_upgrades)
	_label(box, "Basisstufe: 1. Alle drei Werte lassen sich unabhängig setzen und werden im Spielstand gespeichert.")


func _refresh_fields() -> void:
	balance_label.text = "Aktuelles Guthaben: %s $" % NumberFormat.compact(Player.money)
	for key: String in upgrade_inputs:
		upgrade_inputs[key].value = Player.get(key)
	for rarity: int in rarity_inputs:
		rarity_inputs[rarity].value = FishDB.debug_rarity_weights.get(rarity, FishDB.RARITY_DATA[rarity]["spawn_chance"])
	_update_rarity_summary()
	status.text = "Raritäts-Debug aktiv" if not FishDB.debug_rarity_weights.is_empty() else "Normale Raritätschancen aktiv"


func _update_rarity_summary() -> void:
	if rarity_summary == null:
		return
	var total := 0.0
	for input: SpinBox in rarity_inputs.values():
		total += input.value
	var parts := PackedStringArray()
	if total > 0.0:
		for rarity: int in rarity_inputs:
			parts.append("%s %.2f %%" % [tr(FishDB.RARITY_DATA[rarity]["name_key"]), rarity_inputs[rarity].value / total * 100.0])
	rarity_summary.text = "Verteilung: " + " · ".join(parts) if total > 0.0 else "Mindestens eine Rarität muss ein Gewicht über 0 haben."


func _add_money() -> void:
	if not _allowed():
		return
	var amount := int(money_input.value)
	if Player.money > 9223372036854775807 - amount:
		status.text = "Dieser Betrag überschreitet das maximale Guthaben."
		return
	Player.add_money(amount)
	_changed("%s $ hinzugefügt." % NumberFormat.compact(amount))


func _set_money() -> void:
	if not _allowed():
		return
	Player.set_money(int(money_input.value))
	_changed("Guthaben gesetzt.")


func _apply_upgrades() -> void:
	if not _allowed():
		return
	for key: String in upgrade_inputs:
		Player.set(key, int(upgrade_inputs[key].value))
	Player.save_game()
	_changed("Upgrade-Stufen gespeichert.")


func _apply_rarities() -> void:
	if not _allowed():
		return
	var weights := {}
	for rarity: int in rarity_inputs:
		weights[rarity] = rarity_inputs[rarity].value
	if not FishDB.set_debug_rarity_weights(weights):
		status.text = "Nicht übernommen: Mindestens ein Gewicht muss größer als 0 sein."
		return
	_changed("Debug-Verteilung aktiv – gilt auch nach dem Reisen.")


func _reset_rarities() -> void:
	if not _allowed():
		return
	FishDB.clear_debug_rarity_weights()
	_refresh_fields()
	_changed("Standardchancen und normale Köder-/Upgrade-Boni wieder aktiv.")


func _changed(message: String) -> void:
	balance_label.text = "Aktuelles Guthaben: %s $" % NumberFormat.compact(Player.money)
	status.text = message
	values_changed.emit()
