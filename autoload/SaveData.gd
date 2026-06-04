extends Node

const SAVE_PATH = "user://save.cfg"

var high_score: int = 0
var sfx_enabled: bool = true
var music_enabled: bool = true
var current_level: int = 1
var tutorial_seen: bool = false
var saved_stars: Array = [0, 0, 0, 0, 0]

func _ready():
	load_data()

func save():
	var cfg = ConfigFile.new()
	cfg.set_value("game", "high_score", high_score)
	cfg.set_value("game", "current_level", current_level)
	cfg.set_value("game", "stars", saved_stars)
	cfg.set_value("settings", "sfx_enabled", sfx_enabled)
	cfg.set_value("settings", "music_enabled", music_enabled)
	cfg.set_value("settings", "tutorial_seen", tutorial_seen)
	cfg.save(SAVE_PATH)

func load_data():
	var cfg = ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	high_score = cfg.get_value("game", "high_score", 0)
	current_level = cfg.get_value("game", "current_level", 1)
	saved_stars = cfg.get_value("game", "stars", [0, 0, 0, 0, 0])
	sfx_enabled = cfg.get_value("settings", "sfx_enabled", true)
	music_enabled = cfg.get_value("settings", "music_enabled", true)
	tutorial_seen = cfg.get_value("settings", "tutorial_seen", false)
