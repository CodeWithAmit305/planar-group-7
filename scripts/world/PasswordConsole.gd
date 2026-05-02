extends Interactable
class_name PasswordConsole

# Keypad console that checks a text password and emits unlock signal on success.
signal password_solved

const CONSOLE_TEXTURE := preload("res://assets/sprites/world/console_lab.svg")
const GLOW_TEXTURE := preload("res://assets/sprites/fx/glow.svg")

var expected_password := ""
var title_text := "Password Console"
var subtitle_text := "Enter override code"
var solved := false


func _ready() -> void:
	prompt_text = "Press X to open keypad"
	_build_visuals()
	super._ready()


func interact(_player: Node) -> void:
	if solved:
		GameManager.set_prompt("Override accepted. Exit is open.")
		return

	AudioManager.play_sfx("interact")
	GameManager.request_keypad_puzzle(self, title_text, subtitle_text)


func validate_password(text: String) -> bool:
	if solved:
		return true

	if text.strip_edges().to_upper() != expected_password.to_upper():
		return false

	solved = true
	prompt_text = "Override accepted"
	emit_signal("password_solved")
	return true


func _build_visuals() -> void:
	if get_child_count() > 0:
		return

	var glow := Sprite2D.new()
	glow.texture = GLOW_TEXTURE
	glow.scale = Vector2(0.34, 0.25)
	glow.position = Vector2(0, -84)
	glow.modulate = Color(1.0, 0.72, 0.35, 0.24)
	add_child(glow)

	var sprite := Sprite2D.new()
	sprite.texture = CONSOLE_TEXTURE
	sprite.scale = Vector2(0.82, 0.82)
	sprite.position = Vector2(0, -72)
	add_child(sprite)

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(72, 132)
	shape.shape = rect
	shape.position = Vector2(0, -76)
	add_child(shape)
