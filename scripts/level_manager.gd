extends Node

signal level_started(config: Dictionary)
signal level_completed(level: int, score: int, stars: int)
signal level_failed(level: int, score: int)

var current_index: int = 0

func _ready():
	current_index = clamp(SaveData.current_level - 1, 0, Constants.LEVELS.size() - 1)

func get_config() -> Dictionary:
	return Constants.LEVELS[clamp(current_index, 0, Constants.LEVELS.size() - 1)]

func start_level(index: int):
	current_index = clamp(index, 0, Constants.LEVELS.size() - 1)
	SaveData.current_level = current_index + 1
	emit_signal("level_started", get_config())

func complete(score: int):
	var stars = _calc_stars(score, get_config().target)
	SaveData.saved_stars[current_index] = max(SaveData.saved_stars[current_index], stars)
	SaveData.save()
	emit_signal("level_completed", current_index + 1, score, stars)
	current_index = min(current_index + 1, Constants.LEVELS.size() - 1)

func fail(score: int):
	emit_signal("level_failed", current_index + 1, score)

func has_next_level() -> bool:
	return current_index < Constants.LEVELS.size() - 1

func _calc_stars(score: int, target: int) -> int:
	var pct = float(score) / float(target)
	if pct >= 1.0:
		return 3
	elif pct >= 0.7:
		return 2
	else:
		return 1
