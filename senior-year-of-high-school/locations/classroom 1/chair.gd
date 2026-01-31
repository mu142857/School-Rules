# res://locations/classroom 1/chair.tscn
extends Node2D

@export var seat_id: int = 0  # 在编辑器里手动填 1 - 60

@onready var legs_sprite = $Legs
@onready var body_sprite = $Body

const BASE_PATH = "res://characters/character_animations/"

func _ready():
	# 等一帧确保 Autoload 加载完毕，或者直接调用
	call_deferred("refresh_visual")

func refresh_visual():
	if not SeatManager.seat_map.has(seat_id):
		# 如果没有这个座位的数据（比如你写了 61 号），隐藏并报错
		hide_npc()
		return
	
	var data = SeatManager.seat_map[seat_id]
	
	# 1. 如果是主角位，不显示 NPC 贴图
	if data.is_player:
		hide_npc()
		return
	
	# 2. 构建图片路径
	var type = data.type # 如 "B1"
	var sleeve = "_Body_S.png" if data.is_short else "_Body_L.png"
	
	var legs_path = BASE_PATH + type + "_Legs.png"
	var body_path = BASE_PATH + type + sleeve
	
	# 3. 尝试加载并贴图
	# 注意：使用 load 可能在大批量生成时有微小卡顿，之后如果觉得慢可以改用全局预载
	legs_sprite.texture = load(legs_path)
	body_sprite.texture = load(body_path)
	
	# 确保显示
	legs_sprite.show()
	body_sprite.show()

func hide_npc():
	legs_sprite.texture = null
	body_sprite.texture = null
