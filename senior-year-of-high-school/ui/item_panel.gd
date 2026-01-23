 # ui/item_panel.gd

extends Control

# === 节点引用 ===
@onready var item_grid = $LowerSection/ScrollContainer/ItemGrid
@onready var name_label = $UpperSection/InfoPanel/NameLabel
@onready var desc_label = $UpperSection/InfoPanel/DescLabel
@onready var effect_label = $UpperSection/InfoPanel/EffectLabel
@onready var top_icon = $UpperSection/InteractPanel/Icon
@onready var use_button = $UpperSection/InteractPanel/UseButton
@onready var use_button_label = $UpperSection/InteractPanel/UseButton/Lable

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

func _ready():
	# 初始化连接
	if not use_button.pressed.is_connected(_on_use_pressed):
		use_button.pressed.connect(_on_use_pressed)
	
	# 初始状态隐藏详情和按钮
	clear_info()
	# 加载列表
	refresh_inventory()

# === 刷新逻辑 ===

func refresh_inventory():
	# 清空旧格子
	for child in item_grid.get_children():
		child.queue_free()
	
	# 遍历固定列表，生成所有格子
	for id in ALL_ITEM_LIST:
		var count = 0
		var owned = false
		var consumable = false
		
		# 判断是消耗品还是永久物品
		if InventorySystem.consumables.has(id):
			consumable = true
			count = InventorySystem.consumables[id]
			owned = (count > 0)
		else:
			consumable = false
			owned = InventorySystem.has_item(id)
		
		# 在开发者模式下强制视为拥有
		if GameManager.dev_mode:
			owned = true
			
		create_slot_ext(id, count, consumable, owned)

func create_slot_ext(id: String, count: int, consumable: bool, owned: bool):
	var slot = item_slot_scene.instantiate()
	item_grid.add_child(slot)
	
	var img_num = ITEM_IMAGE_MAP.get(id, 1)
	var path = "res://items and saves/items/item%d.png" % img_num
	
	slot.setup(id, path, count, consumable)
	slot.set_owned(owned) # 调用你刚写的新函数
	slot.pressed.connect(_on_item_clicked.bind(slot))

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
	
	# === 判定是否真正拥有 (用于显示内容) ===
	var truly_owned = false
	if is_selected_consumable:
		truly_owned = InventorySystem.consumables[id] > 0
	else:
		truly_owned = InventorySystem.has_item(id)
	
	# 开发者模式全开
	if GameManager.dev_mode: truly_owned = true

	# === 分情况显示内容 ===
	if truly_owned:
		# 1. 拥有时：正常显示全部信息
		name_label.text = TranslationSystem.t("ITEM_" + id + "_NAME")
		desc_label.text = TranslationSystem.t("ITEM_" + id + "_DESC")
		effect_label.text = TranslationSystem.t("ITEM_" + id + "_EFFECT")
		
		var img_num = ITEM_IMAGE_MAP.get(id, 1)
		top_icon.texture = load("res://items and saves/items/item%d.png" % img_num)
		top_icon.modulate = Color(1, 1, 1, 1) # 正常颜色
		
		# 显示并配置使用按钮
		use_button.show()
		if is_selected_consumable:
			use_button_label.text = TranslationSystem.t("UI_USE")
		elif id == "BASKETBALL":
			use_button_label.text = TranslationSystem.t("UI_PLAY")
			use_button.disabled = (TimeSystem.get_current_period() != "DINNER")
		else:
			use_button_label.text = TranslationSystem.t("UI_READ")
			use_button.disabled = false
	else:
		# 2. 未拥有时：显示问号，隐藏效果，隐藏按钮
		name_label.text = "???"
		desc_label.text = "尚未获得该物品，无法查看详情。" # 或者翻译 key: ITEM_UNKNOWN_DESC
		effect_label.text = ""
		
		var img_num = ITEM_IMAGE_MAP.get(id, 1)
		top_icon.texture = load("res://items and saves/items/item%d.png" % img_num)
		top_icon.modulate = Color(0, 0, 0, 0.5) # 变成全黑剪影，增加神秘感
		
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
