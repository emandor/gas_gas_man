extends Node2D

@export var min_scale := 0.3
@export var max_scale := 0.5
@export var min_speed := 200.0
@export var max_speed := 200.0

var palet: Area2D

var speed := 200.0

func set_depth_speed(scale_factor: float):
	speed = lerp(240.0, 90.0, scale_factor)
	scale = Vector2(scale_factor, scale_factor)

func set_speed(value: float):
	speed = value
	
func _process(delta):
	position.x -= speed * delta
	if position.x < -300:
		queue_free()

func _ready():
	var s = randf_range(min_scale, max_scale)
	scale = Vector2(s, s)

	# kecepatan tergantung jarak (lebih kecil → lebih lambat)
	speed = lerp(max_speed, min_speed, (s - min_scale) / (max_scale - min_scale))

	# spawn dari kanan layar
	global_position = Vector2(randf_range(1300, 1800), randf_range(370, 375))
