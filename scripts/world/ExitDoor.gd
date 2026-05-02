extends Node2D
class_name ExitDoor

# Door entity with physical blocker + trigger that can complete the level.
const DOOR_TEXTURE := preload("res://assets/sprites/world/door_lab.svg")
const GLOW_TEXTURE := preload("res://assets/sprites/fx/glow.svg")

var unlocked := false
var completes_level := true
var door_sprite: Sprite2D
var barrier_shape: CollisionShape2D
var status_glow: Sprite2D


func _ready() -> void:
	_build_visuals()
	_apply_state()


func unlock() -> void:
	if unlocked:
		return

	unlocked = true
	_apply_state()

	var tween := create_tween()
	tween.tween_property(door_sprite, "position:y", -10.0, 0.22).as_relative()
	tween.tween_property(door_sprite, "position:y", 4.0, 0.15).as_relative()


func set_locked(locked: bool) -> void:
	unlocked = not locked
	_apply_state()


func _build_visuals() -> void:
	var glow := Sprite2D.new()
	glow.texture = GLOW_TEXTURE
	glow.scale = Vector2(0.5, 0.9)
	glow.modulate = Color(0.52, 1.0, 1.0, 0.24)
	glow.position = Vector2(0, -90)
	add_child(glow)

	door_sprite = Sprite2D.new()
	door_sprite.texture = DOOR_TEXTURE
	door_sprite.position = Vector2.ZERO
	door_sprite.scale = Vector2(0.84, 0.84)
	add_child(door_sprite)

	status_glow = Sprite2D.new()
	status_glow.texture = GLOW_TEXTURE
	status_glow.scale = Vector2(0.12, 0.08)
	status_glow.position = Vector2(24, -46)
	add_child(status_glow)

	var barrier := StaticBody2D.new()
	barrier.collision_layer = 1
	barrier.collision_mask = 0
	add_child(barrier)

	barrier_shape = CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(80, 180)
	barrier_shape.shape = rect
	barrier_shape.position = Vector2(0, -70)
	barrier.add_child(barrier_shape)

	var trigger := Area2D.new()
	trigger.collision_layer = 0
	trigger.collision_mask = 1
	trigger.body_entered.connect(_on_body_entered)
	add_child(trigger)

	var trigger_shape := CollisionShape2D.new()
	var trigger_rect := RectangleShape2D.new()
	trigger_rect.size = Vector2(110, 220)
	trigger_shape.shape = trigger_rect
	trigger_shape.position = Vector2(0, -70)
	trigger.add_child(trigger_shape)


func _apply_state() -> void:
	if barrier_shape:
		barrier_shape.disabled = unlocked
	if status_glow:
		status_glow.modulate = Color("79ffac") if unlocked else Color("ff6c6c")


func _on_body_entered(body: Node) -> void:
	if unlocked and completes_level and body is DimensionPlayer:
		GameManager.complete_level()
