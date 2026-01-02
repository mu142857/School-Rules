# ui/body_panel.gd
extends Control

@onready var pressure_bar = $LeftSection/PressureBar
@onready var pressure_icon = $LeftSection/PressureBar/Icon
@onready var pressure_label = $LeftSection/PressureBar/Label
@onready var pressure_name = $LeftSection/PressureBar/NameTag
@onready var pressure_arrow_up = $LeftSection/PressureBar/ArrowUp
@onready var pressure_arrow_down = $LeftSection/PressureBar/ArrowDown

@onready var hunger_bar = $LeftSection/HungerBar
@onready var hunger_icon = $LeftSection/HungerBar/Icon
@onready var hunger_label = $LeftSection/HungerBar/Label
@onready var hunger_name = $LeftSection/HungerBar/NameTag
@onready var hunger_arrow_up = $LeftSection/HungerBar/ArrowUp
@onready var hunger_arrow_down = $LeftSection/HungerBar/ArrowDown

@onready var toilet_bar = $LeftSection/ToiletBar
@onready var toilet_icon = $LeftSection/ToiletBar/Icon
@onready var toilet_label = $LeftSection/ToiletBar/Label
@onready var toilet_name = $LeftSection/ToiletBar/NameTag
@onready var toilet_arrow_up = $LeftSection/ToiletBar/ArrowUp
@onready var toilet_arrow_down = $LeftSection/ToiletBar/ArrowDown

@onready var paper1 = $ViolationSection/Paper1
@onready var paper2 = $ViolationSection/Paper2
@onready var paper3 = $ViolationSection/Paper3
@onready var violation_label = $ViolationSection/Label
@onready var violation_name = $ViolationSection/NameTag

@onready var pie_title = $RightSection/NameTag
@onready var pie_chart = $RightSection/PieChart
@onready var legend_sleep = $RightSection/LegendSleep
@onready var legend_study = $RightSection/LegendStudy
@onready var legend_other = $RightSection/LegendOther

# 压力颜色
var pressure_color_low = Color("3ECFAF")
var pressure_color_mid = Color("E8D44A")
var pressure_color_high = Color("8B3A4C")

# 饱食度颜色
var hunger_color_high = Color("F2A65A")
var hunger_color_low = Color("5C3A21")

# 厕所值颜色
var toilet_color_low = Color("5DADEC")
var toilet_color_high = Color("1E3A5F")

# 大脑图标
var brain_low_texture = preload("res://ui/icons/brain_low.png")
var brain_mid_texture = preload("res://ui/icons/brain_mid.png")
var brain_high_texture = preload("res://ui/icons/brain_high.png")

# 违纪单图标
var paper_normal_texture = preload("res://ui/icons/violation_normal.png")
var paper_broken_texture = preload("res://ui/icons/violation_broken.png")

# 箭头判定用：记录上次的数值
var last_pressure: float = -1
var last_hunger: float = -1
var last_toilet: float = -1
var last_check_hour: int = -1

func _ready():
	setup_names()
	# 初始化记录
	last_pressure = GameManager.pressure
	last_hunger = GameManager.hunger
	last_toilet = GameManager.toilet_desire
	last_check_hour = GameManager.hour
	update_display()

func _process(_delta):
	update_display()
	check_arrows()

func setup_names():
	pressure_name.text = TranslationSystem.t("STAT_PRESSURE")
	hunger_name.text = TranslationSystem.t("STAT_HUNGER")
	toilet_name.text = TranslationSystem.t("STAT_TOILET")
	violation_name.text = TranslationSystem.t("STAT_VIOLATION")
	
	pie_title.text = TranslationSystem.t("PIE_TITLE")
	update_pie_legend()

func check_arrows():
	# 每两小时判定一次
	var current_hour = GameManager.hour
	var hours_passed = current_hour - last_check_hour
	if hours_passed < 0:
		hours_passed += 24  # 跨天
	
	if hours_passed >= 2:
		# 判定并更新箭头
		update_arrow(pressure_arrow_up, pressure_arrow_down, GameManager.pressure, last_pressure)
		update_arrow(hunger_arrow_up, hunger_arrow_down, GameManager.hunger, last_hunger)
		update_arrow(toilet_arrow_up, toilet_arrow_down, GameManager.toilet_desire, last_toilet)
		
		# 更新记录
		last_pressure = GameManager.pressure
		last_hunger = GameManager.hunger
		last_toilet = GameManager.toilet_desire
		last_check_hour = current_hour

func update_arrow(arrow_up: GPUParticles2D, arrow_down: GPUParticles2D, current: float, last: float):
	if current > last:
		arrow_up.emitting = true
		arrow_down.emitting = false
	elif current < last:
		arrow_up.emitting = false
		arrow_down.emitting = true
	else:
		arrow_up.emitting = false
		arrow_down.emitting = false

func update_display():
	update_pressure()
	update_hunger()
	update_toilet()
	update_violation()

func update_pressure():
	var value = GameManager.pressure
	pressure_bar.value = value
	pressure_label.text = "%d%%" % int(value)
	
	var color: Color
	if value < 50:
		color = pressure_color_low.lerp(pressure_color_mid, value / 50.0)
	else:
		color = pressure_color_mid.lerp(pressure_color_high, (value - 50) / 50.0)
	pressure_bar.tint_progress = color
	
	if value < 60:
		pressure_icon.texture = brain_low_texture
	elif value < 80:
		pressure_icon.texture = brain_mid_texture
	else:
		pressure_icon.texture = brain_high_texture

func update_hunger():
	var value = GameManager.hunger
	hunger_bar.value = clamp(value, 0, 100)
	hunger_label.text = "%d%%" % int(value)
	
	var color = hunger_color_low.lerp(hunger_color_high, value / 100.0)
	hunger_bar.tint_progress = color

func update_toilet():
	var value = GameManager.toilet_desire
	toilet_bar.value = clamp(value, 0, 100)
	toilet_label.text = "%d%%" % int(value)
	
	var t = clamp(value / 100.0, 0, 1)
	var color = toilet_color_low.lerp(toilet_color_high, t)
	toilet_bar.tint_progress = color

func update_violation():
	var points = GameManager.violation_points
	violation_label.text = "%d/3" % points
	
	paper1.texture = paper_broken_texture if points >= 1 else paper_normal_texture
	paper2.texture = paper_broken_texture if points >= 2 else paper_normal_texture
	paper3.texture = paper_broken_texture if points >= 3 else paper_normal_texture

func update_pie_legend():
	if pie_chart.has_data:
		legend_sleep.text = "%s %d%%" % [TranslationSystem.t("PIE_SLEEP"), pie_chart.get_sleep_percent()]
		legend_study.text = "%s %d%%" % [TranslationSystem.t("PIE_STUDY"), pie_chart.get_study_percent()]
		legend_other.text = "%s %d%%" % [TranslationSystem.t("PIE_OTHER"), pie_chart.get_other_percent()]
	else:
		legend_sleep.text = TranslationSystem.t("PIE_NO_DATA")
		legend_study.text = ""
		legend_other.text = ""
