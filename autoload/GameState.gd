extends Node

# enum-like state
const STATE := { IDLE:0, PLAYING:1, PAUSED:2, GAME_OVER:3 }

var score:int = 0
var lives:int = 3
var state:int = STATE.IDLE

signal game_started
signal game_paused
signal game_resumed
signal game_over

func start_game():
	score = 0
	lives = 3
	state = STATE.PLAYING
	emit_signal("game_started")

func pause_game():
	if state == STATE.PLAYING:
		state = STATE.PAUSED
		emit_signal("game_paused")

func resume_game():
	if state == STATE.PAUSED:
		state = STATE.PLAYING
		emit_signal("game_resumed")

func end_game():
	if state != STATE.GAME_OVER:
		state = STATE.GAME_OVER
		emit_signal("game_over")

