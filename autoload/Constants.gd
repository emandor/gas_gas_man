extends Node

# Scene paths
const SCENE_MAIN_MENU := "res://scenes/main_menu/MainMenu.tscn"
const SCENE_GAME      := "res://scenes/levels/Game.tscn"

# Input actions
const INPUT_THROW := "throw_gas"
const INPUT_PAUSE := "pause_game"

# Groups
const GROUP_PLAYER := "player"
const GROUP_HOUSE  := "house"

# Gameplay config
const SCROLL_SPEED := 150.0
const HOUSE_SPAWN_INTERVAL := 2.0
const SCORE_DELIVERY_SUCCESS := 10
const SCORE_DELIVERY_FAIL    := -5
