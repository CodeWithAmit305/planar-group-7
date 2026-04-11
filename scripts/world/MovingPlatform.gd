extends AnimatableBody2D
class_name MovingPlatform

const PLATFORM_TEXTURE := preload("res://assets/sprites/world/platform_panel.svg")
const GLOW_TEXTURE := preload("res://assets/sprites/fx/glow.svg")

@export var start_position := Vector2.ZERO
@export var end_position := Vector2(240, 0)
@export var move_duration := 1.8
@export var platform_size := Vector2(180, 36)
@export var tint := Color("B8F7FF")

var _travel := 0.0
var _direction := 1.0


func _ready() -> void:
	sync_to_physics = true
	position = start_position
	_build_visuals()


func _physics_process(delta: float) -> void:
	if move_duration <= 0.0:
		position = start_position
		return

	_travel += (_direction * delta) / move_duration
	if _travel >= 1.0:
		_travel = 1.0
		_direction = -1.0
	elif _travel <= 0.0:
		_travel = 0.0
		_direction = 1.0

	position = start_position.lerp(end_position, _travel)


func _build_visuals() -> void:
	var shape := CollisionShape2D.new()
	var collision := RectangleShape2D.new()
	collision.size = platform_size
	shape.shape = collision
	add_child(shape)

	var sprite := Sprite2D.new()
	sprite.texture = PLATFORM_TEXTURE
	sprite.scale = Vector2(platform_size.x / 256.0, platform_size.y / 64.0)
	sprite.modulate = tint
	add_child(sprite)

	var top_glow := Sprite2D.new()
	top_glow.texture = GLOW_TEXTURE
	top_glow.scale = Vector2(platform_size.x / 320.0, 0.1)
	top_glow.position = Vector2(0, -platform_size.y * 0.34)
	top_glow.modulate = Color(tint.r, tint.g, tint.b, 0.34)
	add_child(top_glow)
