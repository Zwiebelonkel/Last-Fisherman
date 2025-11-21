extends Node

# --- PLAYER DATA ---
var money: int = 0
var level: int = 1
var xp: int = 0

var upgrade_grip: int = 1
var upgrade_bait: int = 1
var upgrade_line: int = 1

func add_money(amount: int) -> void:
	money += amount
	print("Geld hinzugefügt:", amount, " → Neues Guthaben:", money)

func remove_money(amount: int) -> bool:
	if money >= amount:
		money -= amount
		print("Geld ausgegeben:", amount, " → Neues Guthaben:", money)
		return true
	return false

func set_money(amount: int) -> void:
	money = amount

func get_money() -> int:
	return money

func add_xp(amount: int) -> void:
	xp += amount

func reset():
	money = 0
	level = 1
	xp = 0
