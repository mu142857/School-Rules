# StateMachine/Empty(0)

extends Basic_State
# 空状态

func enter():
	get_parent().change_state(1)
