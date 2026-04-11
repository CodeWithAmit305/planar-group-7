extends Interactable
class_name TimedSwitch

# Re-usable timed trigger used for short-lived gate/window mechanics.
signal activated

const CONSOLE_TEXTURE := preload("res://assets/sprites/world/console_lab.svg")
const GLOW_TEXTURE := preload("res://assets/sprites/fx/glow.svg")

@export var cooldown_duration := 1.4

var _cooldown_timer: Timer
var _status_glow: Sprite2D
var _busy := false


func _ready() -> void:
	prompt_text = "Press X to pulse the gate"
	_build_visuals()
	super._ready()


func interact(_player: Node) -> void:
	if _busy or not GameManager.can_player_input():
		return

	_busy = true
	prompt_text = "Gate pulse active"
	_set_glow(Color("79ffac"))
	AudioManager.play_sfx("interact")
	emit_signal("activated")
	_cooldown_timer.start(cooldown_duration)


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

	_status_glow = Sprite2D.new()
	_status_glow.texture = GLOW_TEXTURE
	_status_glow.scale = Vector2(0.12, 0.08)
	_status_glow.position = Vector2(22, -90)
	add_child(_status_glow)
	_set_glow(Color("ff6c6c"))

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(72, 132)
	shape.shape = rect
	shape.position = Vector2(0, -76)
	add_child(shape)

	_cooldown_timer = Timer.new()
	_cooldown_timer.one_shot = true
	_cooldown_timer.timeout.connect(_on_cooldown_timeout)
	add_child(_cooldown_timer)


func _on_cooldown_timeout() -> void:
	_busy = false
	prompt_text = "Press X to pulse the gate"
	_set_glow(Color("ff6c6c"))


func _set_glow(color: Color) -> void:
	if _status_glow:
		_status_glow.modulate = color
