extends Node

# Scene paths
const SCENE_MAIN_MENU  := "res://scenes/main_menu/MainMenu.tscn"
const SCENE_GAME       := "res://scenes/levels/Game.tscn"
const SCENE_HOME       := "res://scenes/main_menu/HomeScreen.tscn"
const SCENE_LEVEL_SELECT := "res://scenes/ui/LevelSelect.tscn"

# Input actions
const INPUT_THROW := "throw_gas"
const INPUT_PAUSE := "pause_game"

# Groups
const GROUP_PLAYER  := "player"
const GROUP_HOUSE   := "house"
const GROUP_PACKAGE := "package"
const GROUP_CAMERA  := "camera"
const GROUP_HUD     := "hud"

# Gameplay config
const SCROLL_SPEED         := 150.0
const HOUSE_SPAWN_INTERVAL := 2.0
const SCORE_DELIVERY_SUCCESS := 10
const SCORE_DELIVERY_FAIL    := -5

# Level definitions: target deliveries, time (s), scroll speed, spawn interval range
const LEVELS: Array = [
	{ "id":1, "target":5,  "time":60, "speed":150.0, "spawn_min":2.5, "spawn_max":4.0 },
	{ "id":2, "target":7,  "time":60, "speed":180.0, "spawn_min":2.0, "spawn_max":3.2 },
	{ "id":3, "target":10, "time":60, "speed":210.0, "spawn_min":1.5, "spawn_max":2.5 },
	{ "id":4, "target":12, "time":55, "speed":240.0, "spawn_min":1.2, "spawn_max":2.0 },
	{ "id":5, "target":15, "time":50, "speed":270.0, "spawn_min":1.0, "spawn_max":1.7 },
]
