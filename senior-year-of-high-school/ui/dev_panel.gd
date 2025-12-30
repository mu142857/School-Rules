# ui/dev_panel.gd
extends CanvasLayer

@onready var panel = $Panel
@onready var info_label = $Panel/ScrollContainer/HBoxContainer/InfoLabel
@onready var dev_buttons = $Panel/ScrollContainer/HBoxContainer/DevButtonsContainer
@onready var stats_label = $Panel/ScrollContainer/HBoxContainer/StatsLabel
@onready var action_buttons = $Panel/ScrollContainer/HBoxContainer/ActionButtonsContainer
@onready var buff_label = $Panel/ScrollContainer/HBoxContainer/BuffLabel

var pixel_font: Font
var current_subject: String = "Chinese"

func _ready():
	panel.visible = false
	panel.position = Vector2.ZERO
	
	pixel_font = load("res://shared/PixelFont.ttf")
	
	# 顶部对齐
	info_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	dev_buttons.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	stats_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	action_buttons.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	buff_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	
	# 设置各列最小宽度
	info_label.custom_minimum_size.x = 200
	dev_buttons.custom_minimum_size.x = 150
	stats_label.custom_minimum_size.x = 200
	action_buttons.custom_minimum_size.x = 150
	buff_label.custom_minimum_size.x = 150
	
	create_dev_buttons()
	create_action_buttons()

func _process(_delta):
	if GameManager.dev_mode:
		panel.visible = true
		update_labels()
	else:
		panel.visible = false

func update_labels():
	info_label.text = get_info_text()
	stats_label.text = get_stats_text()
	buff_label.text = get_buff_text()

# === 不可控信息 ===
func get_info_text() -> String:
	var text = "=== 时间 ===\n"
	text += "%d月%d日 星期%d\n" % [GameManager.month, GameManager.day, TimeSystem.get_weekday()]
	text += "%02d:%02d\n" % [GameManager.hour, GameManager.minute]
	text += "时段: %s\n" % TimeSystem.get_current_period()
	text += "事件: %s\n" % TimeSystem.get_today_event()
	text += "\n=== 座位 ===\n"
	text += "第%d排 第%d列\n" % [GameManager.seat_row, GameManager.seat_col]
	if GameManager.is_front_row():
		text += "[前排]\n"
	elif GameManager.is_back_row():
		text += "[后排]\n"
	text += "\n=== 学业 ===\n"
	text += "尖子班: %s\n" % ("是" if GameManager.is_elite_class else "否")
	text += "排名: %d\n" % GameManager.exam_rank
	text += "\n=== 知识点 ===\n"
	for subject in GameManager.knowledge:
		var eff = GameManager.learning_efficiency[subject]
		var buff_mod = BuffSystem.get_efficiency_modifier(subject)
		text += "%s: %d (%+d)\n" % [subject, GameManager.knowledge[subject], eff + buff_mod]
	text += "\n=== 位置 ===\n"
	text += "%s\n" % GameManager.current_scene
	return text

# === 可控信息 ===
func get_stats_text() -> String:
	var text = "=== 核心 ===\n"
	text += "压力: %.1f%%\n" % GameManager.pressure
	text += "钱: %d\n" % GameManager.money
	text += "违纪: %d/3\n" % GameManager.violation_points
	text += "劝退: %.1f%%\n" % GameManager.dropout_rate
	text += "\n=== 生理 ===\n"
	text += "饱食: %.1f%%\n" % GameManager.hunger
	text += "[%s]\n" % StatsSystem.get_hunger_status()
	text += "厕所: %.1f%%\n" % GameManager.toilet_desire
	text += "[%s]\n" % StatsSystem.get_toilet_status()
	text += "疲惫: %.1f%%\n" % GameManager.fatigue
	text += "\n=== 当前学科 ===\n"
	text += "%s\n" % current_subject
	return text

