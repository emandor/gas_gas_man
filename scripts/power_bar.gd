extends CanvasLayer
signal throw_power_ready(power: float)
@onready var bar = $TextureProgressBar

var is_charging := false
var power := 0.0
var charge_speed := 80.0
var direction := 1

func _process(delta):
	if is_charging:
		power += charge_speed * direction * delta
		if power >= 100:
			power = 100
			direction = -1
		elif power <= 0:
			power = 0
			direction = 1
		bar.value = power
		bar.visible = true
	else:
		bar.visible = false

func start_charge():
	is_charging = true
	power = 0
	direction = 1
	bar.visible = true

func stop_charge():
	is_charging = false
	throw_power_ready.emit(power)
