# ui/line_chart.gd
extends Control

# 配置
var line_color = Color("3ecfaf") # 默认青色
var fill_color = Color("3ecfaf44") # 半透明填充
var point_size = 6.0
var max_days = 14

# 当前状态
var view_subject: String = "Total": 
	set(val):
		view_subject = val
		queue_redraw()

var current_max: float = 0
var current_min: float = 0

# 各科目颜色配置
var colors = {
	"Total": Color("ffffff"),    # 总分白色
	"Chinese": Color("ff6b6b"),  # 红色
	"Math": Color("4dadff"),     # 蓝色
	"English": Color("ffda47"),  # 黄色
	"Physics": Color("a29bfe"),  # 紫色
	"Geography": Color("55efc4"),# 绿色
	"Biology": Color("fab1a0")   # 橙色
}

func _draw():
	var history = GameManager.knowledge_history
	if history.size() == 0:
		return

	# 1. 提取数据
	var data_points = []
	# 取最近的14天
	var start_idx = max(0, history.size() - max_days)
	for i in range(start_idx, history.size()):
		var record = history[i]
		if view_subject == "Total":
			var sum = record["Chinese"] + record["Math"] + record["English"] + \
					  record["Physics"] + record["Geography"] + record["Biology"]
			data_points.append(sum)
		else:
			data_points.append(record.get(view_subject, 0))

	if data_points.size() == 0: return

	# 2. 计算区间（自动调整刻度）
	current_max = data_points.max()
	current_min = data_points.min()
	
	# 防止最大最小值相等导致除以0（画成直线）
	if current_max == current_min:
		current_max += 10
		current_min -= 10
	
	# 留出一点边距
	var display_max = current_max * 1.1
	var display_min = current_min * 0.9

	# 3. 计算坐标
	var points = PackedVector2Array()
	# X轴间距：总宽750除以13个间隔
	var x_step = size.x / (max_days - 1)
	
	for i in range(data_points.size()):
		var x = i * x_step
		# Y轴映射：(数值 - 最小) / (最大 - 最小) * 高度
		# 注意：屏幕Y坐标是从上往下的，所以要用 size.y 减去结果
		var ratio = (data_points[i] - display_min) / (display_max - display_min)
		var y = size.y - (ratio * size.y)
		points.append(Vector2(x, y))

	# 4. 绘制填充区域（半透明）
	if points.size() > 1:
		var fill_points = PackedVector2Array(points)
		# 添加两个到底部的点形成封闭多边形
		fill_points.append(Vector2(points[-1].x, size.y))
		fill_points.append(Vector2(points[0].x, size.y))
		var color = colors.get(view_subject, line_color)
		color.a = 0.2 # 填充透明度
		draw_colored_polygon(fill_points, color)

	# 5. 绘制折线
	if points.size() > 1:
		draw_polyline(points, colors.get(view_subject, line_color), 2.0, true)

	# 6. 绘制小方块点
	for p in points:
		var rect = Rect2(p.x - point_size/2, p.y - point_size/2, point_size, point_size)
		draw_rect(rect, colors.get(view_subject, line_color))
