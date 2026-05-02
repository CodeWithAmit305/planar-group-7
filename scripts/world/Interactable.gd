extends Area2D
class_name Interactable

# Base class for world objects that the player can approach and activate.
@export var prompt_text := "Press X to interact"


func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	monitoring = true
	monitorable = true
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	add_to_group("interactable")


func interact(_player: Node) -> void:
	pass


func _on_body_entered(body: Node) -> void:
	if body.has_method("register_interactable"):
		body.register_interactable(self)


func _on_body_exited(body: Node) -> void:
	if body.has_method("unregister_interactable"):
		body.unregister_interactable(self)
