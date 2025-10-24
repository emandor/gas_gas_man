extends CanvasLayer

signal start_pressed

@onready var start_button = $Control/TextureButton

func _ready():
	print("HomeScreen ready!")
	if start_button:
		print("Button found:", start_button.name)
		start_button.pressed.connect(_on_button_pressed) # ← pastikan ini barisnya!
	else:
		print("Button not found!")

func _on_button_pressed():
	print("Button clicked!")  # debug log
	start_pressed.emit()
