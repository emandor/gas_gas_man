extends Node2D

@onready var player = $PlayerMotor
@onready var background = $Background
@onready var home_screen = $HomeScreen
@onready var power_bar = $PowerBar
@onready var house_spawner = $HouseSpawner
@onready var hud = $HUD
@onready var game_control = $MenuControl
@onready var bgm = $BGMPlayer
@onready var result_btn_retry = $ResultBoard/ResultButtons/ButtonRetry
@onready var result_btn_menu = $ResultBoard/ResultButtons/ButtonMenu
@onready var audio_result_btn_ok = $ResultBoard/ButtonOkClicked
@onready var result_board = $ResultBoard
@onready var panel_blur = $PanelBlur
@onready var level_select = $LevelSelect
@onready var settings_screen = $SettingsScreen
@onready var tutorial_overlay = $TutorialOverlay
@onready var obstacle_spawner = $ObstacleSpawner

@export var house_scene: PackedScene = preload("res://scenes/environment/House.tscn")

const SCORE_POPUP_SCENE = preload("res://scenes/ui/ScorePopup.tscn")
const PACKAGE_EXPLOSION_SCENE = preload("res://scenes/player/PackageExplosion.tscn")

func _ready():
	$Confetti.visible = false
	result_board.visible = false
	panel_blur.visible = false
	background.is_scrolling = false
	game_control.visible = true
	player.set_process(false)
	hud.visible = false

	home_screen.start_pressed.connect(_on_start_button_pressed)
	hud.game_finished.connect(_on_game_finished)
	game_control.game_control.connect(_on_game_control)
	result_btn_menu.pressed.connect(_on_result_menu_pressed)
	result_btn_retry.pressed.connect(_on_result_retry_pressed)
	GameState.score_changed.connect(_on_score_changed)
	GameState.combo_updated.connect(_on_combo_updated)
	LevelManager.level_started.connect(_on_level_started)
	level_select.level_selected.connect(_on_level_selected)

func _on_score_changed(_new_score: int, combo: int):
	var text: String
	var color: Color
	if combo == 0:
		text = "%d" % Constants.SCORE_DELIVERY_FAIL
		color = Color(1.0, 0.25, 0.25)
	else:
		var pts = Constants.SCORE_DELIVERY_SUCCESS * combo
		text = "+%d" % pts
		if combo >= 3:
			text += "  x%d!" % combo
		color = Color(1.0, 0.2, 0.0) if combo >= 5 else (Color(1.0, 0.6, 0.0) if combo >= 3 else Color(1.0, 1.0, 0.0))

	var popup = SCORE_POPUP_SCENE.instantiate()
	add_child(popup)
	popup.popup(text, color, player.global_position + Vector2(60, -80))

func _on_combo_updated(combo: int):
	AudioManager.play_combo_sfx(combo)

func _on_game_control(action: String):
	match action:
		"toggle_audio":
			settings_screen.show_screen()
		"exit_game":
			if home_screen.visible:
				get_tree().quit()
			else:
				reset_game()

func _on_level_started(cfg: Dictionary):
	background.set_speed(cfg.speed)
	house_spawner.apply_config(cfg)
	_configure_obstacle_spawner(cfg)

func _configure_obstacle_spawner(cfg: Dictionary):
	obstacle_spawner.stop()
	if not obstacle_spawner.timeout.is_connected(_on_obstacle_timeout):
		obstacle_spawner.timeout.connect(_on_obstacle_timeout)
	if LevelManager.current_index >= 2:
		obstacle_spawner.wait_time = randf_range(3.5, 6.0)
		obstacle_spawner.start()

func _on_obstacle_timeout():
	var obs = preload("res://scenes/environment/Obstacle.tscn").instantiate()
	obs.position = Vector2(1500, randf_range(460, 500))
	obs.speed = randf_range(180.0, 260.0)
	add_child(obs)
	obstacle_spawner.wait_time = randf_range(3.5, 6.0)
	obstacle_spawner.start()

# Home screen "PLAY" → show level select
func _on_start_button_pressed():
	level_select.show_screen()

# Level select picked a level
func _on_level_selected(index: int):
	LevelManager.start_level(index)
	GameState.start_game()
	hud.start_timer()
	start_game()
	hud.visible = true
	game_control.visible = true
	tutorial_overlay.show_if_needed()

func start_game():
	background.is_scrolling = true
	player.start_game()
	player.set_process(true)
	home_screen.hide()
	house_spawner.start()
	bgm.play_bgm()

