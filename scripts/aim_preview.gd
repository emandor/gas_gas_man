extends Node2D
## Dotted trajectory preview for drag-to-aim. Integrates with the SAME math the
## RigidBody package uses (g = 980 * gravity_scale, linear_damp), so the dots
## land where the package will land.

const GRAVITY := 1960.0       # 980 * Package gravity_scale(2.0)
const LINEAR_DAMP := 0.05
const STEP := 1.0 / 60.0
const MAX_STEPS := 90          # ~1.5s of flight
const DOT_EVERY := 3           # draw every Nth step → dotted look
const GROUND_Y := 560.0

var _launch := Vector2.ZERO
var _vel := Vector2.ZERO
var _active := false

func show_arc(launch: Vector2, vel: Vector2):
	_launch = launch
	_vel = vel
	_active = true
	queue_redraw()

func clear():
	_active = false
	queue_redraw()

func _draw():
	if not _active:
		return
	var pos = _launch
	var v = _vel
	var c_full = Color(1.0, 0.85, 0.2)       # orange-gold
	var c_brown = Color(0.173, 0.094, 0.063)
	for i in range(MAX_STEPS):
		v.y += GRAVITY * STEP
		v *= 1.0 / (1.0 + STEP * LINEAR_DAMP)
		pos += v * STEP
		if pos.y > GROUND_Y:
			break
		if i % DOT_EVERY == 0:
			var t = float(i) / float(MAX_STEPS)
			var r = lerp(7.0, 3.0, t)          # dots shrink along the arc
			var a = lerp(0.95, 0.25, t)        # and fade
			draw_circle(pos, r + 1.5, Color(c_brown.r, c_brown.g, c_brown.b, a))  # outline
			draw_circle(pos, r, Color(c_full.r, c_full.g, c_full.b, a))
