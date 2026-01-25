 # ui/item_panel.gd

extends Control

# === 节点引用 ===
@onready var item_grid = $LowerSection/ScrollContainer/ItemGrid
@onready var name_label = $UpperSection/InfoPanel/NameLabel
@onready var desc_label = $UpperSection/InfoPanel/DescLabel
@onready var effect_label = $UpperSection/InfoPanel/EffectLabel
@onready var top_icon = $UpperSection/InteractPanel/Icon
@onready var use_button = $UpperSection/InteractPanel/UseButton
@onready var use_button_label = $UpperSection/InteractPanel/UseButton/Label

# === 资源预载 ===
var item_slot_scene = preload("res://items and saves/items/item_slot.tscn")

# === 内部变量 ===
var current_selected_id: String = ""
var is_selected_consumable: bool = true

# 图片映射表 (ID -> 数字序号)
const ITEM_IMAGE_MAP = {
	"PREMIUM_MILK": 1, "NORMAL_MILK": 2, "LEIBI": 3, "BEEF_SNACK": 4,
	"SAUSAGE": 5, "GUM": 6, "BISCUIT": 7, "LEMONADE": 8, "ENERGY_DRINK": 9,
	"RELATIVITY": 10, "CUMIN_BOOK": 11, "NY_TIMES": 12, "ERTA": 13,
	"LOW_MATH": 14, "WORLD_MAP": 15, "ERTA2": 16, "SODA": 17
}

const ALL_ITEM_LIST = [
	"SODA", "BEEF_SNACK", "LEIBI", "SAUSAGE", "GUM", 
	"BISCUIT", "LEMONADE", "ENERGY_DRINK", "NORMAL_MILK", "PREMIUM_MILK",
	"ERTA", "NY_TIMES", "CUMIN_BOOK", "LOW_MATH", "WORLD_MAP", 
	"RELATIVITY", "ERTA2", "BASKETBALL"
]

# 定义颜色常量 (十六进制码)
const COLORS = {
	"POSITIVE": "#79ff79", # 亮绿色
	"NEGATIVE": "#ff7979", # 亮红色
	"CHINESE": "#cfa794",  # 灰橙色
	"MATH": "#94aacf",     # 灰蓝色
	"ENGLISH": "#bca4e0",  # 灰粉色
	"PHYSICS": "#7684cf",  # 灰蓝色/紫色
	"BIOLOGY": "#60bd7d",  # 灰绿色
	"GEOGRAPHY": "#aba058", # 灰黄色
	"HUNGER": "#a67c52",   # 灰棕色
	"PRESSURE": "#8b3a4c",  # 灰红色
	"TIME": "#a9b7aa"      # 时间/分钟(灰色)
}

func _ready():
	# 初始化连接
	if not use_button.pressed.is_connected(_on_use_pressed):
		use_button.pressed.connect(_on_use_pressed)
	InventorySystem.inventory_changed.connect(refresh_inventory)
	
	# 初始状态隐藏详情和按钮
	clear_info()
	# 加载列表
	refresh_inventory()

# === 刷新逻辑 ===

func refresh_inventory():
	# 1. 清空 (用普通的 queue_free 就行，不需要 remove_child)
	for child in item_grid.get_children():
		child.queue_free()
	
	# 2. 严格按数据生成
	for id in ALL_ITEM_LIST:
		var count = 0
		var owned = false
		var consumable = false
		
		if InventorySystem.consumables.has(id):
			consumable = true
			count = InventorySystem.consumables[id]
			owned = (count > 0)
		else:
			consumable = false
			owned = InventorySystem.has_item(id)
		
		# 删掉那个强制 owned = true 的逻辑！
		# 只传真实的 owned 状态给格子
		var slot = create_slot_ext(id, count, consumable, owned)
		
		if id == current_selected_id:
			slot.set_selected(true)

func create_slot_ext(id: String, count: int, consumable: bool, owned: bool):
	var slot = item_slot_scene.instantiate()
	item_grid.add_child(slot)
	
	var img_num = ITEM_IMAGE_MAP.get(id, 1)
	var path = "res://items and saves/items/item%d.png" % img_num
	
	slot.setup(id, path, count, consumable)
	slot.set_owned(owned) 
	slot.pressed.connect(_on_item_clicked.bind(slot))
	
	return slot

# === 交互逻辑 ===

func _on_item_clicked(slot):
	# 取消其他格子的选中状态
	for s in item_grid.get_children():
		if s.has_method("set_selected"):
			s.set_selected(false)
	
	# 设置当前选中
	slot.set_selected(true)
	current_selected_id = slot.item_id
	is_selected_consumable = slot.is_consumable
	
	update_info_display()

