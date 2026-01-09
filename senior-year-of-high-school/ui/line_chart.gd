# ui/line_chart.gd 重构版
extends Control

# --- 配置 ---
var max_days = 14
var point_size = 6.0
var lerp_speed = 0.15 # 平滑速度，数值越小越丝滑

# --- 颜色 ---
var colors = {
	"Total": Color("6e7065"), "Chinese": Color("cfa794"), "Math": Color("94aacf"),
	"English": Color("bca4e0"), "Physics": Color("7684cf"), "Geography": Color("aba058ff"), "Biology": Color("60bd7d")
}

# --- 字体 ---
var custom_font = preload("res://shared/PixelFont.ttf")

# --- 内部变量 ---
var view_subject: String = "Total"
var target_data = []  # 目标数值
var current_data = [] # 当前正在显示的数值（平滑过渡用）
var current_max: float = 0
var current_min: float = 0
var display_max: float = 0 # 平滑后的轴上限
var display_min: float = 0 # 平滑后的轴下限

# 提示框变量
var mouse_idx = -1 # 当前鼠标指着的日期索引

func _ready():
	# 初始化数组长度
	for i in range(max_days):
		current_data.append(0.0)
		target_data.append(0.0)

func _process(_delta):
	update_logic()
	queue_redraw()

func update_logic():
	var history = GameManager.knowledge_history
	if history.size() == 0: return

	# 1. 获取最新数据存入 target_data
	var start_idx = max(0, history.size() - max_days)
	var latest_points = []
	for i in range(start_idx, history.size()):
		var record = history[i]
		if view_subject == "Total":
			var sum = record["Chinese"] + record["Math"] + record["English"] + \
					  record["Physics"] + record["Geography"] + record["Biology"]
			latest_points.append(sum)
		else:
			latest_points.append(record.get(view_subject, 0.0))
	
	# 如果不足14天，前面补0（保持数组长度一致以便平滑切换）
	while latest_points.size() < max_days:
		latest_points.insert(0, 50)
	
	target_data = latest_points

	# 2. 数值平滑（Lerp）
	for i in range(max_days):
		current_data[i] = lerp(current_data[i], float(target_data[i]), lerp_speed)
	
	# 3. 轴范围平滑
	current_max = target_data.max()
	current_min = target_data.min()
	if current_max == current_min: current_max += 10
	
	display_max = lerp(display_max, current_max * 1.1, lerp_speed)
	display_min = lerp(display_min, current_min * 0.9, lerp_speed)

	# 4. 检测鼠标位置
	var m_pos = get_local_mouse_position()
	if m_pos.x >= 0 and m_pos.x <= size.x and m_pos.y >= 0 and m_pos.y <= size.y:
		var x_step = size.x / (max_days - 1)
		mouse_idx = round(m_pos.x / x_step)
		# 确保索引不越界（考虑到数据可能不足14天）
		var data_start_offset = max_days - (history.size() - start_idx)
		if mouse_idx < data_start_offset: mouse_idx = -1
	else:
		mouse_idx = -1

func _draw():
	if current_data.size() < 2: return
	
	var x_step = size.x / (max_days - 1)
	var points = PackedVector2Array()
	
	# 计算坐标点
	for i in range(max_days):
		# 只画有数据（或经过补齐的）部分
		var x = i * x_step
		var ratio = (current_data[i] - display_min) / (display_max - display_min)
		var y = size.y - (ratio * size.y)
		points.append(Vector2(x, y))

	# 绘制填充和折线
	var theme_color = colors.get(view_subject, Color.WHITE)
	
	# 绘制填充
	var fill_pts = PackedVector2Array(points)
	fill_pts.append(Vector2(points[-1].x, size.y))
	fill_pts.append(Vector2(points[0].x, size.y))
	draw_colored_polygon(fill_pts, Color(theme_color, 0.5))
	
	# 绘制主线
	draw_polyline(points, theme_color, 2.0, true)
	
	# 绘制方块
	for p in points:
		draw_rect(Rect2(p.x-3, p.y-3, 6, 6), theme_color)

	# --- 绘制数据提示 (Tooltip) ---
	if mouse_idx != -1 and mouse_idx < points.size():
		var p = points[mouse_idx]
		# 垂直辅助线
		draw_line(Vector2(p.x, 0), Vector2(p.x, size.y), Color(1.0, 1.0, 1.0, 0.392), 1.0)
		# 选中的大方块
		draw_rect(Rect2(p.x-5, p.y-5, 10, 10), theme_color)
		# 绘制文字背景
		var val_text = TranslationSystem.t("TOTAL_POINTS") + str(int(target_data[mouse_idx]))
		var font = ThemeDB.get_fallback_font()
		var font_size = 20
		var text_size = font.get_string_size(val_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
		
		var rect_pos = p + Vector2(-text_size.x/2, -25)
		draw_string(custom_font, rect_pos + Vector2(0, text_size.y - 2), val_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.WHITE)
