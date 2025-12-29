# autoload/stats_system.gd
extends Node

# === 数值变化速率（每游戏分钟）===
var hunger_decay: float = 0.05      # 饱食度下降
var bladder_gain: float = 0.04      # 厕所值上升

# === 疲惫值计算用 ===
var today_study_minutes: int = 0    # 今日学习时长
var today_sleep_minutes: int = 0    # 今日睡眠时长
var last_day: int = -1              # 记录上一天

# 上一次处理的分钟
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
			calculate_fatigue()  # 结算昨日疲惫值
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
	
	# === 厕所值上升 ===
	var bladder_rate = bladder_gain
	if GameManager.hunger > 70:
		bladder_rate *= 1.5
	GameManager.bladder = min(100, GameManager.bladder + bladder_rate)
	
	# === 压力值 ===
	update_pressure(period)
	
	# === 疲惫值100%强制睡觉 ===
	if GameManager.fatigue >= 100:
		force_sleep()

# 每日结算疲惫值
func calculate_fatigue():
	# 理想睡眠约480分钟（8小时），学习约600分钟（10小时）
	var ideal_sleep = 480.0
	var sleep_ratio = today_sleep_minutes / ideal_sleep  # >1表示睡够了
	
	# 睡眠不足会增加疲惫值
	if sleep_ratio >= 1.0:
		GameManager.fatigue = max(0, GameManager.fatigue - 10)  # 睡够了恢复
	elif sleep_ratio >= 0.75:
		GameManager.fatigue = min(100, GameManager.fatigue + 5)  # 稍微不足
	elif sleep_ratio >= 0.5:
		GameManager.fatigue = min(100, GameManager.fatigue + 15) # 明显不足
	else:
		GameManager.fatigue = min(100, GameManager.fatigue + 30) # 严重不足

# 强制睡觉
func force_sleep():
	# TODO: 触发强制睡觉事件
	pass

# 压力值变化
func update_pressure(period: String):
	var pressure_change = 0.0
	
	# 生理状态影响
	if GameManager.hunger <= 10:
		pressure_change += 0.1
	if GameManager.bladder >= 90:
		pressure_change += 0.15
	
	# 时段影响
	match period:
		"SLEEPING", "NAP":
			pressure_change -= 0.2
		"BREAK", "LONG_BREAK":
			pressure_change -= 0.05
		"LUNCH", "DINNER", "BREAKFAST":
			pressure_change -= 0.15  # 吃饭减压更多
		_:
			if period.begins_with("CLASS"):
				pressure_change += 0.05
	
	GameManager.pressure = clamp(GameManager.pressure + pressure_change, 0, 100)

# === 状态判断 ===

func get_hunger_status() -> String:
	if GameManager.hunger <= 2:
		return "STARVING"
	elif GameManager.hunger <= 10:
		return "HUNGRY"
	elif GameManager.hunger <= 30:
		return "PECKISH"
	else:
		return "NORMAL"

func get_bladder_status() -> String:
	if GameManager.bladder >= 98:
		return "DESPERATE"
	elif GameManager.bladder >= 90:
		return "URGENT"
	elif GameManager.bladder >= 70:
		return "NEED"
	else:
		return "NORMAL"

# 学习效率（指数关系）
func get_learning_efficiency() -> float:
	var efficiency = GameManager.learning_ability
	
	# 疲惫值影响（指数关系）
	# 20%疲惫 → 约97%效率
	# 50%疲惫 → 约85%效率
	# 80%疲惫 → 约50%效率
	# 100%疲惫 → 0%效率
	var fatigue_factor = 1.0 - pow(GameManager.fatigue / 100.0, 2.5)
	efficiency *= fatigue_factor
	
	# 极端生理状态影响
	if GameManager.hunger <= 2:
		efficiency *= 0.1
	elif GameManager.hunger <= 10:
		efficiency *= 0.5
	
	if GameManager.bladder >= 98:
		efficiency *= 0.05
	elif GameManager.bladder >= 90:
		efficiency *= 0.4
	
	return efficiency
