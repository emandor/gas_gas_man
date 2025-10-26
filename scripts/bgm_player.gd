extends Node

@onready var player = $BGMPlayer_Sound

func _ready() -> void:
	player.volume_db = 0

func play_bgm():
	player.volume_db = 0

func stop_bgm():
	player.volume_db = -80
