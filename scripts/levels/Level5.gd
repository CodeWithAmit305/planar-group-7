extends BaseLevel

# Final chamber: collect clue fragments and infer a password override.
var exit_door: ExitDoor


func _init() -> void:
	level_name = "Level 5 - Exit Protocol"
	objective_text = "Collect password clues across dimensions, infer the override code, and unlock the final exit."
	level_size = Vector2(1700, 720)
	spawn_position = Vector2(150, 520)
	fail_y = 920.0


func build_level() -> void:
	add_platform(Rect2(0, 592, 720, 92), 0, Color("B8F7FF"))
	add_platform(Rect2(1220, 592, 480, 92), 0, Color("B8F7FF"))
	add_platform(Rect2(0, 592, 720, 92), 1, Color("FFC570"))
	add_platform(Rect2(860, 592, 260, 92), 1, Color("FFC570"))
	add_platform(Rect2(1240, 592, 460, 92), 1, Color("FFC570"))

	add_dimension_anchor(Vector2(560, 520))
	add_dimension_anchor(Vector2(1380, 520))

	exit_door = add_exit_door(Vector2(1560, 498), true)

	var keypad := PasswordConsole.new()
	keypad.position = Vector2(1345, 530)
	keypad.expected_password = "ECHO42"
	keypad.title_text = "Containment Override"
	keypad.subtitle_text = "Infer the password from archived clues recovered across both dimensions."
	keypad.password_solved.connect(_on_password_solved)
	dimension_root_a.add_child(keypad)

	var clue_a := CluePickup.new()
	clue_a.position = Vector2(336, 528)
	clue_a.clue_id = "level_5_alias"
	clue_a.clue_title = "Alias Record"
	clue_a.clue_body = "Containment subjects are logged by field alias. Current intruder alias: ECHO."
	dimension_root_a.add_child(clue_a)

	var clue_b := CluePickup.new()
	clue_b.position = Vector2(974, 528)
	clue_b.clue_id = "level_5_syntax"
	clue_b.clue_title = "Override Syntax"
	clue_b.clue_body = "Emergency override format appends the active trial number."
	dimension_root_b.add_child(clue_b)

	var clue_c := CluePickup.new()
	clue_c.position = Vector2(1328, 528)
	clue_c.clue_id = "level_5_trial"
	clue_c.clue_title = "Trial Archive"
	clue_c.clue_body = "Experiment log: Trial 42 remained active after containment."
	dimension_root_b.add_child(clue_c)

	add_fail_zone(Rect2(720, 650, 520, 120), "The chamber floor collapsed beneath you.")
	add_glow(Vector2(980, 420), Vector2(0.36, 0.16), Color(1.0, 0.72, 0.35, 0.14), 1)
	add_glow(Vector2(1330, 420), Vector2(0.42, 0.18), Color(1.0, 0.72, 0.35, 0.14), 1)


func _on_password_solved() -> void:
	exit_door.unlock()
	GameManager.update_objective("Override accepted. Move through the final exit.")
