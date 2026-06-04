extends RigidBody2D

@export var z_gravity := 30.0   # depth-axis decay (slower = smoother shrink); was 90
@export var wind_strength := 0.0
@export var max_fade_distance := 200.0

var base_scale := Vector2.ONE
var z_velocity := 0.0
var alive := false

func _ready():
	base_scale = scale
	freeze = true
	sleeping = true

	# 🔥 wajib untuk deteksi collision
	contact_monitor = true
	max_contacts_reported = 1

	# damping set once here — was being re-set every physics frame
	linear_damp = 0.05
	angular_damp = 1.5

	connect("body_entered", _on_body_entered)
	add_to_group("package")

func throw_velocity(vel: Vector2):
	# Drag-to-aim throw: launch at an explicit velocity (mass=1 → impulse==velocity).
	freeze = false
	sleeping = false
	alive = true
	z_velocity = abs(vel.y) * 0.05   # small depth pop scaled to throw strength
	linear_velocity = vel

func throw_package(power: float, dir: int):
	# Legacy power-based throw (kept for the sim harness / fallback).
	freeze = false
	sleeping = false
	alive = true

	global_position.x -= 50.0 * dir

	var base_force = 400.0 * power
	var up_force = 550.0 * power
	var z_power = 40.0 * power

	z_velocity = z_power

	apply_central_impulse(Vector2(base_force * dir, -up_force))

func _physics_process(delta):
	if not alive:
		return

	z_velocity -= z_gravity * delta
	if z_velocity < 0:
		var shrink_factor = 1.0 + (z_velocity / 250.0)
		scale = base_scale * clamp(shrink_factor, 0.55, 1.0)

	if wind_strength != 0.0:
		apply_central_force(Vector2(wind_strength * delta * 10.0, 0))

	if global_position.y > 800 or modulate.a < 0.45:
		queue_free()

func reset_package():
	freeze = true
	sleeping = true
	alive = false
	z_velocity = 0.0
	scale = base_scale
	modulate = Color.WHITE
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	global_position = Vector2(200, 400)

func deflect():
	apply_central_impulse(Vector2(randf_range(-100.0, -50.0), randf_range(-150.0, -80.0)))
	GameState.add_delivery_fail()

func _on_body_entered(body):
	if body.name == "Ground" or body.is_in_group("ground"):
		alive = false
		freeze = true
		var t = create_tween()
		t.tween_property(self, "modulate:a", 0.0, 0.2)
		t.tween_callback(queue_free)
