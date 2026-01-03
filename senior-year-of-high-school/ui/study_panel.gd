# ui/study_panel.gd
extends Control

# 科目节点引用（请确保名字在编辑器中对应）
@onready var subjects_container = $SubjectGrid
@onready var chart = $LineChartSection/ChartContainer

# 刻度标签
@onready var max_label = $LineChartSection/MaxLabel
@onready var min_label = $LineChartSection/MinLabel
@onready var mean_label = $LineChartSection/MeanLabel

func _ready():
	setup_subject_signals()
	update_scores()
	# 初始显示总分趋势
	chart.view_subject = "Total"

func _process(_delta):
	# 如果实时变化，可以在这里调用，或者在 GameManager 数据变化时手动更新
	update_scores()

# ui/study_panel.gd (修改 setup_subject_signals 部分)

func setup_subject_signals():
	for subject_node in subjects_container.get_children():
		var subject_name = subject_node.name
		
		# 鼠标移入
		subject_node.mouse_entered.connect(func():
			# 1. 切换图表视图
			chart.view_subject = subject_name
			update_labels()
			
			# 2. 动画：放大 1.1 倍，变亮
			var tween = create_tween().set_parallel(true)
			tween.tween_property(subject_node, "scale", Vector2(1.1, 1.1), 0.1).set_trans(Tween.TRANS_SINE)
			tween.tween_property(subject_node, "modulate", Color(1.2, 1.2, 1.2), 0.1) # 稍微过曝变亮
		)
		
		# 鼠标移出
		subject_node.mouse_exited.connect(func():
			chart.view_subject = "Total"
			update_labels()
			
			# 动画：恢复原始大小和亮度
			var tween = create_tween().set_parallel(true)
			tween.tween_property(subject_node, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_SINE)
			tween.tween_property(subject_node, "modulate", Color.WHITE, 0.1)
		)

func update_scores():
	@warning_ignore("unused_variable")
	var total = 0
	for subject_node in subjects_container.get_children():
		var s_name = subject_node.name
		if GameManager.knowledge.has(s_name):
			var val = GameManager.knowledge[s_name]
			subject_node.get_node("Value").text = str(val)
			subject_node.get_node("NameTag").text = TranslationSystem.t("STAT_" + s_name.to_upper())
			total += val
	
	# 这里可以加一个总分显示的 Label（如果你有的话）
	update_labels()

func update_labels():
	# 从图表获取当前视图的最大、最小、平均值并显示
	max_label.text = str(int(chart.current_max))
	min_label.text = str(int(chart.current_min))
	mean_label.text = str(int((chart.current_max + chart.current_min) / 2))
