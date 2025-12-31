# ui/hud.gd
extends CanvasLayer

@onready var time_label = $Control/TimeLabel
@onready var period_label = $Control/PeriodLabel
@onready var buff_container = $Control/BuffContainer
@onready var info_button_pack = $Control/InfoButtonPack # pt，上官嘉木上官嘉木
@onready var info_button = $Control/InfoButtonPack/InfoButton

var hover_tween: Tween
var pixel_font: Font

func _ready():
	info_button.pressed.connect(_on_info_pressed)
	info_button.mouse_entered.connect(_on_info_hover)
	info_button.mouse_exited.connect(_on_info_unhover)

func _on_info_hover():
	if hover_tween:
		hover_tween.kill()
	hover_tween = create_tween()
	hover_tween.tween_property(info_button_pack, "rotation_degrees", 3.0, 0.05)
	hover_tween.tween_property(info_button_pack, "rotation_degrees", -3.0, 0.1)
	hover_tween.parallel().tween_property(info_button_pack, "scale", Vector2(1.05, 1.05), 0.1)
	hover_tween.tween_property(info_button_pack, "rotation_degrees", 0.0, 0.05)


func _on_info_unhover():
	if hover_tween:
		hover_tween.kill()
	hover_tween = create_tween()
	hover_tween.tween_property(info_button_pack, "scale", Vector2(1.0, 1.0), 0.1)
	info_button_pack.rotation_degrees = 0.0

func _on_info_pressed():
	pass
	#InfoPanel.toggle()

func _process(_delta):
	update_time_display()
	update_buff_display()

func _input(event):
	if event.is_action_pressed("ui_info"):
		_on_info_pressed()

func update_time_display():
	var weekday_text = TranslationSystem.get_weekday_text(TimeSystem.get_weekday())
	time_label.text = "%d月%d日 星期%s" % [GameManager.month, GameManager.day, weekday_text]
	
	var period_text = TranslationSystem.t(TimeSystem.get_current_period())
	period_label.text = "%02d:%02d %s" % [GameManager.hour, GameManager.minute, period_text]

func update_buff_display():
	# 之后加buff图标
	pass
