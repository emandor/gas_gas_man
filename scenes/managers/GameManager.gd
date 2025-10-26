extends Node

@onready var spawner    = $"../HouseSpawner"
@onready var player     = $"../PlayerMotor"
@onready var hud        = $"../HUD"
@onready var background = $"../Background"

func _ready():
	GameState.connect("game_started", self._on_game_started)
	GameState.connect("game_paused", self._on_game_paused)
	GameState.connect("game_resumed", self._on_game_resumed)
	GameState.connect("game_over", self._on_game_over)

	hud.connect("request_start", self._on_request_start)
	hud.connect("request_quit",  self._on_request_quit)
	hud.connect("request_restart", self._on_request_restart)

	# contoh: sinyal dari spawner/house saat delivered
	spawner.connect("house_delivered", self._on_house_delivered)

func _on_request_start():
	GameState.start_game()

func _on_request_quit():
	SceneLoader.goto(Constants.SCENE_MAIN_MENU)

func _on_request_restart():
	SceneLoader.goto(Constants.SCENE_GAME)

func _on_game_started():
	AudioManager.play_bgm()
	background.is_scrolling = true
	player.active = true
	spawner.start()

	hud.show_hud()
	hud.update_score(GameState.score)

func _on_game_paused():
	get_tree().paused = true
	hud.show_pause(true)

func _on_game_resumed():
	get_tree().paused = false
	hud.show_pause(false)

func _on_game_over():
	spawner.stop()
	player.active = false
	background.is_scrolling = false
	hud.show_result(GameState.score)
	AudioManager.stop_bgm()

func _on_house_delivered(success: bool):
	if success:
		GameState.score += Constants.SCORE_DELIVERY_SUCCESS
	else:
		GameState.score += Constants.SCORE_DELIVERY_FAIL
	hud.update_score(GameState.score)
