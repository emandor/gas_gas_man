extends Camera2D

var _duration: float = 0.0
var _magnitude: float = 0.0
var _time: float = 0.0

func shake(duration: float = 0.2, magnitude: float = 8.0):
	_duration = duration
	_magnitude = magnitude
	_time = 0.0

func _process(delta):
	if _duration > 0:
		_duration -= delta
		_time += delta
		offset = Vector2(
			sin(_time * 15.0) * _magnitude,
			cos(_time * 11.0) * _magnitude * 0.7
		)
		_magnitude = lerp(_magnitude, 0.0, delta * 5.0)
	else:
		offset = Vector2.ZERO
