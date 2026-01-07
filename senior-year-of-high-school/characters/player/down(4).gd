# StateMachine/Down(4)

extends Basic_State

@onready var player: CharacterBody2D = $"../.."
@onready var animated_sprite: AnimatedSprite2D = $"../../AnimatedSprite2D"

var state_timer: float = 0.0
const MIN_STATE_TIME: float = 0.1

func enter():
	animated_sprite.play("Down")
	state_timer = 0.0

func process():
	state_timer += get_physics_process_delta_time()
	
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if state_timer >= MIN_STATE_TIME:
		# 无输入
		if direction == Vector2.ZERO:
			get_parent().change_state(1)  # Idle
			return
		
		# 不再是纯向下
		if direction.x != 0 or direction.y <= 0:
			if direction.x == 0 and direction.y < 0:
				get_parent().change_state(3)  # Up
			else:
				get_parent().change_state(2)  # Walk
			return
	
	# 有向下输入就移动
	if direction.y > 0:
		player.velocity = direction * player.SPEED
		player.move_and_slide()

func exit():
	pass
