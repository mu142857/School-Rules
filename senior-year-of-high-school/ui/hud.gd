# ui/hud.gd
extends CanvasLayer

@onready var time_label = $Control/TimeLabel
@onready var period_label = $Control/PeriodLabel
@onready var buff_container = $Control/BuffContainer

@onready var info_button_pack = $Control/InfoButtonPack
@onready var info_button = $Control/InfoButtonPack/InfoButton
@onready var rope1 = $Control/InfoButtonPack/Rope1
@onready var rope2 = $Control/InfoButtonPack/Rope2

var hover_tween: Tween
var slide_tween: Tween
var original_position: Vector2

var info_panel_scene = preload("res://ui/info_panel.tscn")
var info_panel_instance: CanvasLayer = null
var is_sliding: bool = false

func _ready():
	info_button.pressed.connect(_on_info_pressed)
	info_button.mouse_entered.connect(_on_info_hover)
	info_button.mouse_exited.connect(_on_info_unhover)

func _on_info_hover():
	if hover_tween:
		hover_tween.kill()
	hover_tween = create_tween()
	hover_tween.tween_property(info_button_pack, "rotation_degrees", 4.0, 0.04)
	hover_tween.tween_property(info_button_pack, "rotation_degrees", -4.0, 0.08)
	hover_tween.parallel().tween_property(info_button_pack, "scale", Vector2(1.05, 1.05), 0.08)
	hover_tween.tween_property(info_button_pack, "rotation_degrees", 0.0, 0.04)

func _on_info_unhover():
	if hover_tween:
		hover_tween.kill()
	hover_tween = create_tween()
	hover_tween.tween_property(info_button_pack, "scale", Vector2(1.0, 1.0), 0.1)
	info_button_pack.rotation_degrees = 0.0

func _on_info_pressed():
	if not is_sliding and info_panel_instance == null:
		slide_out()

# 向上滑出（带惯性和震动）
func slide_out():
	is_sliding = true
	if slide_tween:
		slide_tween.kill()
	slide_tween = create_tween()
	
	# 先往下一点（惯性）
	slide_tween.tween_property(info_button_pack, "position:y", original_position.y + 20, 0.1).set_ease(Tween.EASE_OUT)
	# 缩小一点
	slide_tween.parallel().tween_property(info_button_pack, "scale", Vector2(1.3, 1.3), 0.1)

	# 绳子收紧
	slide_tween.parallel().tween_property(rope1, "rotation_degrees", -9.9, 0.2)
	slide_tween.parallel().tween_property(rope2, "rotation_degrees", -154.7, 0.2)
	
	# 然后往上滑出
	slide_tween.tween_property(info_button_pack, "position:y", -180, 0.2).set_ease(Tween.EASE_IN)
	# 恢复大小
	slide_tween.parallel().tween_property(info_button_pack, "scale", Vector2(0.8, 0.8), 0.2)
	
	
	slide_tween.tween_callback(_on_slide_out_finished)

func open_info_panel():
	info_panel_instance = info_panel_scene.instantiate()
	info_panel_instance.closed.connect(on_info_panel_closed)
	get_tree().root.add_child(info_panel_instance)
	TimeSystem.is_paused = true

func on_info_panel_closed():
	TimeSystem.is_paused = false
	slide_in()

# 从上滑入（恢复大小）
func slide_in():
	is_sliding = true
	if slide_tween:
		slide_tween.kill()
	info_button_pack.position.y = -180
	slide_tween = create_tween()
	slide_tween.tween_property(info_button_pack, "position:y", original_position.y, 0.3).set_ease(Tween.EASE_OUT)
	# 绳子恢复
	slide_tween.parallel().tween_property(rope1, "rotation_degrees", 10.1, 0.3)
	slide_tween.parallel().tween_property(rope2, "rotation_degrees", -162.1, 0.3)

func _process(_delta):
	update_time_display()
	update_buff_display()

func _input(event):
	if not is_sliding and  event.is_action_pressed("ui_info"):
		slide_out()

func update_time_display():
	var weekday_text = TranslationSystem.get_weekday_text(TimeSystem.get_weekday())
	time_label.text = "%d月%d日 星期%s" % [GameManager.month, GameManager.day, weekday_text]
	
	var period_text = TranslationSystem.t(TimeSystem.get_current_period())
	period_label.text = "%02d:%02d %s" % [GameManager.hour, GameManager.minute, period_text]

func update_buff_display():
	# 之后加buff图标
	pass

func _on_slide_out_finished():
	is_sliding = false
	info_panel_instance = info_panel_scene.instantiate()
	get_tree().root.add_child(info_panel_instance)
	info_panel_instance.panel_closed.connect(_on_info_panel_closed)
	TimeSystem.is_paused = true

func _on_slide_in_finished():
	is_sliding = false

func _on_info_panel_closed():
	info_panel_instance = null
	TimeSystem.is_paused = false
	slide_in()
