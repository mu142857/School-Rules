# autoload/scene_changer.gd
extends Node

# 记录目标生成点的名字（比如 "Door_A", "Stairs_Up"）
var target_spawn_point_name: String = ""

func change_scene(scene_path: String, spawn_point_name: String):
	target_spawn_point_name = spawn_point_name
	get_tree().change_scene_to_file(scene_path)
