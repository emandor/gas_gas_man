extends Node

@onready var player = $BGMPlayer_Sound

func _ready() -> void:
	player.volume_db = -20

func play_bgm():
	player.volume_db = -20

func stop_bgm():
	player.volume_db = -80
