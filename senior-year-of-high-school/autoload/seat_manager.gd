# autoload/seat_manager.gd
extends Node

# 座位图：{ seat_id: { "type": "B1", "is_short": false, "is_player": false } }
var seat_map: Dictionary = {}

const COMMON_TYPES = ["B1", "B2", "B3", "B4", "G1", "G2", "G3", "G4"]

func _ready():
	# 游戏启动时分配一次，之后除非手动调用，否则不变
	generate_initial_seats()

# 计算玩家目前的 Seat ID
func get_player_seat_id() -> int:
	return (GameManager.seat_row - 1) * 10 + GameManager.seat_col

# 生成初始分配（开学）
func generate_initial_seats():
	seat_map.clear()
	var player_id = get_player_seat_id()
	
	# 1. 准备 60 个“服装名额”：15个短袖，45个长袖
	var clothing_pool = []
	for i in range(15): clothing_pool.append(true)  # 短袖
	for i in range(45): clothing_pool.append(false) # 长袖
	clothing_pool.shuffle() # 打乱名额
	
	# 2. 准备座位索引池
	var pool = []
	for i in range(1, 61):
		pool.append(i)
	
	# 3. 按顺序分配（因为 clothing_pool 已经乱了，座位顺序不重要）
	for i in range(60):
		var s_id = pool[i]
		var is_p = (s_id == player_id)
		
		seat_map[s_id] = {
			"type": "PLAYER" if is_p else COMMON_TYPES.pick_random(),
			"is_short": clothing_pool[i], # 从名额池分配
			"is_player": is_p
		}

# 方便以后换座位用的函数
func swap_seats(id_a: int, id_b: int):
	var temp = seat_map[id_a]
	seat_map[id_a] = seat_map[id_b]
	seat_map[id_b] = temp
	# 换完后记得发个信号，让教室里所有椅子刷新

func update_seasonal_clothes():
	var month = GameManager.month
	var day = GameManager.day
	
	# 设定目标短袖人数
	var target_short_count = 15 # 初始
	if month == 4: target_short_count = 25
	if month == 5: target_short_count = 45
	if month >= 6: target_short_count = 55 # 绝大多数穿短袖
	
	# 计算当前有多少短袖
	var current_short_ids = []
	var current_long_ids = []
	for id in seat_map:
		if seat_map[id].is_player: continue
		if seat_map[id].is_short:
			current_short_ids.append(id)
		else:
			current_long_ids.append(id)
	
	# 如果当前短袖不够，从长袖里随机抽人换衣服
	var needed = target_short_count - current_short_ids.size()
	if needed > 0 and current_long_ids.size() > 0:
		current_long_ids.shuffle()
		for i in range(min(needed, current_long_ids.size())):
			var target_id = current_long_ids[i]
			seat_map[target_id].is_short = true
			
		# 发送信号，让目前正在显示的椅子刷新外观
		notify_chairs_to_refresh()

signal seats_need_refresh

func notify_chairs_to_refresh():
	seats_need_refresh.emit()
