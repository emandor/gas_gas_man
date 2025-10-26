extends CanvasLayer

signal game_control

@onready var audio_btn = $HBoxContainer/AudioButton
@onready var exit_btn = $HBoxContainer/ExitButton
@onready var click_sound = $clicked

# TODO change proper should be global
var state_audio = true

func _ready():
	audio_btn.pressed.connect(_on_audio_button_pressed)
	exit_btn.pressed.connect(_on_exit_button_pressed)
	state_audio = true

func _on_audio_button_pressed():
	click_sound.play()
	click_sound.seek(0.6)
	game_control.emit("toggle_audio")
	state_audio = !state_audio
	_update_audio_button_icon()
	print("Audio button pressed")  # debug log

func _on_exit_button_pressed():
	click_sound.play()
	click_sound.seek(0.6)
	game_control.emit("exit_game")
	print("Exit button pressed")  # debug log


func _update_audio_button_icon():
	if state_audio:
		audio_btn.texture_normal = preload("res://assets/sprites/ui/sound.png")
	else:
		audio_btn.texture_normal = preload("res://assets/sprites/ui/mute.png")
