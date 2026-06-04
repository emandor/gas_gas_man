extends Node2D

@export var min_scale := 0.5
@export var max_scale := 0.6
@export var min_speed := 220.0
@export var max_speed := 220.0
@export var score_multiplier: float = 1.0

var palet: Area2D
var atap: Area2D

var speed := 220.0
var _speed_override := false

func set_depth_speed(scale_factor: float):
	# semakin kecil scale → lebih jauh → lebih lambat
	speed = lerp(240.0, 90.0, scale_factor)
	scale = Vector2(scale_factor, scale_factor)

func set_speed(value: float):
	speed = value
	_speed_override = true

func _process(delta):
	position.x -= speed * delta
	if position.x < -300:
		queue_free()

func _ready():
	# acak ukuran (simulasi jarak)
	var s = randf_range(min_scale, max_scale)
	scale = Vector2(s, s)

	# kecepatan tergantung jarak — only if level config hasn't set it
	if not _speed_override:
		speed = lerp(max_speed, min_speed, (s - min_scale) / (max_scale - min_scale))

	# spawn dari kanan layar
	global_position = Vector2(1700, randf_range(380, 400))

	# koneksi event palet
	palet = $PaletTarget
	palet.package_hit.connect(_on_package_hit)
	
	atap = $Atap/AtapTarget
	atap.package_hit.connect(_on_package_hit)


func _on_package_hit(_success: bool):
	pass
