extends PanelContainer

# ===========================
#  FISCHBUCH EINTRAG / ENTRY
# ===========================

var icon: TextureRect
var name_label: Label
var rarity_label: Label
var value_label: Label

var fish_data: Dictionary = {}

func _ready():
	# Nodes finden
	icon = $VBoxContainer/MarginContainer/Icon
	name_label = $VBoxContainer/NameLabel
	rarity_label = $VBoxContainer/RarityLabel
	value_label = $VBoxContainer/ValueLabel	
	
	# Debug
	print("FishBookEntry._ready() - Nodes gefunden:")
	print("  Icon: ", icon)
	print("  Name: ", name_label)
	print("  Rarity: ", rarity_label)
	print("  Value: ", value_label)
	
	# Größe setzen (anpassen nach Bedarf)
	custom_minimum_size = Vector2(70, 90)

func set_fish_data(data: Dictionary):
	fish_data = data
	print("FishBookEntry.set_fish_data() - Data: ", fish_data)
	
	# Warte bis dieser Node ready ist
	if not is_node_ready():
		await ready
	
	update_display()

func update_display():
	print("FishBookEntry.update_display() - Updating display for: ", fish_data.get("name", "???"))
	
	if fish_data.is_empty():
		print("  ⚠️ fish_data ist leer!")
		return
	
	# Nodes nochmal überprüfen
	if icon == null or name_label == null or rarity_label == null or value_label == null:
		print("  ❌ ERROR: Nodes sind null!")
		print("    Icon: ", icon)
		print("    Name: ", name_label)
		print("    Rarity: ", rarity_label)
		print("    Value: ", value_label)
		return
	
	# 🐟 ICON
	if fish_data.has("icon") and ResourceLoader.exists(fish_data["icon"]):
		icon.texture = load(fish_data["icon"])
		icon.modulate = Color.WHITE
		print("  ✅ Icon geladen: ", fish_data["icon"])
	else:
		# Placeholder für unbekannte Fische
		icon.modulate = Color.GRAY
		print("  ⚠️ Icon nicht gefunden: ", fish_data.get("icon", "no icon"))
	
	# 📝 NAME
	var display_name = fish_data["name"] if fish_data.get("caught", false) else "???"
	name_label.text = display_name
	name_label.add_theme_font_size_override("font_size", 14)
	print("  Name: ", display_name)
	
	# 🎨 RARITY & VALUE
	if fish_data.get("caught", false):
		var rarity = fish_data["rarity"]
		var rarity_data = FishDB.RARITY_DATA[rarity]
		rarity_label.text = rarity_data["name"]
		rarity_label.modulate = rarity_data["color"]
		rarity_label.add_theme_font_size_override("font_size", 12)
		
		# 💰 VALUE
		value_label.text = "💰 %d" % fish_data["base_value"]
		value_label.add_theme_font_size_override("font_size", 11)
		value_label.show()
		
		# Hintergrund hell
		modulate = Color.WHITE
		print("  Rarity: ", rarity_data["name"])
	else:
		rarity_label.text = "???"
		rarity_label.modulate = Color.GRAY
		rarity_label.add_theme_font_size_override("font_size", 12)
		value_label.hide()
		
		# Hintergrund grau
		modulate = Color(0.6, 0.6, 0.6)
		print("  Unbekannter Fisch")
	
	print("  ✅ Update abgeschlossen")

func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		if fish_data.get("caught", false):
			show_fish_details()

func show_fish_details():
	var name = fish_data.get("original_name", fish_data.get("name", "Unbekannt"))
	print("🐟 Details:", name)

# ===========================
#  SZENE STRUKTUR
# ===========================
# PanelContainer (FishBookEntry.tscn, Name: "FishBookEntry")
# └─ VBoxContainer (separation: 5, margin all: 8)
#    ├─ Icon (TextureRect, Name: "Icon", Size: 80x80)
#    ├─ NameLabel (Label, Name: "NameLabel")
#    ├─ RarityLabel (Label, Name: "RarityLabel")
#    └─ ValueLabel (Label, Name: "ValueLabel")
