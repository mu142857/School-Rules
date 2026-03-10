# res://ui/pause_menu.tscn
extends CanvasLayer

# === 节点引用 (请确保名字与您的场景一致) ===
@onready var character_preview = $CharacterPreview
@onready var name_label = $InfoVBox/NameLabel
@onready var days_elapsed_label = $InfoVBox/DaysElapsedLabel
@onready var days_gaokao_label = $InfoVBox/DaysGaokaoLabel

@onready var return_button = $Buttons/ReturnButton
@onready var settings_button = $Buttons/SettingsButton
@onready var quit_button = $Buttons/QuitButton

func _ready():
	# 关键设置：即使暂停，UI也要继续处理
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# 初始隐藏
	hide_menu()

func _input(event):
	if event.is_action_pressed("ui_cancel"): # ESC 键
		# 逻辑：如果信息面板开着，ESC会被它拦截（因为它层级在前面）
		# 如果运行到了这里，说明信息面板没开，我们可以安全切换暂停
		toggle_pause()

# === 核心逻辑 ===

func toggle_pause():
	if not visible:
		show_menu()
	else:
		hide_menu()

func show_menu():
	# 1. 物理暂停
	get_tree().paused = true
	# 2. 更新数据展示
	update_info_display()
	# 3. 显示界面
	self.show()
	# 4. 释放鼠标（如果之前被捕获了）
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func hide_menu():
	# 1. 取消物理暂停
	get_tree().paused = false
	# 2. 隐藏界面
	self.hide()

func update_info_display():
	# 更新姓名 (可以使用翻译系统或GameManager变量)
	name_label.text = "林嘉木" # 或者 TranslationSystem.t("PLAYER_NAME")
	
	# 更新开学天数
	var days_passed = calculate_total_days()
	days_elapsed_label.text = TranslationSystem.t("PAUSE_DAYS_START") % days_passed
	
	# 更新高考倒计时
	var days_left = calculate_gaokao_countdown()
	days_gaokao_label.text = TranslationSystem.t("PAUSE_DAYS_GAOKAO") % days_left

# === 计算工具函数 ===

func calculate_total_days() -> int:
	# 3月1日开始，计算累计天数
	var m = GameManager.month
	var d = GameManager.day
	var total = 0
	# 简单月累计（针对高三下学期 3,4,5,6月）
	if m == 3: total = d
	elif m == 4: total = 31 + d
	elif m == 5: total = 31 + 30 + d
	elif m == 6: total = 31 + 30 + 31 + d
	return total

func calculate_gaokao_countdown() -> int:
	# 高考日期：6月7日
	# 计算 6月7日 对应的一年中的总天数，然后减去当前的
	# 也可以直接硬编码 6月7日 是开学后的第 99 天
	var total_days_passed = calculate_total_days()
	var gaokao_day_index = 99 # 31+30+31+7
	return max(0, gaokao_day_index - total_days_passed)

# === 按钮回调 ===

func _on_return_pressed():
	hide_menu()

func _on_settings_pressed():
	# 这里之后可以调用你的设置面板
	print("打开设置界面...")

func _on_quit_pressed():
	# 这里可以直接退出，或者加一个二次确认弹窗
	get_tree().quit()

var btn_move: int = 4
# 1. 返回按钮
func _on_return_button_mouse_entered():
	# 假设 Label 是按钮的直接子节点
	$Buttons/ReturnButton/Label.position.x += btn_move

func _on_return_button_mouse_exited():
	$Buttons/ReturnButton/Label.position.x -= btn_move

# 2. 设置按钮
func _on_settings_button_mouse_entered():
	$Buttons/SettingsButton/Label.position.x += btn_move

func _on_settings_button_mouse_exited():
	$Buttons/SettingsButton/Label.position.x -= btn_move

# 3. 退出按钮
func _on_quit_button_mouse_entered():
	$Buttons/QuitButton/Label.position.x += btn_move

func _on_quit_button_mouse_exited():
	$Buttons/QuitButton/Label.position.x -= btn_move
