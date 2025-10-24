extends Node2D

@export var scroll_speed: float = 200.0
@export var segment_width: float = 1280.0
@export var is_scrolling: bool = true  

func _process(delta):
	if not is_scrolling:
		return  

	for child in get_children():
		child.position.x -= scroll_speed * delta
		if child.position.x <= -segment_width:
			var rightmost_x = -INF
			for c in get_children():
				rightmost_x = max(rightmost_x, c.position.x)
			child.position.x = rightmost_x + segment_width
