extends Node

func goto(path:String) -> void:
	get_tree().change_scene_to_file(path)
