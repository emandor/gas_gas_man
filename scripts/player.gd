extends CharacterBody2D

@export var package_scene: PackedScene

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var aim_preview = get_node_or_null("../AimPreview")

# Drag-to-aim tuning (calibrated from tests/PhysicsSim.gd)
const MAX_DRAG := 260.0      # pull length (px) for full power
const MIN_SPEED := 600.0     # throw speed at minimum effective pull
const MAX_SPEED := 1300.0    # throw speed at full pull
const MIN_POWER := 0.12      # below this fraction, release is ignored (tap)
const THROW_COOLDOWN := 0.4

var can_throw := true
var is_aiming := false
var aim_start := Vector2.ZERO
var throw_vel := Vector2.ZERO
var current_palet: Area2D = null
var current_atap: Area2D = null
var game_started := false

func start_game():
	game_started = true
	anim.play("idle")

func reset_player():
	game_started = false
	is_aiming = false
	can_throw = true
	if aim_preview:
		aim_preview.clear()
	anim.play("idle")

func _ready():
	if not package_scene:
		package_scene = preload("res://scenes/objects/Package.tscn")
	if package_scene == null:
		push_error("Gagal load Package.tscn")
	anim.play("idle")

func _launch_point() -> Vector2:
	return global_position + Vector2(60, -25)

func _input(event):
	if not game_started:
		return

	# --- begin aim (touch or mouse press) ---
	var press := false
	var release := false
	var pointer := Vector2.ZERO
	if event is InputEventScreenTouch:
		pointer = event.position
		press = event.pressed
		release = not event.pressed
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		pointer = event.position
		press = event.pressed
		release = not event.pressed
	elif event is InputEventScreenDrag or event is InputEventMouseMotion:
		if is_aiming:
			_update_aim(event.position)
		return
	elif event.is_action_pressed("throw_package") and can_throw:
		# keyboard quick-throw: fixed forward-up arc at ~70% power
		_do_throw(Vector2(1, -1).normalized() * lerp(MIN_SPEED, MAX_SPEED, 0.7))
		return
	else:
		return

	if press and can_throw:
		is_aiming = true
		aim_start = pointer
		throw_vel = Vector2.ZERO
		_pull_fraction = 0.0
		anim.play("throw")
	elif release and is_aiming:
		is_aiming = false
		if aim_preview:
			aim_preview.clear()
		var power = throw_vel.length()
		if power > 0.0 and (_pull_fraction >= MIN_POWER):
			_do_throw(throw_vel)
		else:
			anim.play("idle")   # cancelled — too small a drag

var _pull_fraction := 0.0

func _update_aim(pointer: Vector2):
	var pull = aim_start - pointer          # slingshot: pull back to fling forward
	var frac = clamp(pull.length() / MAX_DRAG, 0.0, 1.0)
	_pull_fraction = frac
	if frac <= 0.001:
		throw_vel = Vector2.ZERO
		if aim_preview:
			aim_preview.clear()
		return
	var speed = lerp(MIN_SPEED, MAX_SPEED, frac)
	throw_vel = pull.normalized() * speed
	if aim_preview:
		aim_preview.show_arc(_launch_point(), throw_vel)

func _do_throw(vel: Vector2):
	if not package_scene:
		return
	var pkg = package_scene.instantiate()
	if pkg == null:
		return
	get_parent().add_child(pkg)
	pkg.global_position = _launch_point()
	GameState.add_thrown()
	pkg.throw_velocity(vel)
	AudioManager.play_sfx("throw")
	can_throw = false
	anim.play("throwing")
	await get_tree().create_timer(THROW_COOLDOWN).timeout
	can_throw = true
	anim.play("idle")

# --- target wiring (unchanged: houses connect their pallet/roof signals here) ---
func set_palet_target(palet: Area2D):
	current_palet = palet
	if current_palet and not current_palet.package_hit.is_connected(_on_package_hit):
		current_palet.package_hit.connect(_on_package_hit)

func set_atap_target(atap: Area2D):
	current_atap = atap
	if current_atap and not current_atap.package_hit.is_connected(_on_package_hit_roof):
		current_atap.package_hit.connect(_on_package_hit_roof)

func _on_package_hit_roof(_success: bool):
	anim.play("failed")
	GameState.add_delivery_fail()

func _on_package_hit(success: bool):
	if success:
		anim.play("success")
		GameState.add_delivery_success()
	else:
		anim.play("failed")
		GameState.add_delivery_fail()
