extends CanvasLayer

var _blink_timer := 0.0

func _ready():
	visible = false

func show_if_needed():
	if not SaveData.tutorial_seen:
		visible = true

func _process(delta):
	if not visible:
		return
	_blink_timer += delta
	if has_node("BG/VBox/LabelTap"):
		$BG/VBox/LabelTap.modulate.a = 0.5 + 0.5 * sin(_blink_timer * 3.0)

func _input(event):
	if not visible:
		return
	var is_tap = event is InputEventScreenTouch and event.pressed
	var is_key = event.is_action_pressed("throw_package")
	if is_tap or is_key:
		_dismiss()

func _dismiss():
	SaveData.tutorial_seen = true
	SaveData.save()
	var t = create_tween()
	t.tween_property($BG, "modulate:a", 0.0, 0.35)
	t.tween_callback(func(): visible = false; $BG.modulate.a = 1.0)
