# autoload/buff_system.gd
extends Node

# === 当前激活的 Buff ===
var active_buffs: Dictionary = {}

# Buff 定义 {名称: {剩余分钟, 效果数据}}
# 示例: {"DIGESTING": {"duration": 10, "per_minute_toilet": 2}}

var last_minute: int = -1

func _process(_delta):
	if GameManager.minute != last_minute:
		last_minute = GameManager.minute
		on_minute_passed()

func on_minute_passed():
	update_buffs()
	apply_passive_buffs()

# 每分钟更新 Buff
func update_buffs():
	# 更新有时限的 Buff
	var to_remove = []
	for buff_name in active_buffs:
		if active_buffs[buff_name].has("duration"):
			active_buffs[buff_name]["duration"] -= 1
			# 消化 Buff：每分钟加厕所值
			if buff_name == "DIGESTING":
				GameManager.toilet_desire += 2
			if active_buffs[buff_name]["duration"] <= 0:
				to_remove.append(buff_name)
	for buff_name in to_remove:
		active_buffs.erase(buff_name)

func clear_class_buffs():
	# 上完课清除的buff
	active_buffs.erase("FRESH")      # 口香糖清新
	active_buffs.erase("FOCUSED")    # 柠檬水专注
	active_buffs.erase("ENERGETIC")  # 能量饮料精力充沛

# 应用被动 Buff（根据状态自动判定）
func apply_passive_buffs():
	# === 厕所相关 ===
	if GameManager.toilet_desire >= 100:
		if not active_buffs.has("CONSTIPATED"):
			active_buffs["CONSTIPATED"] = {}  # 便秘
		GameManager.pressure += 0.004
	elif active_buffs.has("CONSTIPATED"):
		active_buffs.erase("CONSTIPATED")
	
	if GameManager.toilet_desire >= 50 and GameManager.toilet_desire < 100:
		if not active_buffs.has("NEED_TOILET"):
			active_buffs["NEED_TOILET"] = {}  # 想上厕所
		GameManager.pressure += 0.003
	elif GameManager.toilet_desire < 50 and active_buffs.has("NEED_TOILET"):
		active_buffs.erase("NEED_TOILET")
	
	# === 饥饿相关 ===
	# 先清除所有饥饿 Buff
	active_buffs.erase("PECKISH")
	active_buffs.erase("HUNGRY")
	active_buffs.erase("STARVING")
	
	if GameManager.hunger <= 0:
		# 触发回家休息两天
		trigger_home_rest()
	elif GameManager.hunger < 10:
		active_buffs["STARVING"] = {}  # 极饿
	elif GameManager.hunger < 20:
		active_buffs["HUNGRY"] = {}    # 饿
	elif GameManager.hunger < 40:
		active_buffs["PECKISH"] = {}   # 稍饿
	
	# === 紧迫感（第三次月考后）===
	if GameManager.month == 5 and GameManager.day >= 23:
		if not active_buffs.has("URGENCY"):
			active_buffs["URGENCY"] = {}
	elif GameManager.month > 5:
		if not active_buffs.has("URGENCY"):
			active_buffs["URGENCY"] = {}

# === 添加 Buff ===
func add_buff(buff_name: String, duration: int = -1):
	if duration > 0:
		active_buffs[buff_name] = {"duration": duration}
	else:
		active_buffs[buff_name] = {}

# === 移除 Buff ===
func remove_buff(buff_name: String):
	active_buffs.erase(buff_name)

# === 检查是否有某 Buff ===
func has_buff(buff_name: String) -> bool:
	return active_buffs.has(buff_name)

# === 获取学习效率修正（所有 Buff 的总和）===
@warning_ignore("unused_parameter")
func get_efficiency_modifier(subject: String) -> int:
	var modifier = 0
	
	# 座位影响
	if GameManager.is_front_row():
		modifier += 1
	elif GameManager.is_back_row():
		modifier -= 1
	
	# 便秘
	if has_buff("CONSTIPATED"):
		modifier -= 1
	
	# 极饿
	if has_buff("STARVING"):
		modifier -= 1
	
	# 口香糖清新
	if has_buff("FRESH"):
		modifier += 1
	
	# 柠檬水专注
	if has_buff("FOCUSED"):
		modifier += 2
	
	# 能量饮料精力充沛
	if has_buff("ENERGETIC"):
		modifier += 3

	# 疲惫buff
	if has_buff("TIRED"):
		modifier -= 1
	
	return modifier

# === 获取每节课压力变化 ===
func get_class_pressure_change() -> float:
	var change = 2.0  # 基础每节课 +2%
	
	# 领导听课日
	if TimeSystem.get_today_event() == "LEADER_INSPECTION":
		change += 1.0
	
	# 座位影响
	if GameManager.is_front_row():
		change += 1.0
	elif GameManager.is_back_row():
		if TimeSystem.get_today_event() != "LEADER_INSPECTION":
			change -= 1.0  # 领导听课时后排无效
	
	return change

# === 回家休息两天 ===
func trigger_home_rest():
	# 跳过两天
	for i in range(2):
		GameManager.day += 1
		var days_in_month = [0, 0, 0, 31, 30, 31, 30]
		if GameManager.day > days_in_month[GameManager.month]:
			GameManager.day = 1
			GameManager.month += 1
	# 恢复状态
	GameManager.hunger = 80.0
	GameManager.toilet_desire = 0.0
	GameManager.pressure = max(0, GameManager.pressure - 20)
	GameManager.hour = 5
	GameManager.minute = 30

# === 获取当前所有 Buff 名称（给开发者面板用）===
func get_buff_list() -> String:
	if active_buffs.is_empty():
		return "无"
	var names = []
	for buff_name in active_buffs:
		if active_buffs[buff_name].has("duration"):
			names.append("%s(%d)" % [buff_name, active_buffs[buff_name]["duration"]])
		else:
			names.append(buff_name)
	return ", ".join(names)

func add_violation():
	GameManager.violation_points += 1
	if GameManager.violation_points >= 3:
		trigger_reflection_week()

# 回家反省一周
func trigger_reflection_week():
	GameManager.violation_points = 0
	# 跳过7天
	for i in range(7):
		GameManager.day += 1
		var days_in_month = [0, 0, 0, 31, 30, 31, 30]
		if GameManager.day > days_in_month[GameManager.month]:
			GameManager.day = 1
			GameManager.month += 1
	# 重置状态
	GameManager.hour = 5
	GameManager.minute = 30
	GameManager.hunger = 80
	GameManager.toilet_desire = 0
	GameManager.pressure += 0
	for subject in GameManager.knowledge:
		GameManager.knowledge[subject] = max(0, GameManager.knowledge[subject] - 20)
