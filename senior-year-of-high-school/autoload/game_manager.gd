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
	"Chinese": 50,
	"Math": 50,
	"English": 50,
	"Physics": 50,
	"Geography": 50,
	"Biology": 50
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

func _ready():
	# 如果是新游戏（历史记录为空），记录一下开局初始值
	if knowledge_history.is_empty():
		# 预填 13 天的模拟数据 (40-60分之间)
		for i in range(13):
			var fake_k = {
				"month": month, 
				"day": day, # 实际项目中可以写逻辑让日期递减，这里简化处理
				"Chinese": (randi_range(20, 28) + i * 2), # 24 is the base
				"Math": (randi_range(10, 38) + i * 2),
				"English": (randi_range(18, 30) + i * 2),
				"Physics": (randi_range(13, 35) + i * 2),
				"Geography": (randi_range(18, 30) + i * 2),
				"Biology": (randi_range(16, 32) + i * 2)
			}
			knowledge_history.append(fake_k)
		
		# 第 14 天：存入当前的真实初始值 (50分)
		record_current_knowledge()

	# 时间分配也给个初始填充，防止饼图报错
	if time_allocation_history.is_empty():
		add_record({
			"month": month, "day": day,
			"sleep": 420, "study": 480, "exercise": 60, "other": 480
		})

# 封装一个记录知识点的方法，方便多处调用
func record_current_knowledge():
	var k_record = {
		"month": month,
		"day": day,
		"Chinese": knowledge["Chinese"],
		"Math": knowledge["Math"],
		"English": knowledge["English"],
		"Physics": knowledge["Physics"],
		"Geography": knowledge["Geography"],
		"Biology": knowledge["Biology"]
	}
	knowledge_history.append(k_record)
	# 限制长度
	if knowledge_history.size() > MAX_HISTORY_DAYS:
		knowledge_history.pop_front()
	
	# 同时也给时间分配存一个初始值，防止饼图报错
	if time_allocation_history.is_empty():
		add_record({
			"month": month, "day": day,
			"sleep": 420, "study": 480, "exercise": 60, "other": 480
		})
