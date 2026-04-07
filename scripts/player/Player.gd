extends CharacterBody2D
class_name DimensionPlayer

# Player controller for movement, jumping, interaction detection, and camera feedback.
const IDLE_TEXTURE := preload("res://assets/sprites/player/player_idle.svg")
const RUN_TEXTURE_1 := preload("res://assets/sprites/player/player_run_1.svg")
const RUN_TEXTURE_2 := preload("res://assets/sprites/player/player_run_2.svg")
const JUMP_TEXTURE := preload("res://assets/sprites/player/player_jump.svg")
const LAND_TEXTURE := preload("res://assets/sprites/player/player_land.svg")

const WALK_SPEED := 280.0
const GROUND_ACCEL := 1800.0
const AIR_ACCEL := 1100.0
const FRICTION := 2200.0
const JUMP_VELOCITY := -520.0
const COYOTE_TIME := 0.12
const JUMP_BUFFER_TIME := 0.12

var gravity := ProjectSettings.get_setting("physics/2d/default_gravity") as float
var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var facing := 1.0
var interactables: Array[Node] = []
var current_interactable
var run_anim_timer := 0.0
var landed_timer := 0.0

var visual_root: Node2D
var sprite: Sprite2D
var shadow: Sprite2D
var camera: Camera2D
var squash_tween: Tween


func _ready() -> void:
	collision_layer = 1
	collision_mask = 1

	var collision := CollisionShape2D.new()
	var capsule := CapsuleShape2D.new()
	capsule.radius = 18
	capsule.height = 52
	collision.shape = capsule
	collision.position = Vector2(0, -30)
	add_child(collision)

	shadow = Sprite2D.new()
	shadow.texture = preload("res://assets/sprites/fx/glow.svg")
	shadow.scale = Vector2(0.18, 0.08)
	shadow.modulate = Color(0.0, 0.0, 0.0, 0.22)
	add_child(shadow)

	visual_root = Node2D.new()
	visual_root.position = Vector2(0, -68)
	add_child(visual_root)

	sprite = Sprite2D.new()
	sprite.texture = IDLE_TEXTURE
	sprite.scale = Vector2(0.75, 0.75)
	visual_root.add_child(sprite)

	camera = Camera2D.new()
	camera.enabled = true
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 7.5
	camera.offset = Vector2.ZERO
	add_child(camera)


func configure_camera_bounds(bounds: Rect2) -> void:
	if not camera:
		return
	camera.limit_left = int(bounds.position.x)
	camera.limit_top = int(bounds.position.y)
	camera.limit_right = int(bounds.end.x)
	camera.limit_bottom = int(bounds.end.y)


func _physics_process(delta: float) -> void:
	landed_timer = max(landed_timer - delta, 0.0)
	_refresh_interactable()

	if not GameManager.can_player_input():
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)
		velocity.y += gravity * delta
		move_and_slide()
		_update_animation(delta)
		return

	var move_input := Input.get_axis("move_left", "move_right")
	if move_input != 0.0:
		facing = sign(move_input)

	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer = max(coyote_timer - delta, 0.0)

	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	else:
		jump_buffer_timer = max(jump_buffer_timer - delta, 0.0)

	# Combine jump buffering + coyote time so input remains responsive near edges.
	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer = 0.0
		coyote_timer = 0.0
		AudioManager.play_sfx("jump")
		_apply_squash(Vector2(0.88, 1.08))

	var accel := GROUND_ACCEL if is_on_floor() else AIR_ACCEL
	if move_input != 0.0:
		velocity.x = move_toward(velocity.x, move_input * WALK_SPEED, accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)

	velocity.y += gravity * delta

	if Input.is_action_just_pressed("interact") and current_interactable:
		current_interactable.interact(self)

	# Capture previous grounded state to trigger landing-only feedback effects.
	var was_on_floor := is_on_floor()
	move_and_slide()
	if not was_on_floor and is_on_floor():
		landed_timer = 0.12
		_apply_squash(Vector2(1.08, 0.92))
		kick_camera(4.0)

	_update_animation(delta)


func register_interactable(interactable: Node) -> void:
	if interactables.has(interactable):
		return
	interactables.append(interactable)
	_refresh_interactable()


func unregister_interactable(interactable: Node) -> void:
	interactables.erase(interactable)
	if current_interactable == interactable:
		current_interactable = null
	_refresh_interactable()


func kick_camera(intensity: float) -> void:
	if not camera:
		return
	camera.offset = Vector2(randf_range(-intensity, intensity), randf_range(-intensity * 0.6, intensity * 0.6))
	var tween := create_tween()
	tween.tween_property(camera, "offset", Vector2.ZERO, 0.28).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _refresh_interactable() -> void:
	# Keep only valid/active interactables, then choose the closest prompt source.
	interactables = interactables.filter(
		func(item):
			if not is_instance_valid(item):
				return false
			if item is Area2D:
				return item.monitoring
			return true
	)
	if interactables.is_empty():
		current_interactable = null
		GameManager.clear_prompt()
		return

	interactables.sort_custom(func(a, b): return global_position.distance_squared_to(a.global_position) < global_position.distance_squared_to(b.global_position))
	current_interactable = interactables[0]
	GameManager.set_prompt(current_interactable.prompt_text)


func _update_animation(delta: float) -> void:
	sprite.flip_h = facing < 0.0

	if not is_on_floor():
		sprite.texture = JUMP_TEXTURE
	elif landed_timer > 0.0 and absf(velocity.x) < 14.0:
		sprite.texture = LAND_TEXTURE
	elif absf(velocity.x) > 16.0:
		run_anim_timer += delta * 11.0
		sprite.texture = RUN_TEXTURE_1 if int(run_anim_timer) % 2 == 0 else RUN_TEXTURE_2
	else:
		run_anim_timer = 0.0
		sprite.texture = IDLE_TEXTURE

	shadow.scale.x = lerp(0.16, 0.22, clamp(absf(velocity.x) / WALK_SPEED, 0.0, 1.0))


func _apply_squash(target_scale: Vector2) -> void:
	if squash_tween:
		squash_tween.kill()

	visual_root.scale = target_scale
	squash_tween = create_tween()
	squash_tween.tween_property(visual_root, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
