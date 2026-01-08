# StateMachine/Walk(2)

extends Basic_State

@onready var player: CharacterBody2D = $"../.."
@onready var animated_sprite: AnimatedSprite2D = $"../../AnimatedSprite2D"

var state_timer: float = 0.0
const MIN_STATE_TIME: float = 0.1  # 最小停留时间，可调整

func enter():
	animated_sprite.play("Walk")
	state_timer = 0.0

func process():
	state_timer += get_physics_process_delta_time()
	
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# 冷却时间内不切换状态
	if state_timer >= MIN_STATE_TIME:
		# 无输入
		if direction == Vector2.ZERO:
			get_parent().change_state(1)  # Idle
			return
		
		# 纯向上
		if direction.x == 0 and direction.y < 0:
			get_parent().change_state(3)  # Up
			return
		
		# 纯向下
		if direction.x == 0 and direction.y > 0:
			get_parent().change_state(4)  # Down
			return
	
	# 有输入就移动（即使在冷却中）
	if direction != Vector2.ZERO:
		player.velocity = direction * player.SPEED
		
		if direction.x > 0:
			player.face_right()
			
		elif direction.x < 0:
			player.face_left()
		
		player.move_and_slide()

func exit():
	pass
