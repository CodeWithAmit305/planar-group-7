extends PanelContainer
class_name KeypadPuzzle

signal attempt_submitted(text: String)
signal closed

var title_label: Label
var subtitle_label: Label
var clue_label: Label
var status_label: Label
var line_edit: LineEdit


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	custom_minimum_size = Vector2(700, 520)
	add_theme_stylebox_override("panel", _panel_style(Color(0.07, 0.10, 0.15, 0.96), Color(1.0, 0.70, 0.38, 0.34)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 22)
	add_child(margin)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 12)
	margin.add_child(layout)

	title_label = Label.new()
	title_label.add_theme_font_size_override("font_size", 28)
	title_label.modulate = Color("FFFFFF")
	layout.add_child(title_label)

	subtitle_label = Label.new()
	subtitle_label.modulate = Color(0.84, 0.91, 1.0, 0.82)
	layout.add_child(subtitle_label)

	line_edit = LineEdit.new()
	line_edit.placeholder_text = "ENTER PASSWORD"
	line_edit.max_length = 8
	line_edit.add_theme_font_size_override("font_size", 24)
	line_edit.text_submitted.connect(_on_text_submitted)
	layout.add_child(line_edit)

	clue_label = Label.new()
	clue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	clue_label.modulate = Color(1.0, 0.83, 0.62, 0.88)
	layout.add_child(clue_label)

	var keypad := GridContainer.new()
	keypad.columns = 6
	keypad.add_theme_constant_override("h_separation", 10)
	keypad.add_theme_constant_override("v_separation", 10)
	layout.add_child(keypad)

	var keys := [
		"A", "B", "C", "D", "E", "F",
		"G", "H", "I", "J", "K", "L",
		"M", "N", "O", "P", "Q", "R",
		"S", "T", "U", "V", "W", "X",
		"Y", "Z", "0", "1", "2", "3",
		"4", "5", "6", "7", "8", "9",
	]

	for key in keys:
		var button := Button.new()
		button.text = key
		button.custom_minimum_size = Vector2(86, 42)
		button.add_theme_stylebox_override("normal", _button_style(Color("FFB24B"), 0.16))
		button.add_theme_stylebox_override("hover", _button_style(Color("FFB24B"), 0.26))
		button.add_theme_stylebox_override("pressed", _button_style(Color("FFB24B"), 0.38))
		button.pressed.connect(_append_character.bind(key))
		keypad.add_child(button)

	status_label = Label.new()
	status_label.text = "Enter the inferred password."
	status_label.modulate = Color(0.82, 0.92, 1.0, 0.78)
	layout.add_child(status_label)

	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 12)
	layout.add_child(actions)

	for pair in [["Backspace", "_on_backspace_pressed"], ["Clear", "_on_clear_pressed"], ["Enter", "_on_enter_pressed"], ["Close", "_on_close_pressed"]]:
		var button := Button.new()
		button.text = pair[0]
		button.custom_minimum_size = Vector2(154, 44)
		button.add_theme_stylebox_override("normal", _button_style(Color("6FF8FF"), 0.18))
		button.add_theme_stylebox_override("hover", _button_style(Color("6FF8FF"), 0.28))
		button.add_theme_stylebox_override("pressed", _button_style(Color("6FF8FF"), 0.4))
		button.connect("pressed", Callable(self, pair[1]))
		actions.add_child(button)


func open_puzzle(title_text: String, subtitle_text: String, clue_lines: Array) -> void:
	title_label.text = title_text
	subtitle_label.text = subtitle_text
	clue_label.text = "Archived clues:\n" + ("\n".join(clue_lines) if not clue_lines.is_empty() else "No clues archived yet.")
	status_label.text = "Enter the inferred password."
	status_label.modulate = Color(0.82, 0.92, 1.0, 0.78)
	line_edit.text = ""
	visible = true
	line_edit.grab_focus()


func show_error(message: String) -> void:
	status_label.text = message
	status_label.modulate = Color(1.0, 0.45, 0.45, 1.0)


func _append_character(character: String) -> void:
	if line_edit.text.length() >= line_edit.max_length:
		return
	AudioManager.play_sfx("interact")
	line_edit.text += character


func _on_text_submitted(_new_text: String) -> void:
	_on_enter_pressed()


func _on_backspace_pressed() -> void:
	if line_edit.text.is_empty():
		return
	AudioManager.play_sfx("interact")
	line_edit.text = line_edit.text.left(line_edit.text.length() - 1)


func _on_clear_pressed() -> void:
	AudioManager.play_sfx("interact")
	line_edit.text = ""


func _on_enter_pressed() -> void:
	emit_signal("attempt_submitted", line_edit.text)


func _on_close_pressed() -> void:
	AudioManager.play_sfx("interact")
	emit_signal("closed")


func _panel_style(bg: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 18
	style.corner_radius_top_right = 18
	style.corner_radius_bottom_right = 18
	style.corner_radius_bottom_left = 18
	return style


func _button_style(accent: Color, alpha: float) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(accent.r, accent.g, accent.b, alpha)
	style.border_color = accent
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_right = 12
	style.corner_radius_bottom_left = 12
	return style
