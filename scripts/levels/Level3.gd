extends BaseLevel

# Memory recall puzzle using clues visible in the alternate dimension.
const TERMINAL_TEXTURE := preload("res://assets/sprites/world/clue_terminal.svg")
const COLOR_MAP := {
	"CYAN": Color("77F8FF"),
	"AMBER": Color("FFB54A"),
	"MAGENTA": Color("FF6ED5"),
	"LIME": Color("B3FF6E"),
}

var exit_door: ExitDoor
var memory_console: MemoryConsole
var sequence_clue: CluePickup
var sequence_clue_title := ""
var sequence_clue_body := ""


func _init() -> void:
	level_name = "Level 3 - Chroma Recall"
	objective_text = "Reveal the color sequence in the shifted chamber, then repeat it at the memory console to unlock the exit."
	level_size = Vector2(1600, 720)
	spawn_position = Vector2(150, 520)
	fail_y = 900.0


func build_level() -> void:
	add_platform(Rect2(0, 592, 1600, 92), 0, Color("B8F7FF"))
	add_platform(Rect2(0, 592, 1600, 92), 1, Color("FFC570"))

	var sequence := _generate_sequence()
	var sequence_text := " -> ".join(sequence)

	exit_door = add_exit_door(Vector2(1470, 498), true)
	add_dimension_anchor(Vector2(830, 520))

	memory_console = MemoryConsole.new()
	memory_console.position = Vector2(690, 530)
	memory_console.sequence = sequence
	memory_console.title_text = "Chromatic Recall Console"
	memory_console.hint_text = "Sequence source is hidden in the shifted chamber. Archive it, then repeat the full order here."
	memory_console.memory_solved.connect(_on_memory_solved)
	dimension_root_a.add_child(memory_console)

	sequence_clue = CluePickup.new()
	sequence_clue.position = Vector2(1120, 528)
	sequence_clue.clue_id = "level_3_sequence"
	sequence_clue.clue_title = "Shifted Spectrum Sequence"
	sequence_clue.clue_body = "Order logged: %s." % sequence_text
	sequence_clue_title = sequence_clue.clue_title
	sequence_clue_body = sequence_clue.clue_body
	dimension_root_b.add_child(sequence_clue)

	add_sprite(TERMINAL_TEXTURE, Vector2(1120, 506), Vector2(1.0, 1.0), 1)
	var bar_x := 1040.0
	for color_name in sequence:
		_add_color_bar(Vector2(bar_x, 416), COLOR_MAP[color_name])
		bar_x += 60.0


func _on_memory_solved() -> void:
	exit_door.unlock()
	GameManager.update_objective("Console synced. Reach the exit door.")


func on_dimension_switched(new_dimension: int) -> void:
	if not sequence_clue:
		return

	GameManager.clue_entries.clear()
	GameManager.emit_signal("clues_reset")

	if new_dimension == 1 and sequence_clue.discovered:
		GameManager.register_clue(sequence_clue.clue_id, sequence_clue_title, sequence_clue_body)


func _add_color_bar(position: Vector2, color: Color) -> void:
	var poly := Polygon2D.new()
	poly.color = color
	poly.polygon = PackedVector2Array([
		Vector2(-18, -42),
		Vector2(18, -42),
		Vector2(18, 42),
		Vector2(-18, 42),
	])
	poly.position = position
	dimension_root_b.add_child(poly)
	add_glow(position, Vector2(0.16, 0.28), Color(color.r, color.g, color.b, 0.18), 1)


func _generate_sequence() -> Array[String]:
	var rng := RandomNumberGenerator.new()
	rng.randomize()

	var colors: Array[String] = ["CYAN", "AMBER", "MAGENTA", "LIME"]
	for i in range(colors.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var temp := colors[i]
		colors[i] = colors[j]
		colors[j] = temp

	return colors
