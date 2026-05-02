extends Interactable
class_name DimensionAnchor

# Portal-like interactable that asks the active level to swap dimensions.
const PORTAL_TEXTURE := preload("res://assets/sprites/world/portal_anchor.svg")
const GLOW_TEXTURE := preload("res://assets/sprites/fx/glow.svg")

var level


func _ready() -> void:
	prompt_text = "Press X to shift dimensions"
	_build_visuals()
	super._ready()


func interact(_player: Node) -> void:
	if level and level.has_method("switch_dimension") and GameManager.can_player_input():
		level.switch_dimension()


func _build_visuals() -> void:
	if get_child_count() > 0:
		return

	var glow := Sprite2D.new()
	glow.texture = GLOW_TEXTURE
	glow.modulate = Color(0.55, 1.0, 1.0, 0.35)
	glow.scale = Vector2(0.55, 0.45)
	glow.position = Vector2(0, -20)
	add_child(glow)

	var sprite := Sprite2D.new()
	sprite.texture = PORTAL_TEXTURE
	sprite.scale = Vector2(0.68, 0.68)
	sprite.position = Vector2(0, -28)
	add_child(sprite)

	var shape := CollisionShape2D.new()
	var capsule := CapsuleShape2D.new()
	capsule.radius = 36
	capsule.height = 120
	shape.shape = capsule
	shape.position = Vector2(0, -32)
	add_child(shape)
