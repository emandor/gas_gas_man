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
@onready var panel_blur = $PanelBlur

@export var house_scene: PackedScene = preload("res://scenes/environment/House.tscn")

var sound_mute = false

func _ready():
	$Confetti.visible = false
	result_board.visible = false
	panel_blur.visible = false
	background.is_scrolling = false
	game_control.visible = true
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
			if $HomeScreen.visible:
				get_tree().quit()
			else:
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
	player.start_game()
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
	player.reset_player()
	background.is_scrolling = false
	game_control.visible = true
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
	if thrown_count == 0:
		accuration = 0
	show_result_screen(accuration, score, time, target)


func _on_button_ok_pressed():
	audio_result_btn_ok.play() 
	audio_result_btn_ok.seek(0.6)
	
	result_board.visible = false
	panel_blur.visible = false
	reset_game()

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

	# 🔥 Tentukan Tier Meme
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

	# Set teks dan broom
	label_status.text = tier_text
	label_status.add_theme_color_override("font_color", Color(tier_color))


	label_accuracy.text = "Akurasi: %d%%" % round(accuracy)
	label_score.text = "Skor: %d / %d" % [score, total_score]
	label_time.text = "Waktu: %d detik" % time

	# ✨ Reset visual sebelum animasi
	result_board.modulate = Color(1, 1, 1, 0)
	label_status.scale = Vector2(0.6, 0.6)
	label_accuracy.modulate = Color(1,1,1,0)
	label_score.modulate = Color(1,1,1,0)
	label_time.modulate = Color(1,1,1,0)

	# 🎬 Animasi Fancy
	var t = create_tween()

	# Fade-in Board
	t.tween_property(result_board, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_CUBIC)

	# Pop-in Title (Hero motion)
	t.tween_property(label_status, "scale", Vector2(1,1), 0.35).set_trans(Tween.TRANS_BACK)

	# Slight delay untuk detail (Stagger reveal)
	t.tween_interval(0.15)
	t.tween_property(label_accuracy, "modulate:a", 1.0, 0.25)
	t.tween_property(label_score, "modulate:a", 1.0, 0.25)
	t.tween_property(label_time, "modulate:a", 1.0, 0.25)
