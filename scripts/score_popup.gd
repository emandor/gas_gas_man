extends Label

func popup(text: String, color: Color, start_pos: Vector2):
	self.text = text
	add_theme_color_override("font_color", color)
	global_position = start_pos
	var t = create_tween()
	t.tween_property(self, "position:y", position.y - 80, 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(self, "modulate:a", 0.0, 0.5).set_delay(0.3)
	t.tween_callback(queue_free)
