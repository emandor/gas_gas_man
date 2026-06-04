extends Node

var _overlay: ColorRect = null

func _ready():
	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 0)
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.z_index = 4096
	get_tree().root.call_deferred("add_child", _overlay)

func goto(path: String, duration: float = 0.3) -> void:
	if _overlay == null:
		get_tree().change_scene_to_file(path)
		return
	var t = _overlay.create_tween()
	t.tween_property(_overlay, "color:a", 1.0, duration)
	await t.finished
	get_tree().change_scene_to_file(path)
	t = _overlay.create_tween()
	t.tween_property(_overlay, "color:a", 0.0, duration)
