extends Node2D

@onready var player = $PlayerMotor
@onready var background = $Background
@onready var home_screen = $HomeScreen
@onready var power_bar = $PowerBar
@onready var house_timer = $HouseSpawner
@onready var hud = $HUD
@onready var game_control = $MenuControl

@export var house_scene: PackedScene = preload("res://scenes/environment/House.tscn")

func _ready():
	# default: diam dan layar utama
	background.is_scrolling = false
	game_control.visible = false
	player.set_process(false)
	hud.visible = false
	home_screen.start_pressed.connect(_on_start_pressed)
	hud.game_finished.connect(_on_game_finished)
	game_control.game_control.connect(_on_game_control)

func _on_game_control(action: String):
	match action:
		"toggle_audio":
			print("🔊 Toggling audio...")
			# logika toggle audio di sini
		"exit_game":
			print("🚪 Exiting game...")
			reset_game()
		_:
			print("❓ Unknown action:", action)

func _on_start_pressed():
	print("🎮 Start Game!")
	start_game()
	hud.visible = true
	game_control.visible = true
	hud.reset()

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
	# hapus semua rumah
	for child in get_children():
		if child.name.begins_with("House"):
			child.queue_free()
	house_timer.stop()
	background.is_scrolling = false
	player.set_process(false)
	home_screen.show()
	hud.visible = false

func _on_game_finished():
	reset_game()
