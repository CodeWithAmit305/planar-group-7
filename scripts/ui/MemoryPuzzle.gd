extends PanelContainer
class_name MemoryPuzzle

signal attempt_submitted(sequence: Array)
signal closed

const BUTTON_COLORS := {
	"CYAN": Color("77F8FF"),
	"AMBER": Color("FFB54A"),
	"MAGENTA": Color("FF6ED5"),
	"LIME": Color("B3FF6E"),
}

var title_label: Label
var hint_label: Label
var status_label: Label
var selection_label: Label
var expected_length := 4
var current_sequence: Array[String] = []


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	custom_minimum_size = Vector2(560, 420)
	add_theme_stylebox_override("panel", _panel_style(Color(0.07, 0.11, 0.16, 0.96), Color(0.50, 0.98, 1.0, 0.36)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 20)
	add_child(margin)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 12)
	margin.add_child(layout)

	title_label = Label.new()
	title_label.text = "Memory Console"
	title_label.add_theme_font_size_override("font_size", 26)
	title_label.modulate = Color("E9FFFF")
	layout.add_child(title_label)

	hint_label = Label.new()
	hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint_label.modulate = Color(0.72, 0.88, 0.96, 0.88)
	layout.add_child(hint_label)

	selection_label = Label.new()
	selection_label.modulate = Color(1.0, 0.72, 0.35, 0.95)
	layout.add_child(selection_label)

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 14)
	layout.add_child(grid)

	for name in BUTTON_COLORS.keys():
		var button := Button.new()
		button.text = name
		button.custom_minimum_size = Vector2(220, 92)
		button.add_theme_font_size_override("font_size", 22)
		button.add_theme_stylebox_override("normal", _button_style(BUTTON_COLORS[name], 0.24))
		button.add_theme_stylebox_override("hover", _button_style(BUTTON_COLORS[name], 0.36))
		button.add_theme_stylebox_override("pressed", _button_style(BUTTON_COLORS[name], 0.54))
		button.pressed.connect(_on_color_pressed.bind(name))
		grid.add_child(button)

	status_label = Label.new()
	status_label.text = "Repeat the sequence."
	status_label.modulate = Color(0.82, 0.92, 1.0, 0.78)
	layout.add_child(status_label)

	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 12)
	layout.add_child(actions)

	for pair in [["Submit", "_on_submit_pressed"], ["Reset", "_on_reset_pressed"], ["Close", "_on_close_pressed"]]:
		var button := Button.new()
		button.text = pair[0]
		button.custom_minimum_size = Vector2(140, 46)
		button.add_theme_stylebox_override("normal", _button_style(Color("6FF8FF"), 0.18))
		button.add_theme_stylebox_override("hover", _button_style(Color("6FF8FF"), 0.28))
		button.add_theme_stylebox_override("pressed", _button_style(Color("6FF8FF"), 0.4))
		button.connect("pressed", Callable(self, pair[1]))
		actions.add_child(button)


func open_puzzle(sequence: Array, title_text: String, hint_text: String) -> void:
	expected_length = sequence.size()
	current_sequence.clear()
	title_label.text = title_text
	hint_label.text = hint_text
	status_label.text = "Repeat the sequence."
	status_label.modulate = Color(0.82, 0.92, 1.0, 0.78)
	_update_selection_label()
	visible = true


func show_error(message: String) -> void:
	status_label.text = message
	status_label.modulate = Color(1.0, 0.45, 0.45, 1.0)


func _on_color_pressed(color_name: String) -> void:
	if current_sequence.size() >= expected_length:
		return

	AudioManager.play_sfx("interact")
	current_sequence.append(color_name)
	status_label.text = "Sequence staged."
	status_label.modulate = Color(0.82, 0.92, 1.0, 0.78)
	_update_selection_label()


func _on_submit_pressed() -> void:
	emit_signal("attempt_submitted", current_sequence)


func _on_reset_pressed() -> void:
	AudioManager.play_sfx("interact")
	current_sequence.clear()
	status_label.text = "Sequence cleared."
	status_label.modulate = Color(0.82, 0.92, 1.0, 0.78)
	_update_selection_label()


func _on_close_pressed() -> void:
	AudioManager.play_sfx("interact")
	emit_signal("closed")


func _update_selection_label() -> void:
	var staged := ", ".join(current_sequence)
	if staged.is_empty():
		staged = "No colors staged"
	selection_label.text = "Input: %s" % staged


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
	style.corner_radius_top_left = 14
	style.corner_radius_top_right = 14
	style.corner_radius_bottom_right = 14
	style.corner_radius_bottom_left = 14
	return style
