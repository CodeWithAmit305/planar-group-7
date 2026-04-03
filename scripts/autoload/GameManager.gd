extends Node

signal title_requested
signal level_loaded(level_name: String, objective: String, index: int, total: int)
signal objective_updated(objective: String)
signal prompt_changed(prompt: String)
signal dimension_changed(label: String, accent: Color)
signal level_failed(reason: String)
signal level_completed(level_name: String, final_level: bool)
signal memory_puzzle_requested(sequence: Array, title: String, hint: String)
signal keypad_puzzle_requested(title: String, subtitle: String, clue_lines: Array)
signal clue_logged(title: String, body: String)
signal clues_reset
signal hide_modal
signal dimension_fx

const LEVEL_SCENES: Array[PackedScene] = [
	preload("res://scenes/levels/Level1.tscn"),
	preload("res://scenes/levels/Level2.tscn"),
	preload("res://scenes/levels/Level3.tscn"),
	preload("res://scenes/levels/Level4.tscn"),
	preload("res://scenes/levels/Level5.tscn"),
]

const PRIME_ACCENT := Color("86F8FF")
const SHIFT_ACCENT := Color("FFB24B")

var main_root: Node
var current_level: Node
var current_level_index: int = -1
var current_prompt: String = ""
var state: String = "title"
var modal_open: bool = false
var memory_console
var keypad_console
var clue_entries: Array[Dictionary] = []


## Stores the main scene root so the manager can swap level instances.
func bind_main(main: Node) -> void:
	main_root = main


## Returns the game to title state and clears runtime/session state.
func show_title() -> void:
	state = "title"
	modal_open = false
	memory_console = null
	keypad_console = null
	clue_entries.clear()
	emit_signal("clues_reset")
	emit_signal("hide_modal")
	if main_root:
		main_root.clear_level()
	emit_signal("title_requested")


func start_game() -> void:
	load_level(0)


## Loads a level scene by index and resets transient per-level state.
func load_level(index: int) -> void:
	if not main_root:
		return

	current_level_index = clamp(index, 0, LEVEL_SCENES.size() - 1)
	state = "loading"
	modal_open = false
	current_prompt = ""
	memory_console = null
	keypad_console = null
	clue_entries.clear()
	emit_signal("clues_reset")
	emit_signal("hide_modal")
	emit_signal("prompt_changed", "")

	var level_instance: Node = LEVEL_SCENES[current_level_index].instantiate()
	current_level = level_instance
	main_root.show_level(level_instance)


## Marks level bootstrap complete and broadcasts HUD-facing metadata.
func register_level(level: Node, level_name: String, objective: String, dimension_index: int) -> void:
	current_level = level
	state = "playing"
	modal_open = false
	emit_signal("level_loaded", level_name, objective, current_level_index + 1, LEVEL_SCENES.size())
	notify_dimension_changed(dimension_index)


## Central gate used by player/world scripts before accepting controls.
func can_player_input() -> bool:
	return state == "playing" and not modal_open


func set_modal_open(value: bool) -> void:
	modal_open = value


func set_prompt(prompt: String) -> void:
	if prompt == current_prompt:
		return
	current_prompt = prompt
	emit_signal("prompt_changed", prompt)


func clear_prompt() -> void:
	set_prompt("")


func update_objective(objective: String) -> void:
	emit_signal("objective_updated", objective)


func notify_dimension_changed(dimension_index: int) -> void:
	if dimension_index == 0:
		emit_signal("dimension_changed", "Prime Dimension", PRIME_ACCENT)
	else:
		emit_signal("dimension_changed", "Shift Dimension", SHIFT_ACCENT)


func trigger_dimension_fx() -> void:
	emit_signal("dimension_fx")


func register_clue(id: String, title: String, body: String) -> void:
	for entry in clue_entries:
		if entry.get("id", "") == id:
			return

	var entry: Dictionary = {
		"id": id,
		"title": title,
		"body": body,
	}
	clue_entries.append(entry)
	emit_signal("clue_logged", title, body)


func get_clue_lines() -> Array:
	var lines: Array = []
	for entry in clue_entries:
		lines.append("%s: %s" % [entry.title, entry.body])
	return lines


## Opens the memory puzzle modal for the active console.
func request_memory_puzzle(console_ref, sequence: Array, title: String, hint: String) -> void:
	if state != "playing":
		return
	memory_console = console_ref
	modal_open = true
	emit_signal("memory_puzzle_requested", sequence, title, hint)


## Validates a memory attempt and closes the modal on success.
func submit_memory_attempt(input_sequence: Array) -> bool:
	if memory_console == null:
		return false

	var solved: bool = memory_console.validate_sequence(input_sequence)
	if solved:
		modal_open = false
		memory_console = null
		emit_signal("hide_modal")
	return solved


## Opens the keypad modal and injects collected clue text.
func request_keypad_puzzle(console_ref, title: String, subtitle: String) -> void:
	if state != "playing":
		return
	keypad_console = console_ref
	modal_open = true
	emit_signal("keypad_puzzle_requested", title, subtitle, get_clue_lines())


## Validates keypad text and closes the modal on success.
func submit_password_attempt(text: String) -> bool:
	if keypad_console == null:
		return false

	var solved: bool = keypad_console.validate_password(text)
	if solved:
		modal_open = false
		keypad_console = null
		emit_signal("hide_modal")
	return solved


func close_modal() -> void:
	modal_open = false
	memory_console = null
	keypad_console = null
	emit_signal("hide_modal")


## Transitions from gameplay to failed state and emits failure UI/audio.
func fail_level(reason: String) -> void:
	if state != "playing":
		return

	state = "failed"
	modal_open = false
	emit_signal("hide_modal")
	AudioManager.play_sfx("fail")
	emit_signal("level_failed", reason)


## Transitions from gameplay to complete/victory and emits completion data.
func complete_level() -> void:
	if state != "playing":
		return

	var final_level: bool = current_level_index == LEVEL_SCENES.size() - 1
	state = "victory" if final_level else "complete"
	modal_open = false
	emit_signal("hide_modal")
	AudioManager.play_sfx("success")

	var level_name := ""
	if current_level and current_level.has_method("get_level_name"):
		level_name = current_level.get_level_name()

	emit_signal("level_completed", level_name, final_level)


## Reloads the currently active level index.
func restart_level() -> void:
	if current_level_index >= 0:
		load_level(current_level_index)


## Advances to the next level or returns to title after the final chamber.
func next_level() -> void:
	if current_level_index < LEVEL_SCENES.size() - 1:
		load_level(current_level_index + 1)
	else:
		show_title()
