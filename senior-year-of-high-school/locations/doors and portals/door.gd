# res://locations/doors and portals/door.tscn

extends Node2D
@export var door_type: int = 1

func _ready() -> void:
	if door_type == 1:
		$Door1.show()
		$Door2.hide()
	elif door_type == 2:
		$Door1.hide()
		$Door2.show()
	else:
		$Door1.hide()
		$Door2.hide()
