extends Area2D
class_name FailZone

var zone_size := Vector2(320, 120)
var fail_message := "You fell into unstable space."


func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	body_entered.connect(_on_body_entered)

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = zone_size
	shape.shape = rect
	add_child(shape)

	var fill := Polygon2D.new()
	fill.polygon = PackedVector2Array([
		Vector2(-zone_size.x * 0.5, -zone_size.y * 0.5),
		Vector2(zone_size.x * 0.5, -zone_size.y * 0.5),
		Vector2(zone_size.x * 0.5, zone_size.y * 0.5),
		Vector2(-zone_size.x * 0.5, zone_size.y * 0.5),
	])
	fill.color = Color(0.2, 0.04, 0.08, 0.12)
	add_child(fill)


func _on_body_entered(body: Node) -> void:
	if body is DimensionPlayer:
		GameManager.fail_level(fail_message)
