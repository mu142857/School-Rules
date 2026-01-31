# res://locations/doors and portals/interact_zone.tscn

extends Area2D

# === 配置参数 (在编辑器右侧直接选) ===
@export_group("传送设置")
@export_file("*.tscn") var target_scene_path: String  # 目的地场景文件
@export var target_spawn_id: String = "Default"       # 对应目的地 Marker2D 的名字

@export_group("交互设置")
@export var interact_text: String = "进门"             # 提示文字内容
@export var interact_action: String = "ui_accept"      # 默认是空格键

@onready var prompt_label = $PromptAnchor/PromptLabel

var is_player_in_zone: bool = false

func _ready():
	prompt_label.text = interact_text
	prompt_label.hide()
	
	# 连接信号（检测主角进出）
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	# 假设你的主角节点名字叫 Player，或者属于 "player" 组
	if body.is_in_group("player") or body.name == "Player":
		is_player_in_zone = true
		prompt_label.show()

func _on_body_exited(body):
	if body.is_in_group("player") or body.name == "Player":
		is_player_in_zone = false
		prompt_label.hide()

func _input(event):
	if is_player_in_zone:
		# 触发条件：按下交互键 OR 鼠标左键点击
		var is_action = event.is_action_pressed(interact_action)
		var is_click = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed
		
		if is_action or is_click:
			teleport()

func teleport():
	if target_scene_path == "":
		print("警告：传送门未设置目的地场景！")
		return
	
	# 更新当前场景记录（给地图用）
	# 提取文件名：res://scenes/classroom_1.tscn -> classroom_1
	var scene_name = target_scene_path.get_file().get_basename()
	GameManager.current_scene = scene_name
	
	print("正在传送到: ", scene_name, " 位置: ", target_spawn_id)
	
	# 调用你已经有的全局切换脚本
	SceneChanger.change_scene(target_scene_path, target_spawn_id)
