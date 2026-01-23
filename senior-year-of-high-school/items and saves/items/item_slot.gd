# ui/item_slot.gd

extends TextureButton

@onready var icon = $Icon
@onready var count_label = $CountLabel

var item_id: String = ""
var is_consumable: bool = true

var normal_tex = preload("res://items and saves/items/item_background.png")
var selected_tex = preload("res://items and saves/items/item_background_selected.png")

func setup(id: String, texture_path: String, count: int, consumable: bool):
	item_id = id
	is_consumable = consumable
	icon.texture = load(texture_path)
	
	if is_consumable:
		count_label.text = str(count)
		count_label.show()
	else:
		count_label.hide() # 永久物品不显示数量

func set_selected(state: bool):
	texture_normal = selected_tex if state else normal_tex

func set_owned(is_owned: bool):
	if is_owned:
		modulate = Color(1, 1, 1, 1) # 正常颜色
		count_label.show()
	else:
		modulate = Color(0.3, 0.3, 0.3, 1) # 变暗/变灰
		count_label.hide() # 没拥有时不显示数量 0
