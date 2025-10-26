extends Timer
signal house_delivered(success: bool)

@export var house_scene: PackedScene
@export var spawn_position: Vector2 = Vector2(1400, 470)
@export var house_speed: float = 180.0

var _active := false

func _ready():
	wait_time = Constants.HOUSE_SPAWN_INTERVAL
	one_shot = false
	timeout.connect(_on_timeout)

func start():
	if _active: return
	_active = true
	start() # Timer.start()
	# catatan: kalau nama fungsi bentrok, panggil .start() sebagai Timer:
	Timer.start()

func stop():
	_active = false
	Timer.stop()

func _on_timeout():
	if not house_scene: return
	var h: Node2D = house_scene.instantiate()
	h.position = spawn_position
	if h.has_method("set_speed"):
		h.set_speed(house_speed)
	get_parent().add_child(h)
	h.add_to_group(Constants.GROUP_HOUSE)
	# contoh: house mengirim sinyal "delivered"
	if h.has_signal("delivered"):
		h.connect("delivered", func(ok): emit_signal("house_delivered", ok))
