extends Node2D

@onready var player = $PlayerMotor
@onready var background = $Background
@onready var home_screen = $HomeScreen
@onready var power_bar = $PowerBar
@onready var house_timer = $HouseSpawner
@onready var hud = $HUD
@onready var game_control = $MenuControl
@onready var bgm = $BGMPlayer
@onready var result_btn_ok = $ResultBoard/ButtonOK
@onready var audio_result_btn_ok = $ResultBoard/ButtonOkClicked
@onready var result_board = $ResultBoard

@export var house_scene: PackedScene = preload("res://scenes/environment/House.tscn")

var sound_mute = false

func _ready():
	result_board.visible = false
	background.is_scrolling = false
	game_control.visible = false
	player.set_process(false)	
	hud.visible = false
	home_screen.start_pressed.connect(_on_start_pressed)
	hud.game_finished.connect(_on_game_finished)
	game_control.game_control.connect(_on_game_control)
	result_btn_ok.pressed.connect(_on_button_ok_pressed)

func _on_game_control(action: String):
	match action:
		"toggle_audio":
			print("🔊 Toggling audio...")
			if sound_mute:
				sound_mute = false
				bgm.play_bgm()
			else:
				sound_mute = true
				bgm.stop_bgm()
			# logika toggle audio di sini
		"exit_game":
			print("🚪 Exiting game...")
			reset_game()
		_:
			print("❓ Unknown action:", action)

func _on_start_pressed():
	print("🎮 Start Game!")
	hud.start_timer()
	start_game()
	hud.visible = true
	game_control.visible = true

func start_game():
	background.is_scrolling = true
	player.set_process(true)
	home_screen.hide()

	var spawner = $HouseSpawner
	spawner.start()

func spawn_house():
	var h = house_scene.instantiate()
	add_child(h)

func reset_game():
	for child in get_children():
		print(child.name)
		if child.name == "HouseSpawner" || child.name == "TreeSpawner":
			child.stop()
		if child.name == "House"  || child.name == "Tree" || child.name == "Package":
			child.queue_free()
	house_timer.stop()
	background.is_scrolling = false
	game_control.visible = false
	player.set_process(false)
	home_screen.show()
	hud.visible = false
	get_tree().call_group("package", "queue_free")
	
func _on_game_finished(score, target, time, thrown_count):
	background.is_scrolling = false
	player.set_process(false)
	hud.visible = false
	game_control.visible = false
	var accuration = (float(score) / float(thrown_count)) * 100.0
	show_result_screen(accuration, score, time, target)


func _on_button_ok_pressed():
	result_board.visible = false
	audio_result_btn_ok.play()
	reset_game()


func show_result_screen(accuration: float, score: int, time: int, total_score: int):
	result_board.visible = true
	
	var label_accuration = $ResultBoard/VBoxContainer/LabelAccuration
	var label_score = $ResultBoard/VBoxContainer/LabelScore
	var label_time = $ResultBoard/VBoxContainer/LabelTime

	# isi label
	label_accuration.text = "Akurasi: " + str(round(accuration)) + "%"
	label_score.text = "Skor: " + str(score) + " / " + str(total_score)
	label_time.text = "Waktu: " + str(time) + " detik"

	# animasi lembut
	var tween = create_tween()
	result_board.modulate = Color(1, 1, 1, 0)
	tween.tween_property(result_board, "modulate:a", 1.0, 0.6).set_trans(Tween.TRANS_CUBIC)
