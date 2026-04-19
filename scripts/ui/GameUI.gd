extends CanvasLayer

const TITLE_BG := preload("res://assets/sprites/backgrounds/title_backdrop.svg")
const MemoryPuzzleScene := preload("res://scripts/ui/MemoryPuzzle.gd")
const KeypadPuzzleScene := preload("res://scripts/ui/KeypadPuzzle.gd")

var root: Control
var fade_rect: ColorRect
var dimmer_rect: ColorRect
var title_screen: Control
var hud_panel: PanelContainer
var prompt_panel: PanelContainer
var prompt_label: Label
var level_label: Label
var objective_label: Label
var dimension_label: Label
var clue_panel: PanelContainer
var clue_list: VBoxContainer
var fail_panel: PanelContainer
var complete_panel: PanelContainer
var victory_panel: PanelContainer
var modal_holder: CenterContainer
var memory_overlay: MemoryPuzzle
var keypad_overlay: KeypadPuzzle
var complete_label: Label
var victory_label: Label


## Builds UI layers and subscribes to GameManager signals.
func _ready() -> void:
	root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(root)

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	_build_background_fx()
	_build_title_screen()
	_build_hud()
	_build_state_panels()
	_build_modals()

	GameManager.title_requested.connect(_show_title)
	GameManager.level_loaded.connect(_on_level_loaded)
	GameManager.objective_updated.connect(_on_objective_updated)
	GameManager.prompt_changed.connect(_on_prompt_changed)
	GameManager.dimension_changed.connect(_on_dimension_changed)
	GameManager.level_failed.connect(_on_level_failed)
	GameManager.level_completed.connect(_on_level_completed)
	GameManager.memory_puzzle_requested.connect(_on_memory_puzzle_requested)
	GameManager.keypad_puzzle_requested.connect(_on_keypad_puzzle_requested)
	GameManager.hide_modal.connect(_hide_modals)
	GameManager.dimension_fx.connect(_play_dimension_flash)
	GameManager.clue_logged.connect(_on_clue_logged)
	GameManager.clues_reset.connect(_reset_clues)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel") and (memory_overlay.visible or keypad_overlay.visible):
		GameManager.close_modal()


func _build_background_fx() -> void:
	dimmer_rect = ColorRect.new()
	dimmer_rect.color = Color(0.01, 0.03, 0.05, 0.58)
	dimmer_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	dimmer_rect.visible = false
	root.add_child(dimmer_rect)

	fade_rect = ColorRect.new()
	fade_rect.color = Color(0.82, 1.0, 1.0, 0.0)
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(fade_rect)


func _build_title_screen() -> void:
	title_screen = Control.new()
	title_screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(title_screen)

	var bg := TextureRect.new()
	bg.texture = TITLE_BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	title_screen.add_child(bg)

	var overlay := ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.01, 0.03, 0.05, 0.45)
	title_screen.add_child(overlay)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	title_screen.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(720, 420)
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.05, 0.09, 0.13, 0.88), Color(0.50, 0.98, 1.0, 0.32)))
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 28)
	panel.add_child(margin)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 14)
	margin.add_child(layout)

	var kicker := Label.new()
	kicker.text = "PARALLEL CONTAINMENT PROTOTYPE"
	kicker.modulate = Color(1.0, 0.72, 0.35, 0.94)
	kicker.add_theme_font_size_override("font_size", 18)
	layout.add_child(kicker)

	var title := Label.new()
	title.text = "PLANAR"
	title.modulate = Color("F6FFFF")
	title.add_theme_font_size_override("font_size", 46)
	layout.add_child(title)

	var summary := Label.new()
	summary.text = "A 2D puzzle-platformer prototype set inside a hidden dimensional lab. Shift dimensions, recover clues, solve chamber puzzles, and escape the scientist's containment system."
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary.modulate = Color(0.82, 0.92, 1.0, 0.9)
	layout.add_child(summary)

	var controls := Label.new()
	controls.text = "Move: A / D or Arrow Keys   Jump: Space   Interact: X / E / Enter   Restart: R"
	controls.modulate = Color(0.72, 0.88, 0.96, 0.74)
	layout.add_child(controls)

	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 12)
	layout.add_child(buttons)

	var start_button := _action_button("Start Experiment")
	start_button.pressed.connect(GameManager.start_game)
	buttons.add_child(start_button)

	var subtitle := Label.new()
	subtitle.text = "Five chambers stand between you and the exit: traversal, pressure sync, memory recall, security sprinting, and the final password override."
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle.modulate = Color(0.58, 0.82, 0.92, 0.72)
	layout.add_child(subtitle)


