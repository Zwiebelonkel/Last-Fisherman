extends Node

var fish_inventory: Array = []  # Liste aller gefangenen Fische

func _ready():
    load_inventory()

# 🆕 Seltsame oder fehlende Rarities robust behandeln
func _normalize_rarity_key(raw_rarity) -> int:
    var rarity_key = raw_rarity
    if rarity_key == null:
        return FishDB.RARITY.NORMAL
    if typeof(rarity_key) == TYPE_STRING and rarity_key.is_valid_int():
        rarity_key = int(rarity_key)
    if FishDB.RARITY_DATA.has(rarity_key):
        return rarity_key
    push_warning("Unbekannte Seltenheit im Inventar: %s" % [str(raw_rarity)])
    return FishDB.RARITY.NORMAL

func _safe_rarity_value(fish_data: Dictionary) -> float:
    var rarity_key = _normalize_rarity_key(fish_data.get("rarity", null))
    return FishDB.RARITY_DATA[rarity_key].get("value", 1.0)

func _sanitize_fish_entry(fish_data: Dictionary) -> Dictionary:
    var sanitized = fish_data.duplicate(true)
    sanitized["rarity"] = _normalize_rarity_key(sanitized.get("rarity", null))
    return sanitized

func add_fish(fish_data: Dictionary) -> void:
    var sanitized_fish = _sanitize_fish_entry(fish_data)
    fish_inventory.append(sanitized_fish)
    print("Fisch ins Inventar hinzugefügt:", fish_data)
    save_inventory()

func remove_fish(index: int) -> void:
    if index >= 0 and index < fish_inventory.size():
        fish_inventory.remove_at(index)
        save_inventory()

func clear_inventory():
    fish_inventory.clear()
    save_inventory()

func get_total_value() -> int:
    var total = 0
    for f in fish_inventory:
        var rarity_bonus = _safe_rarity_value(f)
        total += int(f.get("base_value", 0) * rarity_bonus)
    return total

func save_inventory() -> void:
    var save_data = {
        "fish_inventory": fish_inventory
    }
    var file = FileAccess.open("user://inventory.dat", FileAccess.WRITE)
    file.store_var(save_data)
    print("Inventar gespeichert!")

func load_inventory() -> void:
    if FileAccess.file_exists("user://inventory.dat"):
        var file = FileAccess.open("user://inventory.dat", FileAccess.READ)
        var save_data = file.get_var()
        fish_inventory = []
        for fish_data in save_data.get("fish_inventory", []):
            fish_inventory.append(_sanitize_fish_entry(fish_data))
        print("Inventar geladen! Fische im Inventar:", fish_inventory.size())
    else:
        print("Keine Inventar-Speicherdatei gefunden")
