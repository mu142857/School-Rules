# res://locations/doors and portals/interact_zone.tscn

@export_file("*.tscn") var target_scene_path: String
@export var target_spawn_id: String  # 对应新场景里 Marker2D 的名字

func teleport():
	if target_scene_path == "": return
	# 调用全局管理器，传入目的地和具体的生成点名字
	SceneChanger.change_scene(target_scene_path, target_spawn_id)
