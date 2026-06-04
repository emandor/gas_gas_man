extends Area2D

## Kirim ke PlayerMotor saat paket berhasil stay di atas palet
signal package_hit(success: bool)

@export var required_stay_time := 0.1   # brief contact confirm; was 1.5 (impossible on a moving target)
@export var max_entry_speed := 800.0    # reject fast-grazing packages — only register real landings
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
			emit_signal("package_hit", true)
			_spawn_explosion(true)
	else:
		# reset kalau paket keluar
		_stay_timer = 0.0
		_is_success_sent = false


func _on_body_entered(body):
	if body.name == "Package" or body.is_in_group("package"):
		if body is RigidBody2D and body.linear_velocity.length() > max_entry_speed:
			return  # moving too fast — a graze/miss, not a landing
		_overlapping_package = body

func _on_body_exited(body):
	if body == _overlapping_package:
		_overlapping_package = null

func _spawn_explosion(success: bool):
	var cam = get_tree().get_first_node_in_group("camera")
	if cam:
		cam.shake(0.15 if success else 0.25, 8.0 if success else 14.0)
	var fx_scene = load("res://scenes/player/PackageExplosion.tscn")
	if fx_scene:
		var fx = fx_scene.instantiate()
		get_tree().current_scene.add_child(fx)
		fx.play_at(global_position, success)
