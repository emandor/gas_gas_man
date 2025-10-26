extends Node2D

@export var min_scale := 0.5
@export var max_scale := 0.6
@export var min_speed := 200.0
@export var max_speed := 200.0

var palet: Area2D
var atap: Area2D

var speed := 200.0

func set_depth_speed(scale_factor: float):
	# semakin kecil scale → lebih jauh → lebih lambat
	speed = lerp(240.0, 90.0, scale_factor)
	scale = Vector2(scale_factor, scale_factor)

func set_speed(value: float):
	speed = value
	
func _process(delta):
	position.x -= speed * delta
	if position.x < -300:
		queue_free()

func _ready():
	# acak ukuran (simulasi jarak)
	var s = randf_range(min_scale, max_scale)
	scale = Vector2(s, s)

	# kecepatan tergantung jarak (lebih kecil → lebih lambat)
	speed = lerp(max_speed, min_speed, (s - min_scale) / (max_scale - min_scale))

	# spawn dari kanan layar
	global_position = Vector2(1700, randf_range(380, 400))

	# koneksi event palet
	palet = $PaletTarget
	palet.package_hit.connect(_on_package_hit)
	
	atap = $Atap/AtapHit
	atap.package_hit.connect(_on_package_hit)


func _on_package_hit(success: bool):
	if success:
		print("🏆 Rumah menerima paket dengan sukses!")
	else:
		print("💣 Paket gagal dikirim!")
