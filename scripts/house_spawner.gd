extends Timer

@export var house_scene: PackedScene = preload("res://scenes/environment/House.tscn")
@export var house_scenes: Array[PackedScene] = []
@export var player_path: NodePath

@onready var player: Node = get_node(player_path)

@export var spawn_x := 1400.0
@export var spawn_y := 470.0
@export var house_speed := 180.0

var active_house: Node2D = null

func _ready():
	wait_time = 0.1   # Timer rejects 0; real interval is set in _on_timeout / apply_config
	autostart = false
	timeout.connect(_on_timeout)

func _on_timeout():
	spawn_house()
	wait_time = randf_range(1.8, 3.2)
	start()

func _pick_scene() -> PackedScene:
	if house_scenes.size() > 0:
		return house_scenes[randi() % house_scenes.size()]
	return house_scene

func spawn_house():
	if active_house != null and is_instance_valid(active_house):
		return

	var h = _pick_scene().instantiate()
	h.position = Vector2(spawn_x, spawn_y)

	var palet = h.get_node_or_null("PaletTarget")
	if palet:
		player.set_palet_target(palet)

	var atap = h.get_node_or_null("Atap/AtapTarget")
	if atap:
		player.set_atap_target(atap)

	get_parent().add_child(h)   # _ready() runs here

	# apply level speed AFTER _ready() so it isn't overwritten by the random default
	if h.has_method("set_speed"):
		h.set_speed(house_speed)

	active_house = h
	h.tree_exited.connect(func(): active_house = null)

func apply_config(cfg: Dictionary):
	house_speed = cfg.speed
	wait_time = randf_range(cfg.spawn_min, cfg.spawn_max)
