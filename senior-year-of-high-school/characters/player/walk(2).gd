# StateMachine/Walk(2)

extends Basic_State

@onready var player: CharacterBody2D = $"../.."
@onready var animated_sprite: AnimatedSprite2D = $"../../AnimatedSprite2D"

func enter():
	animated_sprite.play("Walk")

func process():
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if direction == Vector2.ZERO:
		get_parent().change_state(1)  # Idle state
		return
	
	# 移动逻辑
	player.velocity = direction * player.SPEED
	
	# 翻转角色朝向
	if direction.x > 0:
		animated_sprite.flip_h = false
	elif direction.x < 0:
		animated_sprite.flip_h = true
	
	player.move_and_slide()

func exit():
	pass
