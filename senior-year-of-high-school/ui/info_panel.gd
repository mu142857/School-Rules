# ui/info_panel.gd
extends CanvasLayer

signal panel_closed

@onready var panel_pack = $Control
@onready var background_colour = $Control/ColorRect
@onready var body_content = $Control/Panel/BodyContent
@onready var study_content = $Control/Panel/StudyContent
@onready var item_content = $Control/Panel/ItemContent
@onready var calendar_content = $Control/Panel/CalendarContent
@onready var map_content = $Control/Panel/MapContent

var current_panel: Control
var slide_tween: Tween
var background_tween: Tween
var is_sliding: bool = false

func _ready():
	preparing_position()
	set_current_panel("Body")

func _input(event):
	if event.is_action_pressed("ui_cancel"):  # ESC
		close()

func close():
	panel_closed.emit()
	queue_free()

func preparing_position(): # 屏幕外准备位置
	panel_pack.global_position = Vector2(-300, -300)
	panel_pack.rotation_degrees = 90.0
	panel_pack.scale = Vector2(0.1, 0.1)
	background_colour.modulate.a = 0
	

func normal_position(): # 正常显示位置
	panel_pack.position = Vector2.ZERO
	panel_pack.rotation_degrees = 0.0
	panel_pack.scale = Vector2(1.0, 1.0)
	background_colour.modulate.a = 1

func open_animation():
	is_sliding = true
	if slide_tween:
		slide_tween.kill()
	slide_tween = create_tween()
	if background_tween:
		background_tween.kill()
	background_tween = create_tween()
	
	# 向下滑动
	background_tween.tween_property(background_colour, "modulate.a", 1.0, 0.3)
	slide_tween.parallel().tween_property(panel_pack, "position", Vector2(40.0, 150.0), 0.3)
	slide_tween.parallel().tween_property(panel_pack, "scale", Vector2(0.6, 0.4), 0.3)
	slide_tween.parallel().tween_property(panel_pack, "rotation_degrees", -20, 0.3).set_ease(Tween.EASE_IN)
	
	slide_tween.tween_property(panel_pack, "position", Vector2.ZERO, 0.1)
	slide_tween.parallel().tween_property(panel_pack, "scale", Vector2(0.8, 0.8), 0.1)
	slide_tween.parallel().tween_property(panel_pack, "rotation_degrees", 15, 0.1)
	
	slide_tween.tween_property(panel_pack, "rotation_degrees", 0, 0.1).set_ease(Tween.EASE_OUT)
	slide_tween.parallel().tween_property(panel_pack, "scale", Vector2(1.0, 1.0), 0.1)
	slide_tween.tween_callback(on_slide_finished)

func change_animation():
	is_sliding = true
	if slide_tween:
		slide_tween.kill()
	slide_tween = create_tween()
	if background_tween:
		background_tween.kill()
	background_tween = create_tween()

func set_current_panel(panel:String):
	match(panel):
		"Body":
			current_panel = body_content
			study_content.hide()
			item_content.hide()
			calendar_content.hide()
			map_content.hide()
		"Study":
			current_panel = study_content
			body_content.hide()
			item_content.hide()
			calendar_content.hide()
			map_content.hide()
		"Item":
			current_panel = item_content
			body_content.hide()
			study_content.hide()
			calendar_content.hide()
			map_content.hide()
		"Calendar":
			current_panel = calendar_content
			body_content.hide()
			study_content.hide()
			item_content.hide()
			map_content.hide()
		"Map":
			current_panel = map_content
			body_content.hide()
			study_content.hide()
			item_content.hide()
			calendar_content.hide()
	current_panel.show()
	open_animation()
	
func on_slide_finished():
	is_sliding = false
	normal_position()


func _on_tab_body_pressed() -> void:
	pass # Replace with function body.


func _on_tab_item_pressed() -> void:
	pass # Replace with function body.


func _on_tab_study_pressed() -> void:
	pass # Replace with function body.


func _on_tab_map_pressed() -> void:
	pass # Replace with function body.


func _on_tab_calendar_pressed() -> void:
	pass # Replace with function body.


func _on_cancel_pressed() -> void:
	close()
