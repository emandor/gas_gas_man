extends Timer

@export var house_scene: PackedScene = preload("res://scenes/environment/House.tscn")
@export var player_path: NodePath

@onready var player: Node = get_node(player_path)

@export var spawn_x := 1400.0
@export var spawn_y := 470.0
@export var house_speed := 180.0

var active_house: Node2D = null

func _ready():
	wait_time = 0
	autostart = false
	timeout.connect(_on_timeout)

func _on_timeout():
	spawn_house()        

func spawn_house():
	if active_house != null and is_instance_valid(active_house):
		return

	var h = house_scene.instantiate()
	h.position = Vector2(spawn_x, spawn_y)

	# get PaletTarget 
	var palet = h.get_node_or_null("PaletTarget")
	if palet:
		player.set_palet_target(palet)

	
	if h.has_method("set_speed"):
		h.set_speed(house_speed)

	get_parent().add_child(h)
	active_house = h
