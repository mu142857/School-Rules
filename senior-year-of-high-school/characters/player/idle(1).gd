# StateMachine/Idle(1)

extends Basic_State

@onready var player: CharacterBody2D = get_parent().get_parent()
@onready var ani2d: AnimatedSprite2D = player.get_node("AnimatedSprite2D")
@onready var state_machine: State_Manager = get_parent()

func enter():
	ani2d.play("Idle")

func process():
	# 有输入就切换到Walk
	if player.direction != Vector2.ZERO:
		state_machine.change_state(2)
