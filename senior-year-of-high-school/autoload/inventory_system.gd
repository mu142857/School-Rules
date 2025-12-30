# autoload/inventory_system.gd
extends Node

# === 消耗品库存 ===
var consumables: Dictionary = {
	"SODA": 0,           # 汽水
	"BEEF_SNACK": 0,     # 大刀牛肉
	"LEIBI": 0,          # 雷碧
	"SAUSAGE": 0,        # 火腿肠
	"GUM": 0,            # 口香糖
	"BISCUIT": 0,        # 压缩饼干
	"LEMONADE": 0,       # 柠檬水
	"ENERGY_DRINK": 0,   # 能量饮料
	"NORMAL_MILK": 0,    # 普通奶
	"PREMIUM_MILK": 0,   # 高级奶
}

# === 永久物品（拥有即true）===
var items: Dictionary = {
	"BASKETBALL": false,      # 篮球
	"ERTA": false,            # 红楼梦（语文）
	"NY_TIMES": false,        # 牛约时报（英语）
	"CUMIN_BOOK": false,      # 孜然（生物）
	"LOW_MATH": false,        # 低等数学（数学）
	"WORLD_MAP": false,       # 世界地图（地理）
	"RELATIVITY": false,      # 相错论（物理）
	"ERTA2": false,           # 小黄书（压力）
}

# === 临时Buff（下节课生效后清除）===
var next_class_bonus: Dictionary = {
	"knowledge_bonus": 0,
	"subject": ""
}

# === 使用消耗品 ===
func use_consumable(item_name: String) -> bool:
	# 开发者模式不检查库存
	if not GameManager.dev_mode:
		if consumables.get(item_name, 0) <= 0:
			return false
		consumables[item_name] -= 1
	
	match item_name:
		"SODA":
			GameManager.pressure = max(0, GameManager.pressure - 10)
		"BEEF_SNACK":
			GameManager.pressure = max(0, GameManager.pressure - 4)
			GameManager.hunger = min(100, GameManager.hunger + 4)
			BuffSystem.add_buff("DIGESTING", 4)
		"LEIBI":
			GameManager.pressure = max(0, GameManager.pressure - 10)
		"SAUSAGE":
			GameManager.hunger = min(100, GameManager.hunger + 10)
		"GUM":
			GameManager.pressure = max(0, GameManager.pressure - 1)
			BuffSystem.add_buff("FRESH", -1)
		"BISCUIT":
			GameManager.hunger = min(100, GameManager.hunger + 20)
			GameManager.pressure = max(0, GameManager.pressure - 3)
			BuffSystem.add_buff("DIGESTING", 10)
		"LEMONADE":
			GameManager.pressure = max(0, GameManager.pressure - 3)
			BuffSystem.add_buff("FOCUSED", -1)
		"ENERGY_DRINK":
			GameManager.pressure = max(0, GameManager.pressure - 3)
			GameManager.hunger = min(100, GameManager.hunger + 3)
			BuffSystem.add_buff("ENERGETIC", -1)
		"NORMAL_MILK":
			GameManager.pressure = max(0, GameManager.pressure - 10)
			GameManager.hunger = min(100, GameManager.hunger + 5)
			BuffSystem.add_buff("DIGESTING", 5)
		"PREMIUM_MILK":
			GameManager.pressure = max(0, GameManager.pressure - 15)
			GameManager.hunger = min(100, GameManager.hunger + 7)
			BuffSystem.add_buff("DIGESTING", 7)
	
	return true

# === 读书（耗时10分钟）===
func read_book(book_name: String) -> bool:
	if not GameManager.dev_mode:
		if not items.get(book_name, false):
			return false
	
	match book_name:
		"ERTA":
			GameManager.knowledge["Chinese"] += 1
		"NY_TIMES":
			GameManager.knowledge["English"] += 1
		"CUMIN_BOOK":
			GameManager.knowledge["Biology"] += 1
		"LOW_MATH":
			GameManager.knowledge["Math"] += 1
		"WORLD_MAP":
			GameManager.knowledge["Geography"] += 1
		"RELATIVITY":
			GameManager.knowledge["Physics"] += 1
		"ERTA2":
			GameManager.pressure = max(0, GameManager.pressure - 1)
	
	TimeSystem.skip_minutes(10)
	return true

# === 打篮球（耗时30分钟）===
func play_basketball() -> bool:
	if not GameManager.dev_mode:
		if not items.get("BASKETBALL", false):
			return false
		if TimeSystem.get_current_period() != "DINNER":
			return false
	
	GameManager.pressure = max(0, GameManager.pressure - 5)
	TimeSystem.skip_minutes(30)
	return true

# === 获取下节课加成并清除 ===
func get_and_clear_class_bonus() -> int:
	var bonus = next_class_bonus["knowledge_bonus"]
	next_class_bonus["knowledge_bonus"] = 0
	next_class_bonus["subject"] = ""
	return bonus

# === 添加消耗品 ===
func add_consumable(item_name: String, amount: int = 1):
	if consumables.has(item_name):
		consumables[item_name] += amount

# === 获得永久物品 ===
func acquire_item(item_name: String):
	if items.has(item_name):
		items[item_name] = true

# === 检查是否拥有永久物品 ===
func has_item(item_name: String) -> bool:
	return items.get(item_name, false)
