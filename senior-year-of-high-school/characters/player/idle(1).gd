# StateMachine/Idle(1)

extends Basic_State

@onready var player: CharacterBody2D = $"../.."
@onready var animated_sprite: AnimatedSprite2D = $"../../AnimatedSprite2D"

func enter():
	animated_sprite.play("Idle")
	player.velocity = Vector2.ZERO

func process():
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if direction == Vector2.ZERO:
		return
	
	# 纯向上
	if direction.x == 0 and direction.y < 0:
		get_parent().change_state(3)  # Up
	# 纯向下
	elif direction.x == 0 and direction.y > 0:
		get_parent().change_state(4)  # Down
	# 其他方向
	else:
		get_parent().change_state(2)  # Walk

func exit():
	pass
