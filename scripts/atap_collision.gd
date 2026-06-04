extends Area2D

signal package_hit(success: bool)

func _ready():
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body.name == "Package" or body.is_in_group("package"):
		emit_signal("package_hit", false)
		_spawn_explosion()

func _spawn_explosion():
	var cam = get_tree().get_first_node_in_group("camera")
	if cam:
		cam.shake(0.25, 14.0)
	var fx_scene = load("res://scenes/player/PackageExplosion.tscn")
	if fx_scene:
		var fx = fx_scene.instantiate()
		get_tree().current_scene.add_child(fx)
		fx.play_at(global_position, false)
