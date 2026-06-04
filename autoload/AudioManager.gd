extends Node

@export var bgm: AudioStream

var _player_bgm: AudioStreamPlayer
var _sfx_pool: Array[AudioStreamPlayer] = []

const SFX_PATHS = {
	"hit":         "res://assets/sfx/package_hit.wav",
	"miss":        "res://assets/sfx/throw_away.wav",
	"throw":       "res://assets/sfx/throw.wav",
	"button":      "res://assets/sfx/button_click.wav",
	"combo_hit_2": "res://assets/sfx/combo_hit_2.wav",
	"combo_hit_3": "res://assets/sfx/combo_hit_3.wav",
	"combo_hit_4": "res://assets/sfx/combo_hit_4.wav",
	"combo_hit_5": "res://assets/sfx/combo_hit_5.wav",
	"combo_break": "res://assets/sfx/combo_break.wav",
}
var _sfx_streams: Dictionary = {}

func _ready():
	_player_bgm = AudioStreamPlayer.new()
	add_child(_player_bgm)
	_player_bgm.bus = "Music"

	for key in SFX_PATHS:
		var stream = load(SFX_PATHS[key])
		if stream:
			_sfx_streams[key] = stream

	for i in 6:
		var p = AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_sfx_pool.append(p)

func play_bgm():
	if bgm:
		_player_bgm.stream = bgm
		_player_bgm.play()

func stop_bgm():
	_player_bgm.stop()

func set_music_enabled(enabled: bool):
	if enabled:
		play_bgm()
	else:
		stop_bgm()

func toggle_mute():
	_player_bgm.stream_paused = not _player_bgm.stream_paused

func play_sfx(key: String, pitch: float = 1.0):
	if not SaveData.sfx_enabled:
		return
	if not _sfx_streams.has(key):
		return
	for p in _sfx_pool:
		if not p.playing:
			p.stream = _sfx_streams[key]
			p.pitch_scale = pitch
			p.play()
			return

func play_combo_sfx(combo: int):
	if combo == 0:
		play_sfx("combo_break")
		return
	var key = "combo_hit_%d" % clamp(combo, 2, 5) if combo >= 2 else "hit"
	play_sfx(key)
