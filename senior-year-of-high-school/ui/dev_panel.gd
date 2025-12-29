# ui/dev_panel.gd
extends CanvasLayer

@onready var panel = $Panel
@onready var label = $Panel/ScrollContainer/Label

func _ready():
	panel.visible = false
	panel.position = Vector2.ZERO
	panel.custom_minimum_size = Vector2(280, 400)

func _process(_delta):
	if GameManager.dev_mode:
		panel.visible = true
		label.text = GameManager.get_debug_text()
	else:
		panel.visible = false
