extends Area2D
class_name PressurePad

# Floor trigger that emits once when the player steps onto it.
signal pressed

const GLOW_TEXTURE := preload("res://assets/sprites/fx/glow.svg")

@export var pad_size := Vector2(92, 20)
@export var accent := Color("6FF8FF")
@export var active_accent := Color("79ffac")

var _fill: Polygon2D
var _glow: Sprite2D
var _active := false


func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	monitoring = true
	monitorable = true
	body_entered.connect(_on_body_entered)
	_build_visuals()
	_apply_visual_state()


func set_active(value: bool) -> void:
	_active = value
	_apply_visual_state()


func _on_body_entered(body: Node) -> void:
	if body is DimensionPlayer:
		emit_signal("pressed")


func _build_visuals() -> void:
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(pad_size.x, pad_size.y + 10.0)
	shape.shape = rect
	shape.position = Vector2(0, -4)
	add_child(shape)

	_fill = Polygon2D.new()
	_fill.polygon = PackedVector2Array([
		Vector2(-pad_size.x * 0.5, -pad_size.y * 0.5),
		Vector2(pad_size.x * 0.5, -pad_size.y * 0.5),
		Vector2(pad_size.x * 0.5, pad_size.y * 0.5),
		Vector2(-pad_size.x * 0.5, pad_size.y * 0.5),
	])
	add_child(_fill)

	_glow = Sprite2D.new()
	_glow.texture = GLOW_TEXTURE
	_glow.scale = Vector2(pad_size.x / 220.0, 0.14)
	_glow.position = Vector2(0, -pad_size.y * 0.5)
	add_child(_glow)


func _apply_visual_state() -> void:
	if _fill:
		_fill.color = active_accent if _active else accent
	if _glow:
		var color := active_accent if _active else accent
		_glow.modulate = Color(color.r, color.g, color.b, 0.34)
