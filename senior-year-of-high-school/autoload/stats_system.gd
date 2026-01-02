# autoload/stats_system.gd
extends Node

# === 数值变化速率（每游戏分钟）===
var hunger_decay: float = 0.023     # 饱食度下降

# === 每日结算用 ===
var last_minute: int = -1
var last_day: int = -1
# 时间分配记录
var today_sleep_minutes: int = 0
var today_study_minutes: int = 0
var today_exercise_minutes: int = 0

func _process(_delta):
	if GameManager.minute != last_minute:
		last_minute = GameManager.minute
		on_minute_passed()

func on_minute_passed():
		
	# 饱食度下降
	GameManager.hunger = max(0, GameManager.hunger - hunger_decay)

func add_sleep_time(minutes: int):
	today_sleep_minutes += minutes

func add_study_time(minutes: int):
	today_study_minutes += minutes

func add_exercise_time(minutes: int):
	today_exercise_minutes += minutes

func get_other_minutes() -> int:
	return 1440 - today_sleep_minutes - today_study_minutes - today_exercise_minutes

# === 每日结算（睡觉后触发）===
func daily_settlement():
	# --- 新增：记录知识点历史 ---
	var k_record = {
		"month": GameManager.month,
		"day": GameManager.day
	}
	for subject in GameManager.knowledge:
		k_record[subject] = GameManager.knowledge[subject]
	
	GameManager.knowledge_history.append(k_record)
	# 限制长度
	if GameManager.knowledge_history.size() > GameManager.MAX_HISTORY_DAYS:
		GameManager.knowledge_history.pop_front()
	# -------------------------

	# 原有的时间记录逻辑（建议改为调用 GameManager.add_record）
	var time_record = {
		"month": GameManager.month,
		"day": GameManager.day,
		"sleep": today_sleep_minutes,
		"study": today_study_minutes,
		"exercise": today_exercise_minutes,
		"other": get_other_minutes()
	}
	GameManager.add_record(time_record) # 调用这个会发射信号
	
	# 重置
	today_sleep_minutes = 0
	today_study_minutes = 0
	today_exercise_minutes = 0
	
	# 知识点每天减少4点
	for subject in GameManager.knowledge:
		GameManager.knowledge[subject] = max(0, GameManager.knowledge[subject] - 4)
	
	# 紧迫感
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

# === 参加跑操 ===
func attend_morning_run():
	add_exercise_time(15)

# === 上课获得知识点 ===
func attend_class(subject: String, effort_level: int):
	if effort_level == 0:
		# 上课睡觉
		BuffSystem.remove_buff("TIRED")
		add_sleep_time(40)
		return
	
	# 正常上课记录学习时间
	add_study_time(40)
	
	# 基础知识点 1-4
	var base_points = effort_level
	var efficiency_mod = GameManager.learning_efficiency[subject]
	var buff_mod = BuffSystem.get_efficiency_modifier(subject)
	var item_bonus = InventorySystem.get_and_clear_class_bonus()
	
	var total_points = base_points + efficiency_mod + buff_mod + item_bonus
	GameManager.knowledge[subject] += total_points
	
	var pressure_change = BuffSystem.get_class_pressure_change()
	GameManager.pressure = clamp(GameManager.pressure + pressure_change, 0, 100)
	
	BuffSystem.clear_class_buffs()

func sleep_to_next_day():
	# 完整睡眠减压
	GameManager.pressure = max(0, GameManager.pressure - 5)
	
	# 解除疲惫buff
	BuffSystem.remove_buff("TIRED")
	
	# 跳到第二天 5:30
	GameManager.day += 1
	var days_in_month = [0, 0, 0, 31, 30, 31, 30]
	if GameManager.day > days_in_month[GameManager.month]:
		GameManager.day = 1
		GameManager.month += 1
	GameManager.hour = 5
	GameManager.minute = 30
	
	# 重置熬夜计数
	GameManager.stayed_up_minutes = 0
	GameManager.wake_up_fail_chance = 0
	
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
