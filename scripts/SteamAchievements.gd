extends Node
# Autoload: Achievements

var steam_ready := false

func _ready():
	if Engine.has_singleton("Steam"):
		if Steam.steamInit():
			steam_ready = true
			print("🏆 Achievement System bereit")
		else:
			print("⚠️ Steam Init für Achievements fehlgeschlagen")
	else:
		print("⚠️ Steam nicht verfügbar - Achievements deaktiviert")

# ===========================
# GENERIC
# ===========================

func unlock(achievement_id: String) -> void:
	if not steam_ready:
		print("⚠️ Achievement %s würde freigeschaltet (Steam nicht verfügbar)" % achievement_id)
		return
	
	# Prüfe ob bereits freigeschaltet
	var already_unlocked: Dictionary = Steam.getAchievement(achievement_id)
	if already_unlocked.get("achieved", false):
		print("ℹ️ Achievement bereits freigeschaltet: %s" % achievement_id)
		return
	
	# Schalte frei
	var success: bool = Steam.setAchievement(achievement_id)
	if success:
		Steam.storeStats()
		print("🏆 Achievement freigeschaltet: %s" % achievement_id)
	else:
		push_error("❌ Achievement freischalten fehlgeschlagen: %s" % achievement_id)

func clear_achievement(achievement_id: String) -> void:
	"""Nur für Testing - entfernt Achievement"""
	if not steam_ready:
		return
	Steam.clearAchievement(achievement_id)
	Steam.storeStats()
	print("🧹 Achievement zurückgesetzt: %s" % achievement_id)

# ===========================
# RARITY ACHIEVEMENTS
# ===========================

func on_fish_caught(fish: Dictionary) -> void:
	if not fish.has("rarity"):
		return
	
	var rarity: int = fish["rarity"]
	
	match rarity:
		FishDB.RARITY.NORMAL:
			unlock("ACH_CATCH_NORMAL")
		FishDB.RARITY.UNGEWOEHNLICH:
			unlock("ACH_CATCH_UNCOMMON")
		FishDB.RARITY.SELTEN:
			unlock("ACH_CATCH_RARE")
		FishDB.RARITY.EPISCH:
			unlock("ACH_CATCH_EPIC")
		FishDB.RARITY.LEGENDAER:
			unlock("ACH_CATCH_LEGENDARY")
		FishDB.RARITY.EXOTISCH:
			unlock("ACH_CATCH_EXOTIC")
		FishDB.RARITY.ANTIK:
			unlock("ACH_CATCH_ANTIQUE")

# ===========================
# TOTAL FISH ACHIEVEMENTS
# ===========================

func check_total_fish_caught() -> void:
	var total := Player.get_total_fish_caught()
	
	if total >= 1:
		unlock("ACH_FISH1")
	if total >= 10:
		unlock("ACH_FISH10")
	if total >= 50:
		unlock("ACH_FISH50")
	if total >= 100:
		unlock("ACH_FISH100")
	if total >= 500:
		unlock("ACH_FISH500")
	if total >= 1000:
		unlock("ACH_FISH1000")

# ===========================
# SPECIES ACHIEVEMENTS
# ===========================

func check_species_discovered() -> void:
	var species_count := Player.caught_fish_species.size()
	
	if species_count >= 10:
		unlock("ACH_SPECIES10")
	if species_count >= 25:
		unlock("ACH_SPECIES25")
	if species_count >= 50:
		unlock("ACH_SPECIES50")
	if species_count >= 75:
		unlock("ACH_SPECIES75")

# ===========================
# BIOME ACHIEVEMENTS
# ===========================

func on_biome_bought(biome: String) -> void:
	match biome:
		"city":
			unlock("ACH_BUY_CITY")
		"sewer":
			unlock("ACH_BUY_SEWER")
		"forest":
			unlock("ACH_BUY_FOREST")
		"desert":
			unlock("ACH_BUY_DESERT")
		"iceland":
			unlock("ACH_BUY_ICELAND")

func on_biome_completed(biome: String) -> void:
	match biome:
		"lake":
			unlock("ACH_COMPLETE_LAKE")
		"city":
			unlock("ACH_COMPLETE_CITY")
		"sewer":
			unlock("ACH_COMPLETE_SEWER")
		"forest":
			unlock("ACH_COMPLETE_FOREST")
		"desert":
			unlock("ACH_COMPLETE_DESERT")
		"iceland":
			unlock("ACH_COMPLETE_ICELAND")
	
	# Prüfe ob ALLE Biome komplett sind
	check_all_biomes_complete()

func check_all_biomes_complete() -> void:
	var all_complete := true
	for completed in Player.completed_biomes.values():
		if not completed:
			all_complete = false
			break
	
	if all_complete:
		unlock("ACH_MASTER_ANGLER")

# ===========================
# MONEY ACHIEVEMENTS
# ===========================

func check_money_earned() -> void:
	var money := Player.money
	
	if money >= 1000:
		unlock("ACH_MONEY_1K")
	if money >= 5000:
		unlock("ACH_MONEY_5K")
	if money >= 10000:
		unlock("ACH_MONEY_10K")
	if money >= 50000:
		unlock("ACH_MONEY_50K")

# ===========================
# WEIGHT ACHIEVEMENTS
# ===========================

func check_weight_record(fish_name: String, weight: float) -> void:
	# Sehr schwerer Fisch
	if weight >= 500.0:
		unlock("ACH_HEAVY_500")
	if weight >= 1000.0:
		unlock("ACH_HEAVY_1000")

# ===========================
# STORY ACHIEVEMENTS
# ===========================

func on_story_item_used(item_name: String) -> void:
	unlock("ACH_STORY_ITEM")
	
	# Prüfe ob alle Story-Items gefunden wurden
	if Player.used_story_items.size() >= 6:  # Anzahl der Biome
		unlock("ACH_ALL_STORY_ITEMS")

# ===========================
# SPECIAL ACHIEVEMENTS
# ===========================

func on_first_fish() -> void:
	unlock("ACH_FIRST_FISH")

func on_first_sale() -> void:
	unlock("ACH_FIRST_SALE")

func on_upgrade_bought() -> void:
	# Prüfe ob alle Upgrades maximal sind
	if Player.upgrade_grip >= 5 and Player.upgrade_bait >= 5 and Player.upgrade_line >= 5:
		unlock("ACH_FULLY_UPGRADED")

# ===========================
# DEBUGGING
# ===========================

func reset_all_achievements() -> void:
	"""NUR FÜR TESTING - Setzt alle Achievements zurück"""
	if not steam_ready:
		return
	
	print("🧹 Setze alle Achievements zurück...")
	Steam.resetAllStats(true)  # true = auch Achievements zurücksetzen
	print("✅ Fertig")
