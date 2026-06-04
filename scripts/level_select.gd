extends CanvasLayer

signal level_selected(index: int)

const C_ORANGE := Color(0.957, 0.659, 0.145)
const C_CREAM := Color(1.0, 0.973, 0.906)
const C_BROWN := Color(0.173, 0.094, 0.063)
const C_CREAM_DARK := Color(0.91, 0.851, 0.722)
const C_GOLD := Color(1.0, 0.843, 0.0)
const C_GREY := Color(0.42, 0.447, 0.502)
const STAR_FULL := preload("res://assets/sprites/ui/star_full.png")
const STAR_EMPTY := preload("res://assets/sprites/ui/star_empty.png")

func _ready():
	visible = false
	if has_node("Panel/VBox/ButtonClose"):
		$Panel/VBox/ButtonClose.pressed.connect(func(): visible = false)

func show_screen():
	visible = true
	_build_buttons()

func _make_card_style(border: Color, bg_top := Color(0.24, 0.13, 0.06)) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg_top
	sb.border_color = border
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(14)
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 14
	sb.content_margin_bottom = 14
	return sb

func _build_buttons():
	if not has_node("Panel/VBox/LevelGrid"):
		return
	var grid = $Panel/VBox/LevelGrid
	for child in grid.get_children():
		child.queue_free()

	for i in Constants.LEVELS.size():
		var lvl = Constants.LEVELS[i]
		var locked = i >= SaveData.current_level
		var is_current = (i == SaveData.current_level - 1)
		var stars = SaveData.saved_stars[i] if i < SaveData.saved_stars.size() else 0

		var card := Button.new()
		card.custom_minimum_size = Vector2(184, 168)
		card.focus_mode = Control.FOCUS_NONE
		card.disabled = locked

		# dark card look (distinct from the orange action buttons)
		var border := C_ORANGE if is_current else C_CREAM_DARK
		var style := _make_card_style(border)
		card.add_theme_stylebox_override("normal", style)
		card.add_theme_stylebox_override("hover", _make_card_style(C_ORANGE, Color(0.3, 0.17, 0.08)))
		card.add_theme_stylebox_override("pressed", _make_card_style(C_ORANGE, Color(0.2, 0.11, 0.05)))
		card.add_theme_stylebox_override("disabled", _make_card_style(Color(0.3, 0.3, 0.3), Color(0.15, 0.12, 0.1)))

		var vbox := VBoxContainer.new()
		vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.add_theme_constant_override("separation", 6)
		card.add_child(vbox)

		if locked:
			var lock := Label.new()
			lock.text = "🔒"
			lock.add_theme_font_size_override("font_size", 56)
			lock.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lock.mouse_filter = Control.MOUSE_FILTER_IGNORE
			vbox.add_child(lock)
			var ltarget := Label.new()
			ltarget.text = "%d 📦" % lvl.target
			ltarget.add_theme_font_size_override("font_size", 18)
			ltarget.add_theme_color_override("font_color", C_CREAM_DARK)
			ltarget.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			ltarget.mouse_filter = Control.MOUSE_FILTER_IGNORE
			vbox.add_child(ltarget)
		else:
			var num := Label.new()
			num.text = "%d" % lvl.id
			num.add_theme_font_size_override("font_size", 64)
			num.add_theme_color_override("font_color", C_ORANGE)
			num.add_theme_color_override("font_outline_color", C_BROWN)
			num.add_theme_constant_override("outline_size", 6)
			num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			num.mouse_filter = Control.MOUSE_FILTER_IGNORE
			vbox.add_child(num)

			var stars_row := HBoxContainer.new()
			stars_row.alignment = BoxContainer.ALIGNMENT_CENTER
			stars_row.add_theme_constant_override("separation", 4)
			stars_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
			for s in range(3):
				var star := TextureRect.new()
				star.texture = STAR_FULL if s < stars else STAR_EMPTY
				star.custom_minimum_size = Vector2(28, 28)
				star.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				star.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				star.mouse_filter = Control.MOUSE_FILTER_IGNORE
				stars_row.add_child(star)
			vbox.add_child(stars_row)

			var target := Label.new()
			target.text = "%d 📦" % lvl.target
			target.add_theme_font_size_override("font_size", 18)
			target.add_theme_color_override("font_color", C_CREAM)
			target.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			target.mouse_filter = Control.MOUSE_FILTER_IGNORE
			vbox.add_child(target)

		card.pressed.connect(_on_level_pressed.bind(i))
		grid.add_child(card)

func _on_level_pressed(index: int):
	AudioManager.play_sfx("button")
	visible = false
	emit_signal("level_selected", index)
