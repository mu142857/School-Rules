# ui/pie_chart.gd
extends Control

var sleep_color = Color("7ca0d4ff")    # 蓝色
var study_color = Color("edaa79ff")    # 橙色
var exercise_color = Color("67c378ff") # 绿色
var other_color = Color("afafafff")    # 灰色

var sleep_percent: float = 0
var study_percent: float = 0
var exercise_percent: float = 0
var other_percent: float = 0
var has_data: bool = false

func _ready():
	GameManager.history_updated.connect(load_data)
	custom_minimum_size = Vector2(150, 150)
	load_data()

func load_data():
	if GameManager.time_allocation_history.size() > 0:
		var last_record = GameManager.time_allocation_history[-1]
		var total = last_record["sleep"] + last_record["study"] + last_record["exercise"] + last_record["other"]
		if total > 0:
			sleep_percent = last_record["sleep"] / float(total)
			study_percent = last_record["study"] / float(total)
			exercise_percent = last_record["exercise"] / float(total)
			other_percent = last_record["other"] / float(total)
			has_data = true
		else:
			has_data = false
	else:
		has_data = false
	
	# 确保数据加载后通知引擎调用 _draw()
	queue_redraw()

func _draw():
	var center = size / 2 + Vector2(-5, -5)
	var radius = min(size.x, size.y) / 2 - 10
	
	if not has_data:
		draw_circle_filled(center, radius, Color("ffffff64"))
		return
	
	var start_angle = -PI / 2
	
	# 睡眠
	if sleep_percent > 0:
		var end_angle = start_angle + sleep_percent * TAU
		draw_arc_filled(center, radius, start_angle, end_angle, sleep_color)
		start_angle = end_angle
	
	# 学习
	if study_percent > 0:
		var end_angle = start_angle + study_percent * TAU
		draw_arc_filled(center, radius, start_angle, end_angle, study_color)
		start_angle = end_angle
	
	# 运动
	if exercise_percent > 0:
		var end_angle = start_angle + exercise_percent * TAU
		draw_arc_filled(center, radius, start_angle, end_angle, exercise_color)
		start_angle = end_angle
	
	# 其他
	if other_percent > 0:
		var end_angle = start_angle + other_percent * TAU
		draw_arc_filled(center, radius, start_angle, end_angle, other_color)

func draw_circle_filled(center: Vector2, radius: float, color: Color):
	var points = PackedVector2Array()
	var segments = 32
	for i in range(segments + 1):
		var angle = i * TAU / segments
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	draw_colored_polygon(points, color)

func draw_arc_filled(center: Vector2, radius: float, start: float, end: float, color: Color):
	var points = PackedVector2Array()
	points.append(center)
	var segments = 32
	var angle_step = (end - start) / segments
	for i in range(segments + 1):
		var angle = start + i * angle_step
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	draw_colored_polygon(points, color)

func get_sleep_percent() -> int:
	return int(sleep_percent * 100)

func get_study_percent() -> int:
	return int(study_percent * 100)

func get_exercise_percent() -> int:
	return int(exercise_percent * 100)

func get_other_percent() -> int:
	return int(other_percent * 100)
