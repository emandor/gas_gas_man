extends Node

enum State { IDLE = 0, PLAYING = 1, PAUSED = 2, GAME_OVER = 3 }

# Legacy alias so existing callers using GameState.STATE.PLAYING keep working
var STATE = { "IDLE": 0, "PLAYING": 1, "PAUSED": 2, "GAME_OVER": 3 }

var score: int = 0
var deliveries: int = 0
var lives: int = 3
var state: int = State.IDLE
var thrown_count: int = 0
var combo: int = 0
var high_score: int = 0

signal game_started
signal game_paused
signal game_resumed
signal game_over
signal score_changed(new_score: int, combo: int)
signal combo_updated(combo: int)

func start_game():
	score = 0
	deliveries = 0
	lives = 3
	thrown_count = 0
	combo = 0
	state = State.PLAYING
	emit_signal("game_started")

func pause_game():
	if state == State.PLAYING:
		state = State.PAUSED
		emit_signal("game_paused")

func resume_game():
	if state == State.PAUSED:
		state = State.PLAYING
		emit_signal("game_resumed")

func end_game():
	if state != State.GAME_OVER:
		state = State.GAME_OVER
		emit_signal("game_over")

func add_delivery_success(multiplier: float = 1.0):
	combo += 1
	deliveries += 1
	score += int(Constants.SCORE_DELIVERY_SUCCESS * max(1, combo) * multiplier)
	emit_signal("score_changed", score, combo)
	emit_signal("combo_updated", combo)

func add_delivery_fail():
	combo = 0
	score = max(0, score + Constants.SCORE_DELIVERY_FAIL)
	emit_signal("score_changed", score, 0)
	emit_signal("combo_updated", 0)

func add_thrown():
	thrown_count += 1
