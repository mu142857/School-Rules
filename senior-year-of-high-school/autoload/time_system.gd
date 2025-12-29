# autoload/time_system.gd
extends Node

# 时间流速（每现实秒 = 多少游戏分钟）
var time_scale: float = 0.1  # 可调整（计划0.5）
var time_accumulator: float = 0.0

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

func _process(delta):
	advance_time(delta)

# 时间流动
func advance_time(delta):
	time_accumulator += delta
	while time_accumulator >= time_scale:
		time_accumulator -= time_scale
		GameManager.minute += 1
		if GameManager.minute >= 60:
			GameManager.minute = 0
			GameManager.hour += 1
		if GameManager.hour >= 24:
			GameManager.hour = 0
			GameManager.day += 1
		# 月份进位（3月31天，4月30天，5月31天）
		var days_in_month = [0, 0, 0, 31, 30, 31, 30]
		if GameManager.day > days_in_month[GameManager.month]:
			GameManager.day = 1
			GameManager.month += 1

# 获取星期几 (1=周一, 7=周日)
func get_weekday() -> int:
	var total_days = GameManager.day
	if GameManager.month >= 4:
		total_days += 31
	if GameManager.month >= 5:
		total_days += 30
	if GameManager.month >= 6:
		total_days += 31
	return (total_days - 1) % 7 + 1

# 获取今日特殊事件
func get_today_event() -> String:
	var key = [GameManager.month, GameManager.day]
	if special_dates.has(key):
		return special_dates[key]
	return ""

# 获取当前时段
func get_current_period() -> String:
	var t = GameManager.hour * 100 + GameManager.minute
	
	# === 凌晨/早晨 ===
	if t < 530:
		return "SLEEPING"
	elif t < 555:
		return "WAKE_UP"
	elif t < 610:
		return "MORNING_RUN"
	elif t < 630:
		return "MORNING_READ"
	elif t < 710:
		return "MORNING_SELF_STUDY"
	elif t < 735:
		return "BREAKFAST"
	elif t < 750:
		return "PRE_CLASS"
	# === 上午 ===
	elif t < 830:
		return "CLASS_1"
	elif t < 840:
		return "BREAK"
	elif t < 920:
		return "CLASS_2"
	elif t < 950:
		return "LONG_BREAK"
	elif t < 1030:
		return "CLASS_3"
	elif t < 1040:
		return "BREAK"
	elif t < 1125:
		return "CLASS_4"
	elif t < 1200:
		return "MINI_SELF_STUDY"
	# === 中午 ===
	elif t < 1240:
		return "LUNCH"
	elif t < 1355:
		return "NAP"
	elif t < 1400:
		return "PRE_CLASS"
	# === 下午 ===
	elif t < 1440:
		return "CLASS_5"
	elif t < 1450:
		return "BREAK"
	elif t < 1530:
		return "CLASS_6"
	elif t < 1600:
		return "EXERCISE_BREAK"
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
		return "DINNER"
	elif t < 1910:
		return "EVENING_SELF_STUDY"
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
		return "DORM_RETURN"
	else:
		return "SLEEPING"
