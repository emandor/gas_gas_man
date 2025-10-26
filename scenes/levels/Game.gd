extends Node2D

@onready var background = $Background
@onready var player     = $PlayerMotor
@onready var hud        = $HUD
@onready var spawner    = $HouseSpawner
@onready var manager    = $GameManager

func _ready():
	# default screen: idle
	background.set("is_scrolling", false)
	player.set("active", false)
	hud.show_main_menu()
	# start akan dipicu dari HUD/MainMenu → GameState.start_game()
