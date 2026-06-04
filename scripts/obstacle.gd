extends Node2D

@export var speed := 200.0

func _ready():
	add_to_group("obstacle")
	if has_node("BlockArea"):
		$BlockArea.body_entered.connect(_on_body_entered)

func _process(delta):
	position.x -= speed * delta
	if position.x < -300:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("package"):
		body.deflect()
		var cam = get_tree().get_first_node_in_group("camera")
		if cam:
			cam.shake(0.1, 6.0)