func reset_game():
	get_tree().call_group("house", "queue_free")
	get_tree().call_group("package", "queue_free")
	house_spawner.stop()
	obstacle_spawner.stop()
	player.reset_player()
	background.is_scrolling = false
	game_control.visible = true
	player.set_process(false)
	home_screen.show()
	hud.visible = false
	bgm.stop_bgm()

func _on_game_finished(score, target, time, thrown_count):
	background.is_scrolling = false
	player.set_process(false)
	obstacle_spawner.stop()
	hud.visible = false
	game_control.visible = false

	var cam = get_tree().get_first_node_in_group("camera")
	if cam:
		cam.shake(0.4, 20.0)

	var accuration = (float(score) / float(thrown_count)) * 100.0 if thrown_count > 0 else 0.0
	show_result_screen(accuration, score, time, target)

	if score > SaveData.high_score:
		SaveData.high_score = score
		SaveData.save()

func _on_result_menu_pressed():
	audio_result_btn_ok.play()
	audio_result_btn_ok.seek(0.6)
	result_board.visible = false
	panel_blur.visible = false
	reset_game()

func _on_result_retry_pressed():
	audio_result_btn_ok.play()
	audio_result_btn_ok.seek(0.6)
	result_board.visible = false
	panel_blur.visible = false
	# restart the same level
	get_tree().call_group("house", "queue_free")
	get_tree().call_group("package", "queue_free")
	house_spawner.stop()
	obstacle_spawner.stop()
	player.reset_player()
	LevelManager.start_level(LevelManager.current_index)
	GameState.start_game()
	hud.start_timer()
	start_game()
	hud.visible = true
	game_control.visible = true

func show_result_screen(accuracy: float, score: int, time: int, total_score: int):
	result_board.visible = true
	panel_blur.visible = true
	hud.visible = false
	$Confetti.visible = true
	$Confetti.restart()

	var label_status = $ResultBoard/VBoxContainer/LabelStatus
	var label_accuracy = $ResultBoard/VBoxContainer/LabelAccuration
	var label_score = $ResultBoard/VBoxContainer/LabelScore
	var label_time = $ResultBoard/VBoxContainer/LabelTime

	var tier_text := ""
	var tier_color := "#868686"

	if accuracy >= 90:
		tier_text = "🤩🤩🤩 Kerennn Euyy 🤙🤙"
		tier_color = "709435"
	elif accuracy >= 75:
		tier_text = "😎🛵 \n Gas Dikit lagii "
		tier_color = "709435"
	elif accuracy >= 50:
		tier_text = "🤭🤭🤭 \n Mayann Lah... "
	elif accuracy >= 25:
		tier_text = "😬😬😬 \nJangan Kasih Kendor"
	else:
		tier_text = "🫠🫠🫠 \nLemess amaattt"

	label_status.text = tier_text
	label_status.add_theme_color_override("font_color", Color(tier_color))
	label_accuracy.text = "Akurasi: %d%%" % round(accuracy)
	label_score.text = "Skor: %d  |  Pengiriman: %d / %d" % [score, GameState.deliveries, total_score]
	label_time.text = "Waktu: %d detik" % time

	# stars by accuracy tier (3 ≥90, 2 ≥50, else 1)
	var star_count = 3 if accuracy >= 90 else (2 if accuracy >= 50 else 1)
	_set_result_stars(star_count)

	result_board.modulate = Color(1, 1, 1, 0)
	label_status.scale = Vector2(0.6, 0.6)
	label_accuracy.modulate = Color(1, 1, 1, 0)
	label_score.modulate = Color(1, 1, 1, 0)
	label_time.modulate = Color(1, 1, 1, 0)

	var t = create_tween()
	t.tween_property(result_board, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_CUBIC)
	t.tween_property(label_status, "scale", Vector2(1, 1), 0.35).set_trans(Tween.TRANS_BACK)
	t.tween_interval(0.15)
	t.tween_property(label_accuracy, "modulate:a", 1.0, 0.25)
	t.tween_property(label_score, "modulate:a", 1.0, 0.25)
	t.tween_property(label_time, "modulate:a", 1.0, 0.25)

const STAR_FULL = preload("res://assets/sprites/ui/star_full.png")
const STAR_EMPTY = preload("res://assets/sprites/ui/star_empty.png")

func _set_result_stars(count: int):
	for i in range(3):
		var star = get_node_or_null("ResultBoard/VBoxContainer/StarsRow/Star%d" % (i + 1))
		if star:
			star.texture = STAR_FULL if i < count else STAR_EMPTY