func _build_hud() -> void:
	hud_panel = PanelContainer.new()
	hud_panel.position = Vector2(18, 18)
	hud_panel.size = Vector2(540, 128)
	hud_panel.visible = false
	hud_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.04, 0.07, 0.11, 0.76), Color(0.50, 0.98, 1.0, 0.28)))
	root.add_child(hud_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 14)
	hud_panel.add_child(margin)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 6)
	margin.add_child(layout)

	level_label = Label.new()
	level_label.add_theme_font_size_override("font_size", 22)
	level_label.modulate = Color("F6FFFF")
	layout.add_child(level_label)

	objective_label = Label.new()
	objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	objective_label.modulate = Color(0.78, 0.92, 1.0, 0.86)
	layout.add_child(objective_label)

	dimension_label = Label.new()
	dimension_label.position = Vector2(1080, 24)
	dimension_label.size = Vector2(170, 42)
	dimension_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dimension_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	dimension_label.add_theme_font_size_override("font_size", 18)
	root.add_child(dimension_label)

	prompt_panel = PanelContainer.new()
	prompt_panel.position = Vector2(388, 646)
	prompt_panel.size = Vector2(504, 48)
	prompt_panel.visible = false
	prompt_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.03, 0.06, 0.09, 0.82), Color(1.0, 0.70, 0.38, 0.26)))
	root.add_child(prompt_panel)

	prompt_label = Label.new()
	prompt_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	prompt_label.modulate = Color(1.0, 0.92, 0.86, 0.96)
	prompt_panel.add_child(prompt_label)

	clue_panel = PanelContainer.new()
	clue_panel.position = Vector2(18, 156)
	clue_panel.size = Vector2(420, 230)
	clue_panel.visible = false
	clue_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.05, 0.07, 0.10, 0.74), Color(1.0, 0.70, 0.38, 0.22)))
	root.add_child(clue_panel)

	var clue_margin := MarginContainer.new()
	clue_margin.add_theme_constant_override("margin_left", 16)
	clue_margin.add_theme_constant_override("margin_top", 14)
	clue_margin.add_theme_constant_override("margin_right", 16)
	clue_margin.add_theme_constant_override("margin_bottom", 14)
	clue_panel.add_child(clue_margin)

	clue_list = VBoxContainer.new()
	clue_list.add_theme_constant_override("separation", 10)
	clue_margin.add_child(clue_list)

	var clue_title := Label.new()
	clue_title.text = "Recovered Clues"
	clue_title.add_theme_font_size_override("font_size", 20)
	clue_title.modulate = Color(1.0, 0.80, 0.55, 0.94)
	clue_list.add_child(clue_title)


func _build_state_panels() -> void:
	fail_panel = _message_panel("Containment Failure", "Restart", "Title")
	fail_panel.visible = false
	root.add_child(fail_panel)
	(fail_panel.get_meta("primary_button") as Button).pressed.connect(GameManager.restart_level)
	(fail_panel.get_meta("secondary_button") as Button).pressed.connect(GameManager.show_title)

	complete_panel = _message_panel("Chamber Cleared", "Next Level", "Restart")
	complete_panel.visible = false
	root.add_child(complete_panel)
	complete_label = complete_panel.get_meta("message_label")
	(complete_panel.get_meta("primary_button") as Button).pressed.connect(GameManager.next_level)
	(complete_panel.get_meta("secondary_button") as Button).pressed.connect(GameManager.restart_level)

	victory_panel = _message_panel("Escape Achieved", "Return To Title", "Restart")
	victory_panel.visible = false
	root.add_child(victory_panel)
	victory_label = victory_panel.get_meta("message_label")
	(victory_panel.get_meta("primary_button") as Button).pressed.connect(GameManager.show_title)
	(victory_panel.get_meta("secondary_button") as Button).pressed.connect(GameManager.restart_level)


func _build_modals() -> void:
	modal_holder = CenterContainer.new()
	modal_holder.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(modal_holder)

	memory_overlay = MemoryPuzzleScene.new()
	memory_overlay.attempt_submitted.connect(_submit_memory_attempt)
	memory_overlay.closed.connect(GameManager.close_modal)
	modal_holder.add_child(memory_overlay)

	keypad_overlay = KeypadPuzzleScene.new()
	keypad_overlay.attempt_submitted.connect(_submit_password_attempt)
	keypad_overlay.closed.connect(GameManager.close_modal)
	modal_holder.add_child(keypad_overlay)


func _show_title() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	title_screen.visible = true
	hud_panel.visible = false
	prompt_panel.visible = false
	clue_panel.visible = false
	fail_panel.visible = false
	complete_panel.visible = false
	victory_panel.visible = false
	_hide_modals()


## Applies visible UI state when a level becomes active.
func _on_level_loaded(level_name_text: String, objective_text_value: String, index: int, total: int) -> void:
	title_screen.visible = false
	fail_panel.visible = false
	complete_panel.visible = false
	victory_panel.visible = false
	hud_panel.visible = true
	level_label.text = "LEVEL %d / %d  |  %s" % [index, total, level_name_text]
	objective_label.text = objective_text_value
	_play_dimension_flash()


