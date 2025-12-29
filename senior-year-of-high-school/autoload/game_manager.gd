# autoload/game_manager.gd
extends Node

# 时间系统
var month: int = 3      # 3月开始
var day: int = 1        # 1日
var hour: int = 5       # 5点
var minute: int = 30    # 30分

# 时间流速（每现实秒 = 多少游戏分钟）
var time_scale: float = 0.1  # 可调整 （计划0.5）

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
	text += "%d月%d日, 星期%d, %02d:%02d\n" % [month, day, get_weekday(), hour, minute]
	text += "当前时段: %s\n" % get_current_period()
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

# 时间流动
var time_accumulator: float = 0.0

func _process(delta):
	advance_time(delta)

func advance_time(delta):
	time_accumulator += delta
	# 每 time_scale 秒，游戏过1分钟
	while time_accumulator >= time_scale:
		time_accumulator -= time_scale
		minute += 1
		if minute >= 60:
			minute = 0
			hour += 1
		if hour >= 24:
			hour = 0
			day += 1
		# 月份进位（简化：3月31天，4月30天，5月31天）
		var days_in_month = [0, 0, 0, 31, 30, 31, 30]  # 索引3=3月
		if day > days_in_month[month]:
			day = 1
			month += 1

# 获取当前时段
func get_current_period() -> String:
	var t = hour * 100 + minute
	
	# === 凌晨/早晨 ===
	if t < 530:
		return "SLEEPING"
	elif t < 550:
		return "WAKE_UP"            # 起床+通勤
	elif t < 610:
		return "MORNING_RUN"        # 跑操
	elif t < 630:
		return "MORNING_READ"       # 早读
	elif t < 710:
		return "MORNING_SELF_STUDY" # 早自习
	elif t < 735:
		return "BREAKFAST"          # 吃早饭
	elif t < 750:
		return "PRE_CLASS"          # 课前自习
	# === 上午 ===
	elif t < 830:
		return "CLASS_1"
	elif t < 840:
		return "BREAK"
	elif t < 920:
		return "CLASS_2"
	elif t < 950:
		return "LONG_BREAK"         # 大课间
	elif t < 1030:
		return "CLASS_3"
	elif t < 1040:
		return "BREAK"
	elif t < 1125:
		return "CLASS_4"
	elif t < 1200:
		return "MINI_SELF_STUDY"    # 小自习
	# === 中午 ===
	elif t < 1240:
		return "LUNCH"
	elif t < 1355:
		return "NAP"                # 午休
	elif t < 1400:
		return "PRE_CLASS"          # 课前预习
	# === 下午 ===
	elif t < 1440:
		return "CLASS_5"
	elif t < 1450:
		return "BREAK"
	elif t < 1530:
		return "CLASS_6"
	elif t < 1600:
		return "EXERCISE_BREAK"     # 课间操
	elif t < 1640:
		return "CLASS_7"
	elif t < 1650:
		return "BREAK"
	elif t < 1730:
		return "CLASS_8"
	elif t < 1740:
		return "BREAK"
	elif t < 1820:
		return "CLASS_9"
	# === 晚上 ===
	elif t < 1845:
		return "DINNER"             # 晚饭
	elif t < 1910:
		return "EVENING_SELF_STUDY" # 晚自习
	elif t < 2000:
		return "CLASS_10"
	elif t < 2010:
		return "BREAK"
	elif t < 2100:
		return "CLASS_11"
	elif t < 2110:
		return "BREAK"
	elif t < 2200:
		return "CLASS_12"
	elif t < 2230:
		return "DORM_RETURN"        # 回宿舍收拾
	else:
		return "SLEEPING"
