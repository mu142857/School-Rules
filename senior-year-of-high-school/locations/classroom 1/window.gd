extends Node2D

# ============ 时段枚举 ============
enum TimePhase { MORNING, NOON, AFTERNOON, NIGHT }

# ============ 节点引用 ============
@onready var night_color: Sprite2D = $NightColor
@onready var morning_color: Sprite2D = $MorningColor
@onready var noon_color: Sprite2D = $NoonColor

# ============ 参数 ============
@export var transition_duration: float = 2.0  # 渐变时间（秒）

# ============ 状态 ============
var current_phase: TimePhase = TimePhase.MORNING
var tween: Tween

func _ready() -> void:
	current_phase = get_time_phase()
	apply_phase_instant(current_phase)

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	var new_phase = get_time_phase()
	if new_phase != current_phase:
		transition_to_phase(new_phase)
		current_phase = new_phase

# ============ 获取当前时段 ============
func get_time_phase() -> TimePhase:
	var hour = GameManager.hour
	
	if hour >= 6 and hour <= 9:
		return TimePhase.MORNING
	elif hour >= 10 and hour <= 16:
		return TimePhase.NOON
	elif hour >= 17 and hour <= 19:
		return TimePhase.AFTERNOON
	else:
		return TimePhase.NIGHT

# ============ 渐变切换 ============
func transition_to_phase(phase: TimePhase) -> void:
	if tween and tween.is_running():
		tween.kill()
	
	tween = create_tween()
	tween.set_parallel(true)
	
	match phase:
		TimePhase.MORNING, TimePhase.AFTERNOON:
			tween.tween_property(morning_color, "modulate:a", 1.0, transition_duration)
			tween.tween_property(noon_color, "modulate:a", 0.0, transition_duration)
			tween.tween_property(night_color, "modulate:a", 0.0, transition_duration)
			
		TimePhase.NOON:
			tween.tween_property(morning_color, "modulate:a", 0.0, transition_duration)
			tween.tween_property(noon_color, "modulate:a", 1.0, transition_duration)
			tween.tween_property(night_color, "modulate:a", 0.0, transition_duration)
			
		TimePhase.NIGHT:
			tween.tween_property(morning_color, "modulate:a", 0.0, transition_duration)
			tween.tween_property(noon_color, "modulate:a", 0.0, transition_duration)
			tween.tween_property(night_color, "modulate:a", 1.0, transition_duration)

# ============ 瞬间切换（初始化用）============
func apply_phase_instant(phase: TimePhase) -> void:
	match phase:
		TimePhase.MORNING, TimePhase.AFTERNOON:
			morning_color.modulate.a = 1.0
			noon_color.modulate.a = 0.0
			night_color.modulate.a = 0.0
			
		TimePhase.NOON:
			morning_color.modulate.a = 0.0
			noon_color.modulate.a = 1.0
			night_color.modulate.a = 0.0
			
		TimePhase.NIGHT:
			morning_color.modulate.a = 0.0
			noon_color.modulate.a = 0.0
			night_color.modulate.a = 1.0