func update_info_display():
	if current_selected_id == "": 
		clear_info()
		return
		
	var id = current_selected_id
	
	# === 1. 判定是否真正拥有 ===
	var truly_owned = false
	if is_selected_consumable:
		truly_owned = InventorySystem.consumables.get(id, 0) > 0
	else:
		truly_owned = InventorySystem.has_item(id)
	
	if GameManager.dev_mode: truly_owned = true

	# === 2. 分情况显示内容 ===
	if truly_owned:
		# --- 拥有时：正常显示全部信息 ---
		name_label.text = TranslationSystem.t("ITEM_" + id + "_NAME")
		desc_label.text = TranslationSystem.t("ITEM_" + id + "_DESC")
		
		# 处理彩色效果文字（调用下面的染色函数）
		var raw_effect = TranslationSystem.t("ITEM_" + id + "_EFFECT")
		effect_label.text = get_styled_effect_text(raw_effect)
		
		# 加载图标
		var img_num = ITEM_IMAGE_MAP.get(id, 1)
		top_icon.texture = load("res://items and saves/items/item%d.png" % img_num)
		top_icon.modulate = Color(1, 1, 1, 1) # 正常颜色
		top_icon.show()
		
		# 显示并配置按钮
		use_button.show()
		if is_selected_consumable:
			use_button_label.text = TranslationSystem.t("UI_USE") # "食用"
			use_button.disabled = false
		elif id == "BASKETBALL":
			use_button_label.text = TranslationSystem.t("UI_PLAY") # "打球"
			# 篮球只能在晚餐时间使用
			use_button.disabled = (TimeSystem.get_current_period() != "DINNER")
		else:
			use_button_label.text = TranslationSystem.t("UI_READ") # "阅读"
			use_button.disabled = false
	else:
		# --- 未拥有时：显示问号，隐藏详情 ---
		name_label.text = "???"
		desc_label.text = "尚未获得该物品，无法查看详情。"
		effect_label.text = "" # 隐藏效果描述
		
		# 显示全黑剪影图标
		var img_num = ITEM_IMAGE_MAP.get(id, 1)
		top_icon.texture = load("res://items and saves/items/item%d.png" % img_num)
		top_icon.modulate = Color(0, 0, 0, 0.5) 
		top_icon.show()
		
		# 隐藏按钮
		use_button.hide()

func _on_use_pressed():
	if current_selected_id == "": return
	
	var success = false
	
	# 根据类型调用不同的系统方法
	if is_selected_consumable:
		success = InventorySystem.use_consumable(current_selected_id)
	elif current_selected_id == "BASKETBALL":
		success = InventorySystem.play_basketball()
	else:
		success = InventorySystem.read_book(current_selected_id)
	
	if success:
		# 刷新列表（数量减少或物品消失）
		refresh_inventory()
		
		# 检查当前物品是否还存在，不存在则清空详情
		var still_has = false
		if is_selected_consumable:
			if InventorySystem.consumables.get(current_selected_id, 0) > 0:
				still_has = true
		else:
			still_has = InventorySystem.has_item(current_selected_id)
			
		if not still_has and not GameManager.dev_mode:
			clear_info()
		else:
			# 如果还在，更新一下显示（比如数量 label）
			update_info_display()

func clear_info():
	current_selected_id = ""
	name_label.text = ""
	desc_label.text = "选择一个物品查看" # 这里可以换成翻译 key
	effect_label.text = ""
	top_icon.hide()
	use_button.hide()

func get_styled_effect_text(raw_text: String) -> String:
	var styled = raw_text
	
	# 染色符号 (+ 和 -)
	styled = styled.replace("+", "[color=%s]+[/color]" % COLORS.POSITIVE)
	styled = styled.replace("-", "[color=%s]-[/color]" % COLORS.NEGATIVE)
	
	# 染色关键字
	var keywords = {
		"语文": COLORS.CHINESE,
		"数学": COLORS.MATH,
		"英语": COLORS.ENGLISH,
		"物理": COLORS.PHYSICS,
		"生物": COLORS.BIOLOGY,
		"地理": COLORS.GEOGRAPHY,
		"知识点": "#ffffff", # 知识点用纯白突出
		"饱食度": COLORS.HUNGER,
		"压力": COLORS.PRESSURE,
		"耗时": COLORS.TIME,
		"分钟": COLORS.TIME
	}
	
	for key in keywords:
		if styled.contains(key):
			styled = styled.replace(key, "[color=%s]%s[/color]" % [keywords[key], key])
	
	return styled
