extends BaseLevel

# Intro chamber: teaches dimension switching for route traversal.

func _init() -> void:
	level_name = "Level 1 - Chamber Split"
	objective_text = "Shift dimensions to bypass the blocked route, cross the chasm, then return to the exit lane."
	level_size = Vector2(1600, 720)
	spawn_position = Vector2(160, 520)
	fail_y = 900.0


func build_level() -> void:
	add_platform(Rect2(0, 592, 1600, 92), 0, Color("B8F7FF"))
	add_platform(Rect2(0, 592, 660, 92), 1, Color("FFC570"))
	add_platform(Rect2(960, 592, 640, 92), 1, Color("FFC570"))

	add_dimension_anchor(Vector2(520, 520))
	add_dimension_anchor(Vector2(1160, 520))
	var orb := add_orb_blocker(Vector2(844, 490))
	var edge_block := CollisionShape2D.new()
	var edge_rect := RectangleShape2D.new()
	edge_rect.size = Vector2(36, 180)
	edge_block.shape = edge_rect
	edge_block.position = Vector2(-86, -30)
	orb.add_child(edge_block)

	var edge_block_right := CollisionShape2D.new()
	var edge_rect_right := RectangleShape2D.new()
	edge_rect_right.size = Vector2(36, 180)
	edge_block_right.shape = edge_rect_right
	edge_block_right.position = Vector2(86, -30)
	orb.add_child(edge_block_right)
	var door := add_exit_door(Vector2(1474, 498), false)
	door.unlock()

	add_fail_zone(Rect2(650, 650, 320, 110), "You slipped into the dimensional void.")
	add_glow(Vector2(640, 430), Vector2(0.56, 0.18), Color(1.0, 0.72, 0.35, 0.12), 1)
	add_glow(Vector2(1120, 400), Vector2(0.44, 0.16), Color(0.52, 1.0, 0.94, 0.12), 0)
