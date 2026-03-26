extends BaseLevel

# Security sprint chamber with moving platforms and a temporary gate window.
var final_exit: ExitDoor
var sweep_gate: ExitDoor
var gate_switch: TimedSwitch
var gate_timer: Timer


func _init() -> void:
	level_name = "Level 4 - Security Sweep"
	objective_text = "Climb the security hall, pulse the sweep shutter, shift back to the prime lane, and dive through before it locks again."
	level_size = Vector2(1900, 860)
	spawn_position = Vector2(150, 640)
	fail_y = 1040.0


func build_level() -> void:
	add_platform(Rect2(0, 712, 360, 120), 0, Color("B8F7FF"))
	add_platform(Rect2(0, 712, 360, 120), 1, Color("FFC570"))
	add_platform(Rect2(780, 612, 220, 36), 1, Color("FFD189"))
	add_platform(Rect2(1120, 532, 220, 36), 1, Color("FFD189"))
	add_platform(Rect2(1460, 452, 150, 36), 1, Color("FFD189"))
	add_platform(Rect2(1540, 452, 360, 36), 0, Color("B8F7FF"))
	add_platform(Rect2(1710, 372, 190, 36), 0, Color("C5FAFF"))

	add_fail_zone(Rect2(360, 780, 420, 140), "Security beams dropped you into the service trench.")
	add_fail_zone(Rect2(1000, 780, 380, 140), "You slipped below the suspended sweep lane.")

	_add_platform_carrier(
		dimension_root_a,
		Vector2(470, 642),
		Vector2(720, 642),
		1.9,
		Vector2(170, 34),
		Color("9DF8FF")
	)
	_add_platform_carrier(
		dimension_root_b,
		Vector2(980, 582),
		Vector2(1240, 582),
		1.65,
		Vector2(160, 34),
		Color("FFCA79")
	)

	add_dimension_anchor(Vector2(720, 618))
	add_dimension_anchor(Vector2(1678, 398))

	gate_switch = TimedSwitch.new()
	gate_switch.position = Vector2(1512, 392)
	gate_switch.cooldown_duration = 1.55
	gate_switch.activated.connect(_on_gate_switch_activated)
	shared_root.add_child(gate_switch)

	sweep_gate = add_exit_door(Vector2(1654, 358), true)
	sweep_gate.completes_level = false

	final_exit = add_exit_door(Vector2(1842, 278), false)
	final_exit.unlock()

	gate_timer = Timer.new()
	gate_timer.one_shot = true
	gate_timer.timeout.connect(_on_gate_timeout)
	add_child(gate_timer)

	add_glow(Vector2(612, 640), Vector2(0.38, 0.14), Color(0.48, 1.0, 0.92, 0.16), 0)
	add_glow(Vector2(1110, 580), Vector2(0.34, 0.14), Color(1.0, 0.72, 0.35, 0.18), 1)
	add_glow(Vector2(1660, 330), Vector2(0.24, 0.18), Color(1.0, 0.72, 0.35, 0.22))


func _on_gate_switch_activated() -> void:
	sweep_gate.set_locked(false)
	GameManager.update_objective("Sweep gate open. Shift back and dive through before it seals.")
	gate_timer.start(1.15)


func _on_gate_timeout() -> void:
	sweep_gate.set_locked(true)
	GameManager.update_objective("Climb the hall, pulse the sweep shutter, then shift back and dive through.")


func _add_platform_carrier(
	root: Node2D,
	start_point: Vector2,
	end_point: Vector2,
	duration: float,
	size: Vector2,
	tint: Color
) -> void:
	var platform := MovingPlatform.new()
	platform.start_position = start_point
	platform.end_position = end_point
	platform.move_duration = duration
	platform.platform_size = size
	platform.tint = tint
	root.add_child(platform)
