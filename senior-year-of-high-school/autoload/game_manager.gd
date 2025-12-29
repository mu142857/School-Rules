# autoload/game_manager.gd
extends Node

# 时间系统
var month: int = 3      # 3月开始
var day: int = 1        # 1日
var hour: int = 5       # 5点
var minute: int = 30    # 30分

# 核心数值
var pressure: float = 50.0       # 压力值 (0-100%)
var money: int = 120             # 钱 (初始120)
var violation_points: int = 0    # 违纪点 (0-3)
var dropout_rate: float = 0.0    # 劝退值 (0-100%)

# 知识点
var knowledge: Dictionary = {
	"Chinese": 50.0,   # 语文知识点
	"Math": 50.0,      # 数学知识点
	"English": 50.0,   # 外语知识点
	"Physics": 50.0,   # 物理知识点
	"Geography": 50.0, # 地理知识点
	"Biology": 50.0    # 生物知识点
}

# 状态
var fatigue: float = 50.0         # 疲惫值 (0-100%)
var learning_ability: float = 1.0 # 学习能力倍率
var seat: int = 23                # 座位号
var current_scene: String = ""    # 当前场景

# 开发者模式
var dev_mode: bool = false

# 时间流速（每现实秒 = 多少游戏分钟）
var time_scale: float = 0.5  # 可调整

# 特殊日期 {[month, day]: "event_name"}
var special_dates: Dictionary = {
	[3, 1]: "SCHOOL_START",        # 开学
	[3, 15]: "LEADER_INSPECTION",  # 领导听课
	[3, 28]: "MONTHLY_EXAM_1",     # 第一次月考
	[4, 12]: "HEALTH_CHECK",       # 体检日
	[4, 18]: "BLACKOUT_NIGHT",     # 停电夜
	[4, 25]: "MONTHLY_EXAM_2",     # 第二次月考
	[5, 1]: "LABOR_DAY",           # 劳动节（半天假）
	[5, 3]: "PARENT_MEETING",      # 家长会
	[5, 16]: "GRADUATION_PHOTO",   # 拍毕业照
	[5, 23]: "MONTHLY_EXAM_3",     # 第三次月考
	[6, 7]: "GAOKAO"               # 高考
}

# 获取星期几 (1=周一, 7=周日)
func get_weekday() -> int:
	# 3月1日是周一，往后推算
	var total_days = day
	if month >= 4:
		total_days += 31  # 3月有31天
	if month >= 5:
		total_days += 30  # 4月有30天
	if month >= 6:
		total_days += 31  # 5月有31天
	return (total_days - 1) % 7 + 1

# 获取今天的特殊事件（没有则返回空字符串）
func get_today_event() -> String:
	var key = [month, day]
	if special_dates.has(key):
		return special_dates[key]
	return ""

# 生理需求
var hunger: float = 100.0      # 饱食度 0-100%
var bladder: float = 0.0       # 上厕所值 0-100%

# 学业状态
var is_elite_class: bool = false  # 是否在尖子班
var exam_rank: int = 0            # 上次月考排名

# 获取饱食度状态
func get_hunger_status() -> String:
	if hunger <= 2:
		return "STARVING"      # 极饿
	elif hunger <= 10:
		return "HUNGRY"        # 饿
	elif hunger <= 30:
		return "PECKISH"       # 稍饿
	else:
		return "NORMAL"

# 获取上厕所状态
func get_bladder_status() -> String:
	if bladder >= 98:
		return "DESPERATE"     # 极其想上厕所
	elif bladder >= 90:
		return "URGENT"        # 很想上厕所
	elif bladder >= 70:
		return "NEED"          # 想上厕所
	else:
		return "NORMAL"

# 切换开发者模式（按F9）
func _input(event):
	if event.is_action_pressed("ui_dev_toggle"):
		dev_mode = !dev_mode

# 获取所有状态的文本（给开发者面板用）
func get_debug_text() -> String:
	var text = ""
	text += "=== 时间 ===\n"
	text += "%d月%d日 周%d %02d:%02d\n" % [month, day, get_weekday(), hour, minute]
	text += "今日事件: %s\n" % get_today_event()
	text += "\n=== 核心数值 ===\n"
	text += "压力值: %.1f%%\n" % pressure
	text += "钱: %d\n" % money
	text += "违纪点: %d/3\n" % violation_points
	text += "劝退值: %.1f%%\n" % dropout_rate
	text += "\n=== 生理 ===\n"
	text += "饱食度: %.1f%% [%s]\n" % [hunger, get_hunger_status()]
	text += "厕所值: %.1f%% [%s]\n" % [bladder, get_bladder_status()]
	text += "疲惫值: %.1f%%\n" % fatigue
	text += "\n=== 学业 ===\n"
	text += "尖子班: %s\n" % ("是" if is_elite_class else "否")
	text += "上次排名: %d\n" % exam_rank
	text += "学习能力: %.2fx\n" % learning_ability
	for subject in knowledge:
		text += "%s: %.1f%%\n" % [subject, knowledge[subject]]
	text += "\n=== 位置 ===\n"
	text += "座位: %d\n" % seat
	text += "场景: %s\n" % current_scene
	return text
