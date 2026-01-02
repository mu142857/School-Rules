# autoload/game_manager.gd
extends Node

# === 时间（由 TimeSystem 管理）===
var month: int = 3
var day: int = 1
var hour: int = 5
var minute: int = 30

# === 核心数值 ===
var pressure: float = 50.0       # 压力值 (0-100%)
var money: int = 120             # 钱
var violation_points: int = 0    # 违纪点 (0-3)
var dropout_rate: float = 0.0    # 劝退值 (0-100%)

# === 睡眠 ===
var sleep_start_hour: int = 22  # 入睡时的小时
var sleep_start_minute: int = 30  # 入睡时的分钟

# === 知识点（点数制）===
var knowledge: Dictionary = {
	"Chinese": 100,
	"Math": 100,
	"English": 100,
	"Physics": 100,
	"Geography": 100,
	"Biology": 100
}

# === 学习效率（点数制，加到上课获得的知识点上）===
var learning_efficiency: Dictionary = {
	"Chinese": 0,
	"Math": 0,
	"English": 0,
	"Physics": 0,
	"Geography": 0,
	"Biology": 0
}

# === 生理需求 ===
var hunger: float = 80.0    # 饱食度 (0-100%)
var toilet_desire: float = 0.0    # 上厕所值 (无上限)
var fatigue: float = 15.0   # 疲惫值 (0-100%)

# === 座位 ===
var seat_row: int = 3       # 排 (1-6)
var seat_col: int = 5       # 列 (1-10)

# === 学业状态 ===
var is_elite_class: bool = false
var exam_rank: int = 0

# === 当前位置 ===
var current_scene: String = ""

# === 开发者模式 ===
var dev_mode: bool = false

# === 历史数据（用于图表）===
var knowledge_history: Array = []  # [{day, month, Chinese, Math, ...}, ...]
var time_allocation_history: Array = []  # [{day, month, sleep, study, eat, ...}, ...]

# 最多存90天数据（3个月）
const MAX_HISTORY_DAYS: int = 90

# 熬夜状况
var stayed_up_minutes: int = 0      # 熬夜分钟数
var wake_up_fail_chance: float = 0  # 起床失败概率
var overslept_until_hour: int = -1  # 睡过头醒来时间（-1表示正常）

# 历史更新数据
signal history_updated

func _input(event):
	if event.is_action_pressed("ui_dev_toggle"):
		dev_mode = !dev_mode

# 判断座位位置
func is_front_row() -> bool:
	return seat_row == 1

func is_back_row() -> bool:
	return seat_row == 6

func add_record(data):
	time_allocation_history.append(data)
	history_updated.emit() # 发射信号
