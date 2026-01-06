# StateMachine/Walk(2)

extends Basic_State

@onready var player: CharacterBody2D = get_parent().get_parent()
@onready var ani2d: AnimatedSprite2D = player.get_node("AnimatedSprite2D")
@onready var state_machine: State_Manager = get_parent()

func enter():
	ani2d.play("Walk")

func process():
	# 没输入就切换回Idle
	if player.direction == Vector2.ZERO:
		state_machine.change_state(1)
