# ui/info_panel.gd
extends CanvasLayer
signal panel_closed

@onready var panel_pack = $Control
@onready var background_colour = $Background
@onready var body_content = $Control/Panel/BodyContent
@onready var study_content = $Control/Panel/StudyContent
@onready var item_content = $Control/Panel/ItemContent
@onready var calendar_content = $Control/Panel/CalendarContent
@onready var map_content = $Control/Panel/MapContent

@onready var tab_body = $Control/Panel/TabBody
@onready var tab_body_label = $Control/Panel/TabBody/Label
@onready var tab_item = $Control/Panel/TabItem
@onready var tab_item_label = $Control/Panel/TabItem/Label
@onready var tab_study = $Control/Panel/TabStudy
@onready var tab_study_label = $Control/Panel/TabStudy/Label
@onready var tab_calendar = $Control/Panel/TabCalendar
@onready var tab_calendar_label = $Control/Panel/TabCalendar/Label
@onready var tab_map = $Control/Panel/TabMap
@onready var tab_map_label = $Control/Panel/TabMap/Label
@onready var cancel_button = $Control/Panel/Cancel
@onready var cancel_label = $Control/Panel/Cancel/Label

var normal_color = Color("b9c7ca")
var hover_color = Color.WHITE
var cancel_color = Color(0.715, 0.407, 0.446, 1.0)

var current_panel: Control
var current_tab: String = ""
var slide_tween: Tween
var background_tween: Tween
var is_sliding: bool = false
var pending_tab: String = ""  # 切换动画中等待切换到的tab

func _ready():
	preparing_position()
	current_tab = "Body"
	set_current_panel("Body")
	open_animation()
	
	background_colour.modulate.a = 0
	setup_tabs()

func _input(event):
	if event.is_action_pressed("ui_cancel") and not is_sliding:
		close()

func close():
	close_animation()

func preparing_position():
	panel_pack.global_position = Vector2(-300, -300)
	panel_pack.rotation_degrees = 90.0
	panel_pack.scale = Vector2(0.1, 0.1)
	panel_pack.modulate.a = 0

func normal_position(): # 笔记用
	panel_pack.position = Vector2.ZERO
	panel_pack.rotation_degrees = 0.0
	panel_pack.scale = Vector2(1.0, 1.0)
	background_colour.modulate.a = 1
	pass

func open_animation():
	is_sliding = true
	if slide_tween:
		slide_tween.kill()
	slide_tween = create_tween()
	if background_tween:
		background_tween.kill()
	background_tween = create_tween()
	
	preparing_position()
	
	background_tween.tween_property(background_colour, "modulate:a", 1.0, 0.3)
	slide_tween.tween_property(panel_pack, "position", Vector2(0, 0), 0.3)
	slide_tween.parallel().tween_property(panel_pack, "modulate:a", 1.0, 0.3)
	slide_tween.parallel().tween_property(panel_pack, "scale", Vector2(1.0, 1.0), 0.3)
	slide_tween.parallel().tween_property(panel_pack, "rotation_degrees", -6.0, 0.3).set_ease(Tween.EASE_IN)
	
	slide_tween.tween_property(panel_pack, "position", Vector2.ZERO, 0.1)
	slide_tween.parallel().tween_property(panel_pack, "scale", Vector2(1, 1), 0.1)
	slide_tween.parallel().tween_property(panel_pack, "rotation_degrees", 3.0, 0.1)
	
	slide_tween.tween_property(panel_pack, "rotation_degrees", 0, 0.1).set_ease(Tween.EASE_OUT)
	slide_tween.parallel().tween_property(panel_pack, "scale", Vector2(1.0, 1.0), 0.1)
	slide_tween.tween_callback(_on_open_finished)

func _on_open_finished():
	is_sliding = false
	update_tab_colors()

func change_animation(new_tab: String):
	if is_sliding:
		return
	if new_tab == current_tab:
		return
	
	is_sliding = true
	pending_tab = new_tab
	
	if slide_tween:
		slide_tween.kill()
	slide_tween = create_tween()
	
	normal_position()
	
	slide_tween.tween_property(panel_pack, "position", Vector2(200, 0), 0.3).set_ease(Tween.EASE_IN)
	slide_tween.parallel().tween_property(panel_pack, "modulate:a", 0.0, 0.2)
	slide_tween.parallel().tween_property(panel_pack, "rotation_degrees", -90.0, 0.3)
	slide_tween.parallel().tween_property(panel_pack, "scale", Vector2(0.1, 0.1), 0.3)
	slide_tween.tween_callback(_on_change_out_finished)

func _on_change_out_finished():
	# 切换内容
	current_tab = pending_tab
	set_current_panel(pending_tab)
	pending_tab = ""

