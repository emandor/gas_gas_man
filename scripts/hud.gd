extends CanvasLayer

@onready var score_label = $MarginContainer/VBoxContainer/ScoreLabel
@onready var target_label = $MarginContainer/VBoxContainer/TargetLabel
#@onready var finish_screen = $FinishScreen

signal game_finished

var score := 0
var target_score := 5   # bisa diubah nanti dari Game.gd

func _ready():
	update_labels()
	#finish_screen.visible = false

func add_score():
	score += 1
	update_labels()
	
	if score >= target_score:
		show_finish()

func update_labels():
	score_label.text = "📦 Score: %d" % score
	target_label.text = "  🎯 Target: %d" % target_score

func show_finish():
	#finish_screen.visible = true
	emit_signal("game_finished")

func reset():
	score = 0
	update_labels()
	#finish_screen.visible = false
