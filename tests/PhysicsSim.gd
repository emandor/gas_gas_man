extends Node2D
## Headless physics sim: throws the real Package.tscn at a velocity sweep and
## measures where each lands (crossing pallet height while descending).
## Run: godot --headless --path . res://tests/PhysicsSim.tscn

const PACKAGE := preload("res://scenes/objects/Package.tscn")

# Real in-game geometry (see plan): launch ~(182,494), pallet height ~487.
const LAUNCH := Vector2(182, 494)
const PALLET_Y := 487.0

var _trials: Array = []      # each: {speed, angle_deg, vx, vy}
var _i := -1
var _pkg: RigidBody2D = null
var _t := 0.0
var _peak_y := 9999.0
var _started_descent := false

func _ready():
	# sweep: angles above horizontal × speeds (px/s)
	for angle in [30, 40, 50, 60]:
		for speed in [700, 850, 1000, 1150, 1300]:
			var rad = deg_to_rad(angle)
			_trials.append({
				"speed": speed, "angle": angle,
				"vx": speed * cos(rad),
				"vy": -speed * sin(rad),
			})
	print("=== PHYSICS SIM (g_effective = 980 * gravity_scale) ===")
	print("launch=", LAUNCH, "  pallet_y=", PALLET_Y)
	print("%-6s %-6s %-9s %-9s %-9s %-9s" % ["ang", "spd", "land_x", "range", "peak_h", "flight"])
	_next_trial()

func _next_trial():
	_i += 1
	if _i >= _trials.size():
		print("=== DONE ===")
		get_tree().quit()
		return
	if _pkg and is_instance_valid(_pkg):
		_pkg.queue_free()
	_pkg = PACKAGE.instantiate()
	add_child(_pkg)
	_pkg.global_position = LAUNCH
	_t = 0.0
	_peak_y = LAUNCH.y
	_started_descent = false
	var tr = _trials[_i]
	_pkg.throw_velocity(Vector2(tr.vx, tr.vy))

func _physics_process(delta):
	if _i < 0 or _i >= _trials.size() or _pkg == null or not is_instance_valid(_pkg):
		return
	_t += delta
	var pos = _pkg.global_position
	_peak_y = min(_peak_y, pos.y)            # smaller y = higher
	var vy = _pkg.linear_velocity.y
	if vy > 0:
		_started_descent = true
	# landing = descending and reached pallet height (or just below)
	if _started_descent and pos.y >= PALLET_Y:
		var tr = _trials[_i]
		print("%-6d %-6d %-9.1f %-9.1f %-9.1f %-9.3f" % [
			tr.angle, tr.speed, pos.x, pos.x - LAUNCH.x,
			LAUNCH.y - _peak_y, _t])
		_next_trial()
		return
	# safety timeout (3s) or off-screen
	if _t > 3.0 or pos.y > 900 or pos.x > 3000:
		var tr = _trials[_i]
		print("%-6d %-6d %-9s %-9s %-9.1f %-9.3f" % [
			tr.angle, tr.speed, "MISS", "-", LAUNCH.y - _peak_y, _t])
		_next_trial()
