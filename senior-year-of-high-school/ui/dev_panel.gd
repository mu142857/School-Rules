# ui/dev_panel.gd
extends CanvasLayer

@onready var panel = $Panel
@onready var label = $Panel/ScrollContainer/Label

func _ready():
	panel.visible = false
	panel.position = Vector2.ZERO
	panel.custom_minimum_size = Vector2(280, 400)

func _process(_delta):
	if GameManager.dev_mode:
		panel.visible = true
		label.text = get_debug_text()
	else:
		panel.visible = false

func get_debug_text() -> String:
	var text = ""
	text += "=== 时间 ===\n"
	text += "%d月%d日, 星期%d, %02d:%02d\n" % [GameManager.month, GameManager.day, TimeSystem.get_weekday(), GameManager.hour, GameManager.minute]
	text += "当前时段: %s\n" % TimeSystem.get_current_period()
	text += "今日事件: %s\n" % TimeSystem.get_today_event()
	text += "\n=== 核心数值 ===\n"
	text += "压力值: %.1f%%\n" % GameManager.pressure
	text += "钱: %d\n" % GameManager.money
	text += "违纪点: %d/3\n" % GameManager.violation_points
	text += "劝退值: %.1f%%\n" % GameManager.dropout_rate
	text += "\n=== 生理 ===\n"
	text += "饱食度: %.1f%% [%s]\n" % [GameManager.hunger, StatsSystem.get_hunger_status()]
	text += "厕所值: %.1f%% [%s]\n" % [GameManager.bladder, StatsSystem.get_bladder_status()]
	text += "疲惫值: %.1f%%\n" % GameManager.fatigue
	text += "学习效率: %.0f%%\n" % (StatsSystem.get_learning_efficiency() * 100)
	text += "\n=== 学业 ===\n"
	text += "尖子班: %s\n" % ("是" if GameManager.is_elite_class else "否")
	text += "上次排名: %d\n" % GameManager.exam_rank
	text += "学习能力: %.2fx\n" % GameManager.learning_ability
	for subject in GameManager.knowledge:
		text += "%s: %.1f%%\n" % [subject, GameManager.knowledge[subject]]
	text += "\n=== 位置 ===\n"
	text += "座位: %d\n" % GameManager.seat
	text += "场景: %s\n" % GameManager.current_scene
	return text
