extends CanvasLayer

@onready var score_label = $TopBar/ScoreBlock/ScoreLabel
@onready var target_label = $TopBar/DeliveryBlock/TargetLabel
@onready var timer_label = $TopBar/TimerLabel

signal game_finished(score: int, target: int, time: int, thrown_count: int)

var initial_time := 60
var target_deliveries := 5
var time := initial_time
var timer: Timer = null
var _finished := false

func _format_time(t: int) -> String:
	var minutes = int(t / 60)
	var seconds = int(t % 60)
	return "%02d:%02d" % [minutes, seconds]

func _ready():
	add_to_group("hud")
	timer_label.text = _format_time(time)
	timer = Timer.new()
	timer.wait_time = 1.0
	timer.one_shot = false
	timer.timeout.connect(_on_timer_tick)
	add_child(timer)
	update_labels()
	GameState.score_changed.connect(_on_score_changed)
	GameState.combo_updated.connect(_on_combo_updated)

func _on_score_changed(_new_score: int, _combo: int):
	update_labels()
	if not _finished and GameState.deliveries >= target_deliveries:
		show_finish()

func _on_combo_updated(combo: int):
	if not has_node("ComboLabel"):
		return
	var lbl = $ComboLabel
	lbl.visible = combo >= 2
	if combo < 2:
		return
	lbl.text = "x%d COMBO!" % combo
	var t = create_tween()
	t.tween_property(lbl, "scale", Vector2(1.3, 1.3), 0.1).set_trans(Tween.TRANS_BACK)
	t.tween_property(lbl, "scale", Vector2(1.0, 1.0), 0.15)
	var color = Color(1.0, 0.2, 0.0) if combo >= 5 else (Color(1.0, 0.6, 0.0) if combo >= 3 else Color(1.0, 1.0, 0.0))
	lbl.add_theme_color_override("font_color", color)

func start_timer():
	_finished = false
	var cfg = LevelManager.get_config()
	target_deliveries = cfg.target
	initial_time = cfg.time
	time = initial_time
	timer_label.text = _format_time(time)
	update_labels()
	timer.start()

func stop_timer():
	if timer and not timer.is_stopped():
		timer.stop()

func reset():
	_finished = false
	time = initial_time
	update_labels()
	timer_label.text = _format_time(time)
	stop_timer()

func update_labels():
	score_label.text = "%d" % GameState.score
	target_label.text = "%d / %d" % [GameState.deliveries, target_deliveries]

func _on_timer_tick():
	time -= 1
	timer_label.text = _format_time(time)
	if time <= 0:
		timer.stop()
		show_finish()

func show_finish():
	if _finished:
		return
	_finished = true
	stop_timer()
	var score = GameState.score
	var deliveries = GameState.deliveries
	if deliveries >= target_deliveries:
		LevelManager.complete(score)
	else:
		LevelManager.fail(score)
	emit_signal("game_finished", score, target_deliveries, initial_time - time, GameState.thrown_count)
	reset()
