extends Interactable
class_name CluePickup

# Interactable clue terminal that can register lore/password hints in GameManager.
const TERMINAL_TEXTURE := preload("res://assets/sprites/world/clue_terminal.svg")
const GLOW_TEXTURE := preload("res://assets/sprites/fx/glow.svg")

var clue_id := ""
var clue_title := "Recovered Note"
var clue_body := ""
var discovered := false
var log_to_memory := true


func _ready() -> void:
	prompt_text = "Press X to archive clue"
	_build_visuals()
	super._ready()


func interact(_player: Node) -> void:
	AudioManager.play_sfx("interact")
	if not discovered:
		discovered = true
		prompt_text = "Clue archived"
		if log_to_memory:
			GameManager.register_clue(clue_id, clue_title, clue_body)
	else:
		if log_to_memory:
			GameManager.set_prompt("Clue already archived in visor memory.")
		else:
			GameManager.set_prompt("No archive available. Memorize and proceed.")


func _build_visuals() -> void:
	if get_child_count() > 0:
		return

	var glow := Sprite2D.new()
	glow.texture = GLOW_TEXTURE
	glow.scale = Vector2(0.28, 0.3)
	glow.position = Vector2(0, -70)
	glow.modulate = Color(0.52, 1.0, 1.0, 0.24)
	add_child(glow)

	var sprite := Sprite2D.new()
	sprite.texture = TERMINAL_TEXTURE
	sprite.scale = Vector2(0.82, 0.82)
	sprite.position = Vector2(0, -66)
	add_child(sprite)

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(66, 138)
	shape.shape = rect
	shape.position = Vector2(0, -72)
	add_child(shape)
