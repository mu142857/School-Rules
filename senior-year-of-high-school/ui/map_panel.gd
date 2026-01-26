# res://ui/map_panel.tscn

extends Control

@onready var detection_areas = $DetectionAreas
@onready var label_zh_root = $Label_ZH
@onready var label_en_root = $Label_EN # 新增：引用英文根节点

# 颜色配置
var highlight_color = Color.WHITE
var normal_colors_zh = {} 
var normal_colors_en = {} 

func _ready():
	# 1. 初始化显隐状态
	update_language_visibility()
	
	# 2. 自动初始化：给26个区域连上信号并记录颜色
	for area in detection_areas.get_children():
		if area is Area2D:
			# 记录中文版颜色
			var lbl_zh = label_zh_root.get_node_or_null(NodePath(area.name))
			if lbl_zh:
				normal_colors_zh[area.name] = lbl_zh.get_theme_color("font_color")
			
			# 记录英文版颜色
			var lbl_en = label_en_root.get_node_or_null(NodePath(area.name))
			if lbl_en:
				normal_colors_en[area.name] = lbl_en.get_theme_color("font_color")
			
			# 连接信号
			area.mouse_entered.connect(_on_building_hover.bind(area))
			area.mouse_exited.connect(_on_building_unhover.bind(area))

# 每帧检查语言（或者你可以写个 setter，但在开发阶段这样最稳）
func _process(_delta):
	update_language_visibility()

# 根据当前语言切换根节点的显示
func update_language_visibility():
	var is_zh = (TranslationSystem.current_language == "zh")
	label_zh_root.visible = is_zh
	label_en_root.visible = !is_zh

# 鼠标移入：让“当前显示”的那个 Label 变白
func _on_building_hover(area: Area2D):
	# 判定现在该找哪个根节点
	var active_root = label_zh_root if label_zh_root.visible else label_en_root
	var label = active_root.get_node_or_null(NodePath(area.name))
	
	if label:
		var tween = create_tween()
		tween.tween_property(label, "theme_override_colors/font_color", highlight_color, 0.1)

# 鼠标移出：根据语言恢复对应的颜色
func _on_building_unhover(area: Area2D):
	var active_root = label_zh_root if label_zh_root.visible else label_en_root
	var label = active_root.get_node_or_null(NodePath(area.name))
	
	if label:
		# 寻找对应的原始颜色记录
		var color_map = normal_colors_zh if label_zh_root.visible else normal_colors_en
		if color_map.has(area.name):
			var tween = create_tween()
			tween.tween_property(label, "theme_override_colors/font_color", color_map[area.name], 0.1)
