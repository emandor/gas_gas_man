extends Node

@export var bgm: AudioStream
var _player_bgm: AudioStreamPlayer

func _ready():
	_player_bgm = AudioStreamPlayer.new()
	add_child(_player_bgm)
	_player_bgm.bus = "Music"

func play_bgm():
	if bgm:
		_player_bgm.stream = bgm
		_player_bgm.play()

func stop_bgm():
	_player_bgm.stop()

func toggle_mute():
	_player_bgm.stream_paused = not _player_bgm.stream_paused

