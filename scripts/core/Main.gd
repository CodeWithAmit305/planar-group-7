extends Node

@onready var level_host: Node = $LevelHost


## Initializes input bindings, audio, and the top-level game state.
func _ready() -> void:
	_ensure_input_actions()
	AudioManager.start_gameplay_audio()
	GameManager.bind_main(self)
	GameManager.show_title()


## Handles global state controls (start, next, title return, restart).
func _unhandled_input(event: InputEvent) -> void:
	if GameManager.state == "title" and (event.is_action_pressed("interact") or event.is_action_pressed("jump")):
		GameManager.start_game()
		get_viewport().set_input_as_handled()
		return

	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			if GameManager.state == "complete":
				GameManager.next_level()
				get_viewport().set_input_as_handled()
				return
			if GameManager.state == "victory":
				GameManager.show_title()
				get_viewport().set_input_as_handled()
				return

	if event.is_action_pressed("restart_level") and GameManager.state != "title":
		GameManager.restart_level()


## Replaces the active level node in the level host container.
func show_level(level: Node) -> void:
	clear_level()
	level_host.add_child(level)


## Clears all child nodes from the level host before loading a level.
func clear_level() -> void:
	for child in level_host.get_children():
		child.queue_free()


## Defines default keyboard bindings once when actions are empty.
func _ensure_input_actions() -> void:
	_bind_action("move_left", [KEY_A, KEY_LEFT])
	_bind_action("move_right", [KEY_D, KEY_RIGHT])
	_bind_action("jump", [KEY_SPACE, KEY_W, KEY_UP])
	_bind_action("interact", [KEY_X, KEY_E, KEY_ENTER])
	_bind_action("restart_level", [KEY_R])
	_bind_action("cancel", [KEY_ESCAPE])


## Adds key events to an action only if the action has no existing events.
func _bind_action(action_name: String, keys: Array[int]) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	if InputMap.action_get_events(action_name).size() > 0:
		return

	for key in keys:
		var event := InputEventKey.new()
		event.keycode = key
		event.physical_keycode = key
		InputMap.action_add_event(action_name, event)
