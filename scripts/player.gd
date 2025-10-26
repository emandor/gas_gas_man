extends CharacterBody2D

@export var package_scene: PackedScene    # Bisa diatur dari Inspector

@onready var power_bar = $"../PowerBar"
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var throw_sound = $AudioStreamPlayer2D

var can_throw := true
var is_charging := false
var state := "idle"
var current_palet: Area2D = null
var current_atap: Area2D = null
var game_started := false


func start_game():
	game_started = true
	anim.play("idle")

func reset_player():
	game_started = false
	is_charging = false
	can_throw = true
	anim.play("idle")

func _ready():
	# Pastikan package_scene terload
	if not package_scene:
		package_scene = preload("res://scenes/objects/Package.tscn")
	
	if package_scene == null:
		push_error("❌ Gagal load Package.tscn! Periksa path atau isi di Inspector.")
	else:
		print("✅ Package scene loaded:", package_scene.resource_path)

	# PowerBar connect
	if power_bar:
		power_bar.throw_power_ready.connect(_on_throw_power_ready)
	else:
		push_warning("⚠️ PowerBar tidak ditemukan oleh PlayerMotor!")
	
	anim.play("idle")
	
func _charging():
	is_charging = true
	power_bar.start_charge()
	anim.play("throw")

func throwing():
	is_charging = false
	can_throw = false
	power_bar.stop_charge()
	anim.play("throwing")
	

func _input(event):
	if not game_started:
		return

	if event is InputEventScreenTouch:
		if event.pressed and can_throw:
			_charging()
			
		elif not event.pressed and is_charging:
			throwing()

	elif event.is_action_pressed("throw_package") and can_throw:
		_charging()

	elif event.is_action_released("throw_package") and is_charging:
		throwing()

func _physics_process(delta):
	if not game_started:
		return
	
	if Input.is_action_just_pressed("throw_package") and can_throw:
		is_charging = true
		power_bar.start_charge()
		anim.play("throw")

	elif Input.is_action_just_released("throw_package") and is_charging:
		is_charging = false
		can_throw = false
		power_bar.stop_charge()
		anim.play("throwing")
		


func _on_throw_power_ready(power: float):
	throw_package(power / 100.0)


func throw_package(power: float):
	if not package_scene:
		push_error("❌ Tidak bisa instantiate Package — package_scene NULL!")
		return

	var pkg = package_scene.instantiate()
	if pkg == null:
		push_error("❌ instantiate gagal! Pastikan path Package.tscn valid.")
		return

	get_parent().add_child(pkg)
	pkg.global_position = global_position + Vector2(60, -25)
	
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.add_thrown()

	# Arah lempar ke kanan
	pkg.throw_package(power, 1)
	throw_sound.play()
	

	# Jika ada palet aktif, kirim ke package
	if current_palet and pkg.has_method("set_target"):
		pkg.set_target(current_palet)
	
	if current_atap and pkg.has_method("set_target"):
		pkg.set_target(current_atap)

	await get_tree().create_timer(0.4).timeout
	can_throw = true
	anim.play("idle")


# Dipanggil dari Game.gd / HouseSpawner saat rumah spawn
func set_palet_target(palet: Area2D):
	current_palet = palet
	if current_palet and not current_palet.package_hit.is_connected(_on_package_hit):
		current_palet.package_hit.connect(_on_package_hit)
		
# Dipanggil dari Game.gd / HouseSpawner saat rumah spawn
func set_atap_target(atap: Area2D):
	current_atap = atap
	if current_atap and not current_atap.package_hit.is_connected(_on_package_hit_roof):
		current_atap.package_hit.connect(_on_package_hit_roof)

func _on_package_hit_roof(success: bool):
	anim.play("failed")

func _on_package_hit(success: bool):
	if success:
		anim.play("success")
		# cari HUD dari scene root dan tambah skor
		var hud = get_tree().get_first_node_in_group("hud")
		if hud:
			hud.add_score()
	else:
		anim.play("failed")
