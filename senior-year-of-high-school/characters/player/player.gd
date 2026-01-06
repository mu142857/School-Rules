extends CharacterBody2D

const SPEED: float = 200.0

var direction: Vector2 = Vector2.ZERO

@onready var state_machine: State_Manager = $StateMachine
@onready var ani2d: AnimatedSprite2D = $AnimatedSprite2D

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	# 获取输入方向
	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# 移动
	velocity = direction * SPEED
	move_and_slide()
	
	# 翻转sprite（面向左/右）
	if direction.x != 0:
		ani2d.flip_h = direction.x < 0
