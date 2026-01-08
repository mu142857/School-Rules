# res://characters/player/player.gd

extends CharacterBody2D

const SPEED: float = 500.0

@onready var state_machine: State_Manager = $StateMachine
@onready var ani2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	state_machine.change_state(1)

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	pass

func face_left():
	ani2d.scale.x = -1

func face_right():
	ani2d.scale.x = 1
