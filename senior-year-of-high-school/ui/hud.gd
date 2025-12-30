# ui/hud.gd
extends CanvasLayer

@onready var time_label = $Control/TimeLabel
@onready var period_label = $Control/PeriodLabel
@onready var buff_container = $Control/BuffContainer
@onready var info_button = $Control/InfoButton

var pixel_font: Font

func _ready():
	pixel_font = load("res://shared/PixelFont.ttf")
	time_label.add_theme_font_override("font", pixel_font)
	period_label.add_theme_font_override("font", pixel_font)
	
	info_button.pressed.connect(_on_info_pressed)

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
	pass

func _on_info_pressed():
	# 之后连接InfoPanel
	pass
