# ui/pie_chart.gd
extends Control

var sleep_color = Color("4A6FA5")    # 蓝色
var study_color = Color("D4874C")    # 橙色
var other_color = Color("6B6B6B")    # 灰色

var sleep_percent: float = 0
var study_percent: float = 0
var other_percent: float = 0
var has_data: bool = false

func _ready():
	custom_minimum_size = Vector2(150, 150)
	load_data()

func load_data():
	if GameManager.time_allocation_history.size() > 0:
		var last_record = GameManager.time_allocation_history[-1]
		var total = last_record["sleep"] + last_record["study"] + last_record["other"]
		if total > 0:
			sleep_percent = last_record["sleep"] / float(total)
			study_percent = last_record["study"] / float(total)
			other_percent = last_record["other"] / float(total)
			has_data = true
		else:
			has_data = false
	else:
		has_data = false
	queue_redraw()

func _draw():
	var center = size / 2
	var radius = min(size.x, size.y) / 2 - 10
	
	if not has_data:
		# 画一个灰色圆表示无数据
		draw_circle_filled(center, radius, Color("3A3A3A"))
		return
	
	var start_angle = -PI / 2  # 从顶部开始
	
	# 画睡眠扇形
	if sleep_percent > 0:
		var end_angle = start_angle + sleep_percent * TAU
		draw_arc_filled(center, radius, start_angle, end_angle, sleep_color)
		start_angle = end_angle
	
	# 画学习扇形
	if study_percent > 0:
		var end_angle = start_angle + study_percent * TAU
		draw_arc_filled(center, radius, start_angle, end_angle, study_color)
		start_angle = end_angle
	
	# 画其他扇形
	if other_percent > 0:
		var end_angle = start_angle + other_percent * TAU
		draw_arc_filled(center, radius, start_angle, end_angle, other_color)

func draw_circle_filled(center: Vector2, radius: float, color: Color):
	var points = PackedVector2Array()
	var segments = 8  # 原来是32，改成12
	for i in range(segments + 1):
		var angle = i * TAU / segments
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	draw_colored_polygon(points, color)

func draw_arc_filled(center: Vector2, radius: float, start: float, end: float, color: Color):
	var points = PackedVector2Array()
	points.append(center)
	var segments = 8  # 原来是32，改成12
	var angle_step = (end - start) / segments
	for i in range(segments + 1):
		var angle = start + i * angle_step
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	draw_colored_polygon(points, color)

func get_sleep_percent() -> int:
	return int(sleep_percent * 100)

func get_study_percent() -> int:
	return int(study_percent * 100)

func get_other_percent() -> int:
	return int(other_percent * 100)
