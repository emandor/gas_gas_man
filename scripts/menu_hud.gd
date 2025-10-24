extends CanvasLayer

signal game_control

@onready var audio_btn = $HBoxContainer/AudioButton
@onready var exit_btn = $HBoxContainer/ExitButton


func _ready():
	audio_btn.pressed.connect(_on_audio_button_pressed)
	exit_btn.pressed.connect(_on_exit_button_pressed)

func _on_audio_button_pressed():
	game_control.emit("toggle_audio")
	print("Audio button pressed")  # debug log

func _on_exit_button_pressed():
	game_control.emit("exit_game")
	print("Exit button pressed")  # debug log
