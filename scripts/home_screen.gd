extends CanvasLayer

signal start_pressed

@onready var start_button = $Control/TextureButton
@onready var click_sound = $Control/clicked

func _ready():
	if start_button:
		start_button.pressed.connect(_on_button_pressed)
	else:
		push_warning("HomeScreen: start button not found")

func _on_button_pressed():
	click_sound.play()
	click_sound.seek(0.6)
	start_pressed.emit()
