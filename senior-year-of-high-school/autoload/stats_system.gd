# autoload/stats_system.gd
extends Node

# === 数值变化速率（每游戏分钟）===
var hunger_decay: float = 0.023     # 饱食度下降

# === 每日结算用 ===
var today_study_minutes: int = 0
var today_sleep_minutes: int = 0
var last_day: int = -1
var last_minute: int = -1

func _process(_delta):
	if GameManager.minute != last_minute:
		last_minute = GameManager.minute
		update_stats()

func update_stats():
	var period = TimeSystem.get_current_period()
	
	# === 检测新的一天 ===
	if GameManager.day != last_day:
		if last_day != -1:
			daily_settlement()  # 每日结算
		last_day = GameManager.day
		today_study_minutes = 0
		today_sleep_minutes = 0
	
	# === 记录今日时间分配 ===
	if period == "SLEEPING" or period == "NAP":
		today_sleep_minutes += 1
	elif period.begins_with("CLASS") or period.ends_with("SELF_STUDY") or period == "MORNING_READ":
		today_study_minutes += 1
	
	# === 饱食度下降 ===
	GameManager.hunger = max(0, GameManager.hunger - hunger_decay)

# === 每日结算（睡觉后触发）===
func daily_settlement():
	# 知识点每天减少4点
	for subject in GameManager.knowledge:
		GameManager.knowledge[subject] = max(0, GameManager.knowledge[subject] - 4)
	
	# 紧迫感：第三次月考后每天压力+5%
	if BuffSystem.has_buff("URGENCY"):
		GameManager.pressure = min(100, GameManager.pressure + 5)

# === 吃饭 ===
func eat_meal(is_expensive: bool = false):
	if is_expensive:
		GameManager.hunger = min(100, GameManager.hunger + 20)
		GameManager.pressure = max(0, GameManager.pressure - 7)
		GameManager.money -= 10  # 昂贵的饭价格
	else:
		GameManager.hunger = min(100, GameManager.hunger + 20)
		GameManager.pressure = max(0, GameManager.pressure - 5)
		GameManager.money -= 5   # 普通饭价格
	# 添加消化 Buff（10分钟，每分钟+2厕所值）
	BuffSystem.add_buff("DIGESTING", 10)

# === 喝东西 ===
func drink(drink_type: String):
	match drink_type:
		"MILK":
			GameManager.pressure = max(0, GameManager.pressure - 10)
			GameManager.money -= 3
		"GLUCOSE":
			GameManager.hunger = min(100, GameManager.hunger + 5)
			# 无消化 Buff
			GameManager.money -= 2
		"COLA":
			GameManager.pressure = max(0, GameManager.pressure - 20)
			GameManager.money -= 4

# === 上厕所 ===
func use_toilet():
	GameManager.toilet_desire = 0

# === 上课获得知识点 ===
func attend_class(subject: String, effort_level: int):
	# effort_level: 0=睡觉, 1=消极, 2=普通, 3=认真, 4=积极
	if effort_level == 0:
		# 上课睡觉：压力不变，知识点不变
		return
	
	# 基础知识点 1-4
	var base_points = effort_level
	
	# 加上学习效率
	var efficiency_mod = GameManager.learning_efficiency[subject]
	
	# 加上 Buff 修正
	var buff_mod = BuffSystem.get_efficiency_modifier(subject)
	
	var total_points = base_points + efficiency_mod + buff_mod
	GameManager.knowledge[subject] += total_points
	
	# 上课压力变化
	var pressure_change = BuffSystem.get_class_pressure_change()
	GameManager.pressure = clamp(GameManager.pressure + pressure_change, 0, 100)

# === 睡觉（跳到第二天）===
func sleep_to_next_day():
	# 完整睡眠减压
	GameManager.pressure = max(0, GameManager.pressure - 5)
	
	# 跳到第二天 5:30
	GameManager.day += 1
	var days_in_month = [0, 0, 0, 31, 30, 31, 30]
	if GameManager.day > days_in_month[GameManager.month]:
		GameManager.day = 1
		GameManager.month += 1
	GameManager.hour = 5
	GameManager.minute = 30
	
	# 触发每日结算
	daily_settlement()

# === 状态判断 ===
func get_hunger_status() -> String:
	if GameManager.hunger <= 0:
		return "STARVING_HOME"  # 回家
	elif GameManager.hunger < 10:
		return "STARVING"
	elif GameManager.hunger < 20:
		return "HUNGRY"
	elif GameManager.hunger < 40:
		return "PECKISH"
	else:
		return "NORMAL"

func get_toilet_status() -> String:
	if GameManager.toilet_desire >= 100:
		return "CONSTIPATED"
	elif GameManager.toilet_desire >= 50:
		return "NEED"
	else:
		return "NORMAL"