func _on_objective_updated(objective_text_value: String) -> void:
	objective_label.text = objective_text_value


func _on_prompt_changed(prompt: String) -> void:
	prompt_panel.visible = not prompt.is_empty()
	prompt_label.text = prompt


func _on_dimension_changed(label_text: String, accent: Color) -> void:
	dimension_label.text = label_text
	dimension_label.modulate = accent


## Shows failure messaging and restart hint.
func _on_level_failed(reason: String) -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	fail_panel.visible = true
	(fail_panel.get_meta("message_label") as Label).text = "%s\n\nPress R to restart." % reason


## Shows chamber clear or final victory messaging and key hints.
func _on_level_completed(level_name_text: String, final_level: bool) -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if final_level:
		victory_panel.visible = true
		victory_label.text = "The final containment password broke the scientist's lockdown. You escaped %s and left the dimensional lab behind.\n\nPress Enter to return to title, or R to restart." % level_name_text
	else:
		complete_panel.visible = true
		complete_label.text = "%s completed. Advance to the next chamber.\n\nPress Enter for next level, or R to restart." % level_name_text


## Opens the memory puzzle modal and hides other modal content.
func _on_memory_puzzle_requested(sequence: Array, title_text: String, hint: String) -> void:
	dimmer_rect.visible = true
	memory_overlay.open_puzzle(sequence, title_text, hint)
	keypad_overlay.visible = false


## Opens the keypad modal with clue history and hides other modal content.
func _on_keypad_puzzle_requested(title_text: String, subtitle: String, clue_lines: Array) -> void:
	dimmer_rect.visible = true
	keypad_overlay.open_puzzle(title_text, subtitle, clue_lines)
	memory_overlay.visible = false


func _hide_modals() -> void:
	dimmer_rect.visible = false
	memory_overlay.visible = false
	keypad_overlay.visible = false


## Sends memory submissions through the manager and keeps modal on failure.
func _submit_memory_attempt(sequence: Array) -> void:
	if GameManager.submit_memory_attempt(sequence):
		_hide_modals()
	else:
		memory_overlay.show_error("Sequence mismatch. Recheck the shifted clue.")


## Sends keypad submissions through the manager and keeps modal on failure.
func _submit_password_attempt(text: String) -> void:
	if GameManager.submit_password_attempt(text):
		_hide_modals()
	else:
		keypad_overlay.show_error("Access denied. Re-evaluate the archived clues.")


func _on_clue_logged(title_text: String, body: String) -> void:
	clue_panel.visible = true
	var entry := Label.new()
	entry.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	entry.text = "%s\n%s" % [title_text, body]
	entry.modulate = Color(0.88, 0.95, 1.0, 0.86)
	clue_list.add_child(entry)


func _reset_clues() -> void:
	for child in clue_list.get_children():
		if child is Label and child.text != "Recovered Clues":
			child.queue_free()
	clue_panel.visible = false


func _play_dimension_flash() -> void:
	fade_rect.color = Color(0.82, 1.0, 1.0, 0.16)
	var tween := create_tween()
	tween.tween_property(fade_rect, "color", Color(0.82, 1.0, 1.0, 0.0), 0.28)


func _message_panel(title_text: String, primary_text: String, secondary_text: String) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.position = Vector2(340, 170)
	panel.size = Vector2(600, 320)
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.05, 0.08, 0.12, 0.92), Color(1.0, 0.70, 0.38, 0.28)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 22)
	panel.add_child(margin)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 16)
	margin.add_child(layout)

	var title := Label.new()
	title.text = title_text
	title.add_theme_font_size_override("font_size", 30)
	title.modulate = Color("F8FFFF")
	layout.add_child(title)

	var message := Label.new()
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message.modulate = Color(0.84, 0.93, 1.0, 0.9)
	layout.add_child(message)

	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 12)
	layout.add_child(buttons)

	var primary := _action_button(primary_text)
	buttons.add_child(primary)

	var secondary := _action_button(secondary_text)
	buttons.add_child(secondary)

	panel.set_meta("message_label", message)
	panel.set_meta("primary_button", primary)
	panel.set_meta("secondary_button", secondary)
	return panel


func _action_button(text_value: String) -> Button:
	var button := Button.new()
	button.text = text_value
	button.custom_minimum_size = Vector2(180, 50)
	button.add_theme_stylebox_override("normal", _button_style(Color("6FF8FF"), 0.18))
	button.add_theme_stylebox_override("hover", _button_style(Color("6FF8FF"), 0.28))
	button.add_theme_stylebox_override("pressed", _button_style(Color("6FF8FF"), 0.40))
	return button


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
