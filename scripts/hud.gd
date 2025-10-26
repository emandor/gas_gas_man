extends CanvasLayer

@onready var score_label = $MarginContainer/VBoxContainer/ScoreLabel
@onready var target_label = $MarginContainer/VBoxContainer/TargetLabel
@onready var timer_label = $CenterContainer/HBoxContainer/TimerLabel

signal game_finished(score: int, target: int, time: int, thrown_count: int)

var initial_time := 60
var score := 0
var target_score := 5
var time := initial_time
var timer: Timer = null
var thrown_count := 0

func _format_time(t: int) -> String:
	var minutes = int(t / 60)
	var seconds = int(t % 60)
	return "%02d:%02d" % [minutes, seconds]

func _ready():
	
	timer_label.text = _format_time(time)
	timer = Timer.new()
	timer.wait_time = 1.0
	timer.one_shot = false
	timer.timeout.connect(_on_timer_tick)
	add_child(timer)
	thrown_count = 0
	update_labels()

func start_timer():
	time = initial_time
	timer_label.text = _format_time(time)
	timer.start()

func stop_timer():
	if timer and timer.is_stopped() == false:
		timer.stop()

func reset():
	score = 0
	time = initial_time
	thrown_count = 0
	update_labels()
	timer_label.text = _format_time(time)
	stop_timer()

func add_score():
	score += 1
	update_labels()
	if score >= target_score:
		show_finish()

func update_labels():
	score_label.text = "Score: %d" % score
	target_label.text = "Target: %d" % target_score

func _on_timer_tick():
	time -= 1
	timer_label.text = _format_time(time)

	if time <= 0:
		timer.stop()
		show_finish()

func show_finish():
	emit_signal("game_finished", score, target_score, initial_time, thrown_count)
	reset()

func add_thrown():
	thrown_count += 1
