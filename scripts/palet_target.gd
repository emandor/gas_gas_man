extends Area2D

## Kirim ke PlayerMotor saat paket berhasil stay di atas palet
signal package_hit(success: bool)

@export var required_stay_time := 0.5   # berapa lama paket harus diam di atas palet
@export var debug_color := Color(0, 1, 0, 0.25)

var _overlapping_package: RigidBody2D = null
var _stay_timer := 0.0
var _is_success_sent := false

func _ready():
	# pastikan Area2D aktif
	monitoring = true
	monitorable = true
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)
	set_process(true)

func _physics_process(delta):
	if _overlapping_package:
		_stay_timer += delta
		# paket harus diam di atas palet selama durasi tertentu
		if _stay_timer >= required_stay_time and not _is_success_sent:
			_is_success_sent = true
			print("✅ Paket stay di atas palet — HIT SUCCESS!")
			emit_signal("package_hit", true)
	else:
		# reset kalau paket keluar
		_stay_timer = 0.0
		_is_success_sent = false


func _on_body_entered(body):
	if body.name == "Package" or body.is_in_group("package"):
		print("📦 Paket masuk ke area palet")
		_overlapping_package = body


func _on_body_exited(body):
	if body == _overlapping_package:
		print("📦 Paket keluar dari area palet")
		_overlapping_package = null
