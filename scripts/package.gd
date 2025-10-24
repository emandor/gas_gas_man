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
	contact_monitor = true

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

	linear_damp = 0.4
	angular_damp = 0.6

	if global_position.y > 800 or modulate.a < 0.45:
		queue_free()
