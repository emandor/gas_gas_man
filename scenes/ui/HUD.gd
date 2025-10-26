extends CanvasLayer

signal request_start
signal request_quit
signal request_restart

@onready var score_label = $ScoreLabel
@onready var main_panel  = $MainPanel
@onready var pause_panel = $PausePanel
@onready var result_panel = $ResultPanel

func show_main_menu():
	main_panel.visible = true
	pause_panel.visible = false
	result_panel.visible = false

func show_hud():
	main_panel.visible = false
	pause_panel.visible = false
	result_panel.visible = false

func show_pause(v:bool):
	pause_panel.visible = v

func show_result(final_score:int):
	result_panel.visible = true
	result_panel.get_node("Score").text = str(final_score)

func update_score(v:int):
	score_label.text = str(v)

func _unhandled_input(event):
	if event.is_action_pressed(Constants.INPUT_PAUSE):
		if GameState.state == GameState.STATE.PLAYING:
			GameState.pause_game()
		elif GameState.state == GameState.STATE.PAUSED:
			GameState.resume_game()

# hooked to buttons
func _on_StartButton_pressed():   emit_signal("request_start")
func _on_QuitButton_pressed():    emit_signal("request_quit")
func _on_RestartButton_pressed(): emit_signal("request_restart")
