extends BaseLevel

# Pressure-pad synchronization puzzle with timed carryover between dimensions.
var exit_door: ExitDoor
var prime_pad: PressurePad
var shift_pad: PressurePad
var sync_timer: Timer
var first_pad_charged := false
var second_pad_charged := false
var synced := false


func _init() -> void:
	level_name = "Level 2 - Pressure Sync"
	objective_text = "Charge the prime pressure pad, shift before the charge decays, then reach the shift pad to sync both locks and open the exit."
	level_size = Vector2(1720, 760)
	spawn_position = Vector2(150, 560)
	fail_y = 940.0


func build_level() -> void:
	add_platform(Rect2(0, 632, 460, 110), 0, Color("B8F7FF"))
	add_platform(Rect2(0, 632, 460, 110), 1, Color("FFC570"))
	add_platform(Rect2(520, 552, 180, 34), 0, Color("C5FAFF"))
	add_platform(Rect2(720, 632, 230, 110), 0, Color("B8F7FF"))
	add_platform(Rect2(720, 632, 230, 110), 1, Color("FFC570"))
	add_platform(Rect2(980, 562, 260, 34), 1, Color("FFD189"))
	add_platform(Rect2(1280, 522, 280, 34), 1, Color("FFD189"))
	add_platform(Rect2(1500, 632, 220, 110), 0, Color("B8F7FF"))
	add_platform(Rect2(1500, 632, 220, 110), 1, Color("FFC570"))

	add_fail_zone(Rect2(460, 700, 250, 110), "The sync trench dropped you below the test deck.")
	add_fail_zone(Rect2(950, 700, 500, 110), "You lost footing in the chamber gap.")

	add_dimension_anchor(Vector2(820, 560))
	add_dimension_anchor(Vector2(1480, 560))

	prime_pad = PressurePad.new()
	prime_pad.position = Vector2(610, 528)
	prime_pad.accent = Color("6FF8FF")
	prime_pad.active_accent = Color("79ffac")
	prime_pad.pressed.connect(_on_prime_pad_pressed)
	dimension_root_a.add_child(prime_pad)

	shift_pad = PressurePad.new()
	shift_pad.position = Vector2(1410, 498)
	shift_pad.accent = Color("FFB24B")
	shift_pad.active_accent = Color("79ffac")
	shift_pad.pressed.connect(_on_shift_pad_pressed)
	dimension_root_b.add_child(shift_pad)

	exit_door = add_exit_door(Vector2(1638, 538), true)

	sync_timer = Timer.new()
	sync_timer.one_shot = true
	sync_timer.timeout.connect(_on_sync_timeout)
	add_child(sync_timer)

	add_glow(Vector2(610, 504), Vector2(0.22, 0.12), Color(0.48, 1.0, 0.92, 0.18), 0)
	add_glow(Vector2(1410, 472), Vector2(0.22, 0.12), Color(1.0, 0.72, 0.35, 0.18), 1)


func _on_prime_pad_pressed() -> void:
	if synced:
		return

	first_pad_charged = true
	prime_pad.set_active(true)
	GameManager.update_objective("Prime lock charged. Shift and reach the second pad before the sync drains.")
	sync_timer.start(4.8)
	AudioManager.play_sfx("interact")


func _on_shift_pad_pressed() -> void:
	if synced:
		return

	if not first_pad_charged:
		GameManager.update_objective("The shift pad is cold. Charge the prime pad first, then come back fast.")
		AudioManager.play_sfx("fail")
		return

	second_pad_charged = true
	shift_pad.set_active(true)
	synced = true
	sync_timer.stop()
	exit_door.unlock()
	GameManager.update_objective("Pressure sync achieved. Shift back if needed and move through the unlocked door.")
	AudioManager.play_sfx("success")


func _on_sync_timeout() -> void:
	if synced:
		return

	first_pad_charged = false
	second_pad_charged = false
	prime_pad.set_active(false)
	shift_pad.set_active(false)
	GameManager.update_objective("The prime pad charge decayed. Re-arm it and try to sync both locks faster.")
