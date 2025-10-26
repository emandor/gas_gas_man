extends RigidBody2D

@export var gravity := 2800.0   
@export var z_gravity := 90.0   
@export var shrink_rate := 0.3
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
	
	connect("body_entered", _on_body_entered)
	add_to_group("package")

func throw_package(power: float, dir: int):
	freeze = false
	sleeping = false
	alive = true
	
	global_position.x -= 50.0 * dir 

	var base_force = 220.0 * power 
	var up_force = 350.0 * power   
	var z_power = 80.0 * power

	z_velocity = z_power

	apply_central_impulse(Vector2(base_force * dir, -up_force))

func _physics_process(delta):
	if not alive:
		return

	z_velocity -= z_gravity * delta
	if z_velocity < 0:
		var shrink_factor = 1.0 + (z_velocity / 250.0)
		scale = base_scale * clamp(shrink_factor, 0.55, 1.0)

	apply_central_force(Vector2(wind_strength * delta * 10.0, 0))
	linear_damp = 0.2
	angular_damp = 0.4

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

func _on_body_entered(body):
	if body.name == "Ground" or body.is_in_group("ground"):
		print("💥 Package hit ground, deleting in 0.5s...")
		await get_tree().create_timer(0.3).timeout
		if is_instance_valid(self):
			queue_free()
