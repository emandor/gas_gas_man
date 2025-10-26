extends Node2D

@export var segment_width : float = 2024.0
@export var move_speed : float = 220.0

@onready var camera_2d : Camera2D = get_tree().get_first_node_in_group("camera")

func _ready() -> void:
	if camera_2d == null:
		camera_2d = get_viewport().get_camera_2d()

func _process(delta: float) -> void:
	# sementara: auto scroll kalau player belum aktif
	position.x -= move_speed * delta
	_recycle_segments()

func _recycle_segments() -> void:
	for seg in get_children():
		var right_edge = seg.global_position.x + segment_width
		var left_edge_cam = camera_2d.global_position.x - (get_viewport().get_visible_rect().size.x * 0.6)
		if right_edge < left_edge_cam:
			var max_x = _get_max_segment_x()
			seg.global_position.x = max_x + segment_width

func _get_max_segment_x() -> float:
	var max_val = -INF
	for c in get_children():
		max_val = max(max_val, c.global_position.x)
	return max_val
