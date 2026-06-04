extends CanvasLayer

func _ready():
	visible = false
	_refresh_toggles()
	if has_node("Panel/VBox/MusicToggle"):
		$Panel/VBox/MusicToggle.toggled.connect(func(v):
			SaveData.music_enabled = v
			SaveData.save()
			AudioManager.set_music_enabled(v)
		)
	if has_node("Panel/VBox/SFXToggle"):
		$Panel/VBox/SFXToggle.toggled.connect(func(v):
			SaveData.sfx_enabled = v
			SaveData.save()
		)
	if has_node("Panel/VBox/ButtonClose"):
		$Panel/VBox/ButtonClose.pressed.connect(func(): visible = false)

func show_screen():
	_refresh_toggles()
	visible = true

func _refresh_toggles():
	if has_node("Panel/VBox/MusicToggle"):
		$Panel/VBox/MusicToggle.set_pressed_no_signal(SaveData.music_enabled)
	if has_node("Panel/VBox/SFXToggle"):
		$Panel/VBox/SFXToggle.set_pressed_no_signal(SaveData.sfx_enabled)
