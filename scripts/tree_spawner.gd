extends Timer

@export var tree_scene: PackedScene = preload("res://scenes/environment/Tree.tscn")

@export var spawn_x := 1400.0
@export var spawn_y_min := 300.0
@export var spawn_y_max := 350.0
@export var tree_speed := 180.0

@export var min_interval := 0.8    # waktu spawn minimal
@export var max_interval := 2.0    # waktu spawn maksimal

@export var max_trees_on_screen := 3

var active_trees: Array = []

func _ready():
	autostart = false
	wait_time = randf_range(min_interval, max_interval)
	timeout.connect(_on_timeout)
	start()

func _on_timeout():
	spawn_tree()
	wait_time = randf_range(min_interval, max_interval)
	start() # restart timer agar loop jalan terus

func spawn_tree():
	# bersihkan yang sudah dihapus
	active_trees = active_trees.filter(func(t):
		return is_instance_valid(t)
	)

	# batasi jumlah pohon aktif di layar
	if active_trees.size() >= max_trees_on_screen:
		return

	var tree = tree_scene.instantiate()
	var rand_y = randf_range(spawn_y_min, spawn_y_max)
	var rand_x = randf_range(1280, 3280)
	tree.position = Vector2(spawn_x, rand_y)

	if tree.has_method("set_speed"):
		tree.set_speed(tree_speed)

	get_parent().add_child(tree)
	active_trees.append(tree)
