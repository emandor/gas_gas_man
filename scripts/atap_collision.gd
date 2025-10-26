extends Area2D

signal package_hit(success: bool)

func _ready():
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body.name == "Package" or body.is_in_group("package"):
		emit_signal("package_hit", false)
   
