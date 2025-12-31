# autoload/time_system.gd
extends Node

# 时间流速（每现实秒 = 多少游戏分钟）
var time_scale: float = 0.1  # 可调整（计划0.5）
var time_accumulator: float = 0.0
var is_paused: bool = false
var pause_reason: String = ""  # "CLASS" 或 "SLEEP"
var last_period: String = ""

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
	if not is_paused:
		advance_time(delta)
	check_auto_pause()

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

# 跳过指定分钟（同时更新数值）
func skip_minutes(minutes: int):
	for i in range(minutes):
		GameManager.minute += 1
		if GameManager.minute >= 60:
			GameManager.minute = 0
			GameManager.hour += 1
		if GameManager.hour >= 24:
			GameManager.hour = 0
			GameManager.day += 1
		var days_in_month = [0, 0, 0, 31, 30, 31, 30]
		if GameManager.day > days_in_month[GameManager.month]:
			GameManager.day = 1
			GameManager.month += 1
		
		# 触发数值更新
		StatsSystem.on_minute_passed()
		BuffSystem.on_minute_passed()

# 检查是否需要自动暂停
func check_auto_pause():
	var current_period = get_current_period()
	
	# 时段变化时检查
	if current_period != last_period:
		last_period = current_period
		
		# 上课时间暂停
		if current_period.begins_with("CLASS"):
			pause_for_class()
		
		# 睡觉时间暂停（22:30后每次时段变化都检查）
		if current_period == "SLEEPING":
			pause_for_sleep()

		# 午休暂停（需要在座位上）
		if current_period == "NAP":
			pause_for_nap()

# 上课暂停
func pause_for_class():
	is_paused = true
	pause_reason = "CLASS"

# 睡觉暂停
func pause_for_sleep():
	is_paused = true
	pause_reason = "SLEEP"

# 午休暂停
func pause_for_nap():
	is_paused = true
	pause_reason = "NAP"

# 继续时间（选择完成后调用）
func resume_time():
	is_paused = false
	pause_reason = ""

# 获取当前课程对应的学科
func get_current_subject() -> String:
	var period = get_current_period()
	var weekday = get_weekday()
	
	# 简化版课表：根据课程编号和星期决定学科
	# 之后可以做完整课表
	var subjects = ["Chinese", "Math", "English", "Physics", "Geography", "Biology"]
	
	if period.begins_with("CLASS_"):
		var class_num = int(period.split("_")[1])
		var index = (class_num + weekday) % 6
		return subjects[index]
	
	return "Chinese"

# 熬夜检测（每分钟调用）
func check_staying_up():
	var t = GameManager.hour * 100 + GameManager.minute
	# 22:30后还没睡
	if t >= 2230 or t < 530:
		if not is_paused or pause_reason != "SLEEP":
			GameManager.stayed_up_minutes += 1
			# 每30分钟增加3%起床失败概率
			@warning_ignore("integer_division")
			GameManager.wake_up_fail_chance = (GameManager.stayed_up_minutes / 30) * 3.0
	
	# 处理入睡
func handle_sleep():
	if GameManager.stayed_up_minutes > 0:
		# 计算起床失败
		var roll = randf() * 100
		if roll < GameManager.wake_up_fail_chance:
			# 睡过头：从入睡时间往后8小时
			var sleep_hour = GameManager.hour
			GameManager.overslept_until_hour = (sleep_hour + 8) % 24
			BuffSystem.add_violation()
		
		# 熬夜了就加疲惫buff
		BuffSystem.add_buff("TIRED", -1)
	
	# 重置熬夜计数
	GameManager.stayed_up_minutes = 0
	GameManager.wake_up_fail_chance = 0

# 处理睡过头醒来
func handle_oversleep_wake():
	if GameManager.overslept_until_hour > 0:
		# 跳到醒来时间
		GameManager.hour = GameManager.overslept_until_hour
		GameManager.minute = 0
		GameManager.overslept_until_hour = -1
		# 疲惫buff解除（睡够了）
		BuffSystem.remove_buff("TIRED")