func close_animation():
	if is_sliding:
		return
	
	is_sliding = true
	
	if slide_tween:
		slide_tween.kill()
	slide_tween = create_tween()
	if background_tween:
		background_tween.kill()
	background_tween = create_tween()
	
	normal_position()
	
	background_tween.tween_property(background_colour, "modulate:a", 0.0, 0.3)
	
	slide_tween.tween_property(panel_pack, "position", Vector2(200, 0), 0.3).set_ease(Tween.EASE_IN)
	slide_tween.parallel().tween_property(panel_pack, "modulate:a", 0.0, 0.1)
	slide_tween.parallel().tween_property(panel_pack, "rotation_degrees", -90.0, 0.3)
	slide_tween.parallel().tween_property(panel_pack, "scale", Vector2(0.1, 0.1), 0.3)
	slide_tween.tween_callback(_on_close_finished)

func _on_close_finished():
	panel_closed.emit()
	self.queue_free()

func set_current_panel(panel: String):
	body_content.hide()
	study_content.hide()
	item_content.hide()
	calendar_content.hide()
	map_content.hide()
	
	match panel:
		"Body":
			current_panel = body_content
		"Study":
			current_panel = study_content
		"Item":
			current_panel = item_content
		"Calendar":
			current_panel = calendar_content
		"Map":
			current_panel = map_content
	
	current_panel.show()
	#open_animation()

func _on_tab_body_pressed() -> void:
	if not is_sliding and current_tab != "Body":
		current_tab = "Body"
		set_current_panel("Body")
		update_tab_colors()

func _on_tab_item_pressed() -> void:
	if not is_sliding and current_tab != "Item":
		current_tab = "Item"
		set_current_panel("Item")
		update_tab_colors()

func _on_tab_study_pressed() -> void:
	if not is_sliding and current_tab != "Study":
		current_tab = "Study"
		set_current_panel("Study")
		update_tab_colors()

func _on_tab_map_pressed() -> void:
	if not is_sliding and current_tab != "Map":
		current_tab = "Map"
		set_current_panel("Map")
		update_tab_colors()

func _on_tab_calendar_pressed() -> void:
	if not is_sliding and current_tab != "Calendar":
		current_tab = "Calendar"
		set_current_panel("Calendar")
		update_tab_colors()

func _on_cancel_pressed() -> void:
	if not is_sliding:
		close()

func setup_tabs():
	# 设置文字
	tab_body_label.text = TranslationSystem.t("TAB_BODY")
	tab_item_label.text = TranslationSystem.t("TAB_ITEM")
	tab_study_label.text = TranslationSystem.t("TAB_STUDY")
	tab_calendar_label.text = TranslationSystem.t("TAB_CALENDAR")
	tab_map_label.text = TranslationSystem.t("TAB_MAP")
	cancel_label.text = TranslationSystem.t("TAB_CANCEL")
	
	# 设置初始颜色
	update_tab_colors()
	cancel_label.add_theme_color_override("font_color", cancel_color)
	
	# 连接悬停信号
	tab_body.mouse_entered.connect(func(): tab_body_label.add_theme_color_override("font_color", hover_color))
	tab_body.mouse_exited.connect(func(): update_tab_colors())
	
	tab_item.mouse_entered.connect(func(): tab_item_label.add_theme_color_override("font_color", hover_color))
	tab_item.mouse_exited.connect(func(): update_tab_colors())
	
	tab_study.mouse_entered.connect(func(): tab_study_label.add_theme_color_override("font_color", hover_color))
	tab_study.mouse_exited.connect(func(): update_tab_colors())
	
	tab_calendar.mouse_entered.connect(func(): tab_calendar_label.add_theme_color_override("font_color", hover_color))
	tab_calendar.mouse_exited.connect(func(): update_tab_colors())
	
	tab_map.mouse_entered.connect(func(): tab_map_label.add_theme_color_override("font_color", hover_color))
	tab_map.mouse_exited.connect(func(): update_tab_colors())
	
	# cancel 按钮
	cancel_button.mouse_entered.connect(func(): cancel_label.add_theme_color_override("font_color", hover_color))
	cancel_button.mouse_exited.connect(func(): cancel_label.add_theme_color_override("font_color", cancel_color))

func update_tab_colors():
	# 当前 tab 白色，其他正常颜色
	tab_body_label.add_theme_color_override("font_color", hover_color if current_tab == "Body" else normal_color)
	tab_item_label.add_theme_color_override("font_color", hover_color if current_tab == "Item" else normal_color)
	tab_study_label.add_theme_color_override("font_color", hover_color if current_tab == "Study" else normal_color)
	tab_calendar_label.add_theme_color_override("font_color", hover_color if current_tab == "Calendar" else normal_color)
	tab_map_label.add_theme_color_override("font_color", hover_color if current_tab == "Map" else normal_color)
