# res://locations/classroom 1/light_manager.gd

extends Node2D

# ============ 时段枚举 ============
enum TimePhase { MORNING, NOON, AFTERNOON, NIGHT }

# ============ 节点引用 ============
# 上午/下午显示
@onready var window_light_1: Polygon2D = $WindowLight1
@onready var window_light_2: Polygon2D = $WindowLight2
@onready var window_light_3: Polygon2D = $WindowLight3
@onready var dust_1: GPUParticles2D = $Dust1
@onready var dust_2: GPUParticles2D = $Dust2
@onready var dust_3: GPUParticles2D = $Dust3

# 晚上显示
@onready var point_light_1: PointLight2D = $PointLight1
@onready var point_light_2: PointLight2D = $PointLight2
@onready var point_light_3: PointLight2D = $PointLight3
@onready var point_light_4: PointLight2D = $PointLight4
@onready var time_filter: CanvasLayer = $TimeFilter
@onready var night_color_rect: ColorRect = $TimeFilter/NightFilter
@onready var morning_color_rect: ColorRect = $TimeFilter/MorningFilter

# LightOnFloor（父节点的兄弟节点）
@onready var light_on_floor: Node2D = $"../LightOnFloor"

# ============ 参数 ============
@export var transition_duration: float = 2.0  # 渐变时间（秒）

# ============ 状态 ============
var current_phase: TimePhase = TimePhase.MORNING
var tween: Tween

func _ready() -> void:
	# 初始化：根据当前时间设置状态（无渐变）
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
	
	# 上午：6:00 - 9:59
	if hour >= 6 and hour <= 9:
		return TimePhase.MORNING
	# 中午：10:00 - 16:59
	elif hour >= 10 and hour <= 16:
		return TimePhase.NOON
	# 下午：17:00 - 19:59
	elif hour >= 17 and hour <= 19:
		return TimePhase.AFTERNOON
	# 晚上：20:00 - 5:59
	else:
		return TimePhase.NIGHT

# ============ 渐变切换 ============
func transition_to_phase(phase: TimePhase) -> void:
	# 停止之前的 tween
	if tween and tween.is_running():
		tween.kill()
	
	tween = create_tween()
	tween.set_parallel(true)  # 并行执行所有渐变
	
	match phase:
		TimePhase.MORNING, TimePhase.AFTERNOON:
			# 显示上午/下午元素
			fade_in_morning_elements(tween)
			# 隐藏晚上元素
			fade_out_night_elements(tween)
			
		TimePhase.NOON:
			# 全部隐藏
			fade_out_morning_elements(tween)
			fade_out_night_elements(tween)
			
		TimePhase.NIGHT:
			# 隐藏上午/下午元素
			fade_out_morning_elements(tween)
			# 显示晚上元素
			fade_in_night_elements(tween)

# ============ 上午/下午元素渐变 ============
func fade_in_morning_elements(tw: Tween) -> void:
	# MorningFilter
	tw.tween_property(morning_color_rect, "modulate:a", 1.0, transition_duration)
	
	# WindowLight
	tw.tween_property(window_light_1, "modulate:a", 1.0, transition_duration)
	tw.tween_property(window_light_2, "modulate:a", 1.0, transition_duration)
	tw.tween_property(window_light_3, "modulate:a", 1.0, transition_duration)
	
	# Dust（先开启发射，再渐显）
	dust_1.emitting = true
	dust_2.emitting = true
	dust_3.emitting = true
	tw.tween_property(dust_1, "modulate:a", 1.0, transition_duration)
	tw.tween_property(dust_2, "modulate:a", 1.0, transition_duration)
	tw.tween_property(dust_3, "modulate:a", 1.0, transition_duration)
	
	# LightOnFloor
	tw.tween_property(light_on_floor, "modulate:a", 1.0, transition_duration)

func fade_out_morning_elements(tw: Tween) -> void:
	tw.tween_property(morning_color_rect, "modulate:a", 0.0, transition_duration)
	tw.tween_property(window_light_1, "modulate:a", 0.0, transition_duration)
	tw.tween_property(window_light_2, "modulate:a", 0.0, transition_duration)
	tw.tween_property(window_light_3, "modulate:a", 0.0, transition_duration)
	tw.tween_property(dust_1, "modulate:a", 0.0, transition_duration)
	tw.tween_property(dust_2, "modulate:a", 0.0, transition_duration)
	tw.tween_property(dust_3, "modulate:a", 0.0, transition_duration)
	tw.tween_property(light_on_floor, "modulate:a", 0.0, transition_duration)
	
	# 渐隐完成后停止粒子发射
	tw.chain().tween_callback(func():
		dust_1.emitting = false
		dust_2.emitting = false
		dust_3.emitting = false
	)

# ============ 晚上元素渐变 ============
func fade_in_night_elements(tw: Tween) -> void:
	# PointLight（用 color.a）
	tw.tween_property(point_light_1, "color:a", 1.0, transition_duration)
	tw.tween_property(point_light_2, "color:a", 1.0, transition_duration)
	tw.tween_property(point_light_3, "color:a", 1.0, transition_duration)
	tw.tween_property(point_light_4, "color:a", 1.0, transition_duration)
	
	# NightFilter 的 ColorRect
	tw.tween_property(night_color_rect, "modulate:a", 1.0, transition_duration)

func fade_out_night_elements(tw: Tween) -> void:
	tw.tween_property(point_light_1, "color:a", 0.0, transition_duration)
	tw.tween_property(point_light_2, "color:a", 0.0, transition_duration)
	tw.tween_property(point_light_3, "color:a", 0.0, transition_duration)
	tw.tween_property(point_light_4, "color:a", 0.0, transition_duration)
	tw.tween_property(night_color_rect, "modulate:a", 0.0, transition_duration)

# ============ 瞬间切换（初始化用）============
func apply_phase_instant(phase: TimePhase) -> void:
	match phase:
		TimePhase.MORNING, TimePhase.AFTERNOON:
			set_morning_elements_alpha(1.0)
			set_night_elements_alpha(0.0)
			dust_1.emitting = true
			dust_2.emitting = true
			dust_3.emitting = true
			
		TimePhase.NOON:
			set_morning_elements_alpha(0.0)
			set_night_elements_alpha(0.0)
			dust_1.emitting = false
			dust_2.emitting = false
			dust_3.emitting = false
			
		TimePhase.NIGHT:
			set_morning_elements_alpha(0.0)
			set_night_elements_alpha(1.0)
			dust_1.emitting = false
			dust_2.emitting = false
			dust_3.emitting = false

func set_morning_elements_alpha(alpha: float) -> void:
	morning_color_rect.modulate.a = alpha
	window_light_1.modulate.a = alpha
	window_light_2.modulate.a = alpha
	window_light_3.modulate.a = alpha
	dust_1.modulate.a = alpha
	dust_2.modulate.a = alpha
	dust_3.modulate.a = alpha
	light_on_floor.modulate.a = alpha

func set_night_elements_alpha(alpha: float) -> void:
	point_light_1.color.a = alpha
	point_light_2.color.a = alpha
	point_light_3.color.a = alpha
	point_light_4.color.a = alpha
	night_color_rect.modulate.a = alpha
