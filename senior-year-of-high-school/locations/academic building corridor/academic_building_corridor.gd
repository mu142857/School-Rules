# res://locations/academic building corridor/academic_building_corridor.tscn

extends Node2D

@export_group("Camera Settings")
@export var camera_limit_left: int = -10000
@export var camera_limit_top: int = -10000
@export var camera_limit_right: int = 10000
@export var camera_limit_bottom: int = 10000
@export var camera_zoom: Vector2 = Vector2(0.8, 0.8)
@export var camera_offset: Vector2 = Vector2(0, -250)

@onready var player_scene = preload("res://characters/player/player.tscn")
@onready var spawn_points = $SpawnPoints

func _ready():
	spawn_and_setup_player()

func spawn_and_setup_player():
	# 1. 实例化主角
	var player = player_scene.instantiate()
	add_child(player)
	
	# 2. 定位到正确的 Marker2D
	# 从全局 SceneChanger 获取目标点名字
	var target_point = SceneChanger.target_spawn_point_name
	var spawn_node = spawn_points.get_node_or_null(NodePath(target_point))
	
	if spawn_node:
		player.global_position = spawn_node.global_position
	else:
		# 兜底方案：如果找不到点（比如直接按 F6 运行），去第一个子节点
		if spawn_points.get_child_count() > 0:
			player.global_position = spawn_points.get_child(0).global_position
	
	# 3. 配置内置相机
	var camera = player.get_node_or_null("Camera2D")
	if camera:
		camera.limit_left = camera_limit_left
		camera.limit_top = camera_limit_top
		camera.limit_right = camera_limit_right
		camera.limit_bottom = camera_limit_bottom
		
		# 应用你提供的具体数值
		camera.zoom = camera_zoom
		camera.offset = camera_offset
		
		# 开启平滑移动，这样传送过去时不会瞬间硬跳
		camera.position_smoothing_enabled = true
		camera.position_smoothing_speed = 5.0
