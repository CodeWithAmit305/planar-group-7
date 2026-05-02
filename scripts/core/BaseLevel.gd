extends Node2D
class_name BaseLevel

const PLAYER_SCENE := preload("res://scenes/player/Player.tscn")
const BACKDROP_TEXTURE := preload("res://assets/sprites/backgrounds/lab_backdrop.svg")
const PLATFORM_TEXTURE := preload("res://assets/sprites/world/platform_panel.svg")
const GLOW_TEXTURE := preload("res://assets/sprites/fx/glow.svg")
const ORB_TEXTURE := preload("res://assets/sprites/world/orb_blocker.svg")

var level_name := "Containment Chamber"
var objective_text := "Escape the chamber."
var level_size := Vector2(1600, 720)
var spawn_position := Vector2(120, 520)
var fail_y := 860.0
var current_dimension := 0

var background_root: Node2D
var backdrop_sprite: Sprite2D
var shared_root: Node2D
var dimension_root_a: DimensionLayer
var dimension_root_b: DimensionLayer
var player: DimensionPlayer


func _ready() -> void:
	_build_shell()
	build_level()
	_spawn_player()
	apply_dimension_state()
	GameManager.register_level(self, level_name, objective_text, current_dimension)


func get_level_name() -> String:
	return level_name


func build_level() -> void:
	pass


func on_dimension_switched(_new_dimension: int) -> void:
	pass


func switch_dimension() -> void:
	if not GameManager.can_player_input():
		return

	current_dimension = 1 - current_dimension
	apply_dimension_state()
	AudioManager.play_sfx("switch")
	GameManager.notify_dimension_changed(current_dimension)
	GameManager.trigger_dimension_fx()
	if player:
		player.kick_camera(7.0)
	on_dimension_switched(current_dimension)


func apply_dimension_state() -> void:
	dimension_root_a.set_layer_state(current_dimension == 0)
	dimension_root_b.set_layer_state(current_dimension == 1)


func add_platform(rect: Rect2, dimension: int, tint: Color = Color(0.82, 0.95, 1.0, 1.0)) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	body.position = rect.position + rect.size * 0.5

	var shape := CollisionShape2D.new()
	var collision := RectangleShape2D.new()
	collision.size = rect.size
	shape.shape = collision
	body.add_child(shape)

	var sprite := Sprite2D.new()
	sprite.texture = PLATFORM_TEXTURE
	sprite.scale = Vector2(rect.size.x / 256.0, rect.size.y / 64.0)
	sprite.modulate = tint
	body.add_child(sprite)

	var top_glow := Sprite2D.new()
	top_glow.texture = GLOW_TEXTURE
	top_glow.scale = Vector2(rect.size.x / 320.0, 0.1)
	top_glow.position = Vector2(0, -rect.size.y * 0.36)
	top_glow.modulate = Color(tint.r, tint.g, tint.b, 0.28)
	body.add_child(top_glow)

	_get_dimension_root(dimension).add_child(body)
	return body


func add_dimension_anchor(position: Vector2) -> DimensionAnchor:
	var anchor := DimensionAnchor.new()
	anchor.position = position
	anchor.level = self
	shared_root.add_child(anchor)
	return anchor


func add_exit_door(position: Vector2, locked: bool) -> ExitDoor:
	var door := ExitDoor.new()
	door.position = position
	door.set_locked(locked)
	shared_root.add_child(door)
	return door


func add_fail_zone(rect: Rect2, message: String) -> FailZone:
	var zone := FailZone.new()
	zone.position = rect.position + rect.size * 0.5
	zone.zone_size = rect.size
	zone.fail_message = message
	shared_root.add_child(zone)
	return zone


func add_orb_blocker(position: Vector2) -> StaticBody2D:
	var blocker := StaticBody2D.new()
	blocker.position = position
	blocker.collision_layer = 1
	blocker.collision_mask = 0

	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 66
	shape.shape = circle
	shape.position = Vector2(0, -14)
	blocker.add_child(shape)

	var glow := Sprite2D.new()
	glow.texture = GLOW_TEXTURE
	glow.scale = Vector2(0.5, 0.5)
	glow.position = Vector2(0, -14)
	glow.modulate = Color(0.58, 0.94, 1.0, 0.28)
	blocker.add_child(glow)

	var sprite := Sprite2D.new()
	sprite.texture = ORB_TEXTURE
	sprite.position = Vector2(0, -14)
	sprite.scale = Vector2(1.0, 1.0)
	blocker.add_child(sprite)

	dimension_root_a.add_child(blocker)
	return blocker


func add_glow(position: Vector2, scale: Vector2, color: Color, dimension: int = -1) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = GLOW_TEXTURE
	sprite.position = position
	sprite.scale = scale
	sprite.modulate = color
	if dimension == -1:
		shared_root.add_child(sprite)
	else:
		_get_dimension_root(dimension).add_child(sprite)
	return sprite


func add_sprite(texture: Texture2D, position: Vector2, scale: Vector2, dimension: int = -1, tint: Color = Color.WHITE) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = position
	sprite.scale = scale
	sprite.modulate = tint
	if dimension == -1:
		shared_root.add_child(sprite)
	else:
		_get_dimension_root(dimension).add_child(sprite)
	return sprite


func _build_shell() -> void:
	background_root = Node2D.new()
	add_child(background_root)

	backdrop_sprite = Sprite2D.new()
	backdrop_sprite.texture = BACKDROP_TEXTURE
	backdrop_sprite.position = level_size * 0.5
	background_root.add_child(backdrop_sprite)
	_update_backdrop_scale()

	shared_root = Node2D.new()
	add_child(shared_root)

	dimension_root_a = DimensionLayer.new()
	add_child(dimension_root_a)

	dimension_root_b = DimensionLayer.new()
	dimension_root_b.inactive_modulate = Color(1.0, 0.74, 0.38, 0.14)
	add_child(dimension_root_b)

	_build_common_dressing()


func _build_common_dressing() -> void:
	add_glow(Vector2(level_size.x * 0.18, level_size.y * 0.26), Vector2(0.6, 0.24), Color(0.48, 1.0, 1.0, 0.14))
	add_glow(Vector2(level_size.x * 0.72, level_size.y * 0.24), Vector2(0.7, 0.28), Color(1.0, 0.7, 0.32, 0.08))
	add_glow(Vector2(level_size.x * 0.52, level_size.y * 0.74), Vector2(1.2, 0.18), Color(0.42, 1.0, 0.92, 0.10))

	for x in [180.0, 560.0, 940.0, 1320.0]:
		var line := Line2D.new()
		line.width = 2.0
		line.default_color = Color(0.55, 0.98, 1.0, 0.08)
		line.points = PackedVector2Array([Vector2(x, 0), Vector2(x, level_size.y)])
		background_root.add_child(line)


func _spawn_player() -> void:
	player = PLAYER_SCENE.instantiate()
	player.position = spawn_position
	player.configure_camera_bounds(Rect2(Vector2.ZERO, level_size))
	add_child(player)


func _process(_delta: float) -> void:
	if player and player.position.y > fail_y and GameManager.state == "playing":
		GameManager.fail_level("You fell outside the chamber bounds.")


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_SIZE_CHANGED:
		_update_backdrop_scale()


func _update_backdrop_scale() -> void:
	if not backdrop_sprite:
		return

	var viewport_size := get_viewport_rect().size
	var desired_size := level_size + viewport_size
	backdrop_sprite.scale = Vector2(desired_size.x / 1920.0, desired_size.y / 1080.0)


func _get_dimension_root(dimension: int) -> Node2D:
	return dimension_root_a if dimension == 0 else dimension_root_b
