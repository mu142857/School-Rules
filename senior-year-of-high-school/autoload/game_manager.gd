# autoload/game_manager.gd
extends Node

# === 时间（由 TimeSystem 管理）===
var month: int = 3      # 3月开始
var day: int = 1        # 1日
var hour: int = 5       # 5点
var minute: int = 30    # 30分

# === 核心数值 ===
var pressure: float = 50.0       # 压力值 (0-100%)
var money: int = 120             # 钱 (初始120)
var violation_points: int = 0    # 违纪点 (0-3)
var dropout_rate: float = 0.0    # 劝退值 (0-100%)

# === 知识点 ===
var knowledge: Dictionary = {
	"Chinese": 50.0,   # 语文
	"Math": 50.0,      # 数学
	"English": 50.0,   # 外语
	"Physics": 50.0,   # 物理
	"Geography": 50.0, # 地理
	"Biology": 50.0    # 生物
}

# === 生理需求 ===
var hunger: float = 80.0   # 饱食度 (0-100%)
var bladder: float = 0.0    # 上厕所值 (0-100%)
var fatigue: float = 5.0   # 疲惫值 (0-100%)

# === 学业状态 ===
var is_elite_class: bool = false  # 是否在尖子班
var exam_rank: int = 0            # 上次月考排名
var learning_ability: float = 1.0 # 学习能力倍率

# === 位置 ===
var seat: int = 23             # 座位号
var current_scene: String = "" # 当前场景

# === 开发者模式 ===
var dev_mode: bool = false

func _input(event):
	if event.is_action_pressed("ui_dev_toggle"):
		dev_mode = !dev_mode
