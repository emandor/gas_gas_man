extends Node2D

func play_at(pos: Vector2, success: bool):
	global_position = pos
	var burst_color = Color(1.0, 0.85, 0.0) if success else Color(1.0, 0.3, 0.1)
	$Burst.modulate = burst_color
	$Ring.modulate = burst_color
	$Burst.restart()
	$Ring.restart()
	await get_tree().create_timer($Burst.lifetime + 0.15).timeout
	queue_free()
