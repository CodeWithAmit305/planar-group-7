extends Interactable
class_name MemoryConsole

# Puzzle console that validates a color sequence before unlocking progression.
signal memory_solved

const CONSOLE_TEXTURE := preload("res://assets/sprites/world/console_lab.svg")
const GLOW_TEXTURE := preload("res://assets/sprites/fx/glow.svg")

var sequence: Array[String] = []
var title_text := "Memory Console"
var hint_text := ""
var solved := false


func _ready() -> void:
	prompt_text = "Press X to access memory console"
	_build_visuals()
	super._ready()


func interact(_player: Node) -> void:
	if solved:
		GameManager.set_prompt("Console already synced. Move to the exit.")
		return

	AudioManager.play_sfx("interact")
	GameManager.request_memory_puzzle(self, sequence, title_text, hint_text)


func validate_sequence(input_sequence: Array) -> bool:
	if solved:
		return true

	if input_sequence.size() != sequence.size():
		return false

	# Compare submitted entries one-by-one for deterministic puzzle validation.
	for i in sequence.size():
		if input_sequence[i] != sequence[i]:
			return false

	solved = true
	prompt_text = "Console synced"
	emit_signal("memory_solved")
	return true


func _build_visuals() -> void:
	if get_child_count() > 0:
		return

	var glow := Sprite2D.new()
	glow.texture = GLOW_TEXTURE
	glow.scale = Vector2(0.36, 0.25)
	glow.position = Vector2(0, -84)
	glow.modulate = Color(0.54, 1.0, 1.0, 0.28)
	add_child(glow)

	var sprite := Sprite2D.new()
	sprite.texture = CONSOLE_TEXTURE
	sprite.scale = Vector2(0.78, 0.78)
	sprite.position = Vector2(0, -72)
	add_child(sprite)

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(72, 132)
	shape.shape = rect
	shape.position = Vector2(0, -76)
	add_child(shape)