# === Buff列表 ===
func get_buff_text() -> String:
	var text = "=== Buff ===\n"
	if BuffSystem.active_buffs.is_empty():
		text += "无\n"
	else:
		for buff_name in BuffSystem.active_buffs:
			if BuffSystem.active_buffs[buff_name].has("duration"):
				text += "%s\n(%d分钟)\n" % [buff_name, BuffSystem.active_buffs[buff_name]["duration"]]
			else:
				text += "%s\n" % buff_name
	return text

# === 数值调整按钮（开发用）===
func create_dev_buttons():
	add_button(dev_buttons, "压力+10", func(): GameManager.pressure = min(100, GameManager.pressure + 10))
	add_button(dev_buttons, "压力-10", func(): GameManager.pressure = max(0, GameManager.pressure - 10))
	add_button(dev_buttons, "钱+50", func(): GameManager.money += 50)
	add_button(dev_buttons, "饱食+20", func(): GameManager.hunger = min(100, GameManager.hunger + 20))
	add_button(dev_buttons, "厕所+20", func(): GameManager.toilet_desire += 20)
	add_button(dev_buttons, "厕所清零", func(): GameManager.toilet_desire = 0)
	add_label(dev_buttons, "--- 座位 ---")
	add_button(dev_buttons, "第1排", func(): GameManager.seat_row = 1)
	add_button(dev_buttons, "第3排", func(): GameManager.seat_row = 3)
	add_button(dev_buttons, "第6排", func(): GameManager.seat_row = 6)
	add_label(dev_buttons, "--- 时间 ---")
	add_button(dev_buttons, "跳到明天", func(): StatsSystem.sleep_to_next_day())

# === 游戏内操作按钮 ===
func create_action_buttons():
	add_label(action_buttons, "--- 吃饭 ---")
	add_button(action_buttons, "普通饭", func(): StatsSystem.eat_meal(false))
	add_button(action_buttons, "昂贵的饭", func(): StatsSystem.eat_meal(true))
	add_label(action_buttons, "--- 饮品 ---")
	add_button(action_buttons, "喝奶", func(): StatsSystem.drink("MILK"))
	add_button(action_buttons, "喝葡萄糖", func(): StatsSystem.drink("GLUCOSE"))
	add_button(action_buttons, "喝可乐", func(): StatsSystem.drink("COLA"))
	add_label(action_buttons, "--- 厕所 ---")
	add_button(action_buttons, "上厕所", func(): StatsSystem.use_toilet())
	add_label(action_buttons, "--- 学科 ---")
	add_button(action_buttons, "语文", func(): current_subject = "Chinese")
	add_button(action_buttons, "数学", func(): current_subject = "Math")
	add_button(action_buttons, "英语", func(): current_subject = "English")
	add_button(action_buttons, "物理", func(): current_subject = "Physics")
	add_button(action_buttons, "地理", func(): current_subject = "Geography")
	add_button(action_buttons, "生物", func(): current_subject = "Biology")
	add_label(action_buttons, "--- 上课 ---")
	add_button(action_buttons, "睡觉(0)", func(): StatsSystem.attend_class(current_subject, 0))
	add_button(action_buttons, "消极(1)", func(): StatsSystem.attend_class(current_subject, 1))
	add_button(action_buttons, "普通(2)", func(): StatsSystem.attend_class(current_subject, 2))
	add_button(action_buttons, "认真(3)", func(): StatsSystem.attend_class(current_subject, 3))
	add_button(action_buttons, "积极(4)", func(): StatsSystem.attend_class(current_subject, 4))

func add_label(container: Control, text: String):
	var lbl = Label.new()
	lbl.text = text
	lbl.add_theme_font_override("font", pixel_font)
	container.add_child(lbl)

func add_button(container: Control, text: String, callback: Callable):
	var btn = Button.new()
	btn.text = text
	btn.add_theme_font_override("font", pixel_font)
	btn.pressed.connect(callback)
	container.add_child(btn)
