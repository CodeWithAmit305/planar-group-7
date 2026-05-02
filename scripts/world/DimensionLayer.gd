extends Node2D
class_name DimensionLayer

# Toggles visibility/collision state for all children when dimensions switch.
@export var active_modulate := Color(1, 1, 1, 1)
@export var inactive_modulate := Color(0.5, 0.7, 0.82, 0.18)


func set_layer_state(active: bool) -> void:
	visible = true
	modulate = active_modulate if active else inactive_modulate
	_apply_state_recursive(self, active)


func _apply_state_recursive(node: Node, active: bool) -> void:
	for child in node.get_children():
		if child is CollisionShape2D:
			child.disabled = not active
		elif child is CollisionPolygon2D:
			child.disabled = not active
		elif child is Area2D:
			child.monitoring = active
			child.monitorable = active

		_apply_state_recursive(child, active)
