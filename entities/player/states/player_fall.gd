extends State
## Player Fall state while descending or walking off ledges.


func enter() -> void:
	var player := entity as Player
	if player != null:
		player.notify_state_entered(&"Fall")
		player.play_animation(&"fall")


func physics_update(delta: float) -> void:
	var player := entity as Player
	if player == null:
		return

	if Input.is_action_just_pressed("attack"):
		transition_requested.emit(self, &"AirAttack")
		return
	if Input.is_action_just_pressed("ki_blast") and player.can_cast_ki_blast():
		transition_requested.emit(self, &"KiBlast")
		return
	if Input.is_action_just_pressed("special_skill") and player.can_use_special_skill():
		transition_requested.emit(self, &"SpecialSkill")
		return
	if Input.is_action_just_pressed("dash") and player.can_air_dash():
		player.consume_air_dash()
		transition_requested.emit(self, &"Dash")
		return
	if player.can_consume_buffered_jump():
		player.consume_jump()
		transition_requested.emit(self, &"Jump")
		return

	player.handle_horizontal_movement(delta, false)
	player.apply_platformer_gravity(delta)
	player.move_and_slide()

	if player.is_on_floor():
		player.play_squash(Vector2(1.16, 0.84), 0.12)
		if absf(player.get_move_input()) > 0.01:
			transition_requested.emit(self, &"Move")
		else:
			transition_requested.emit(self, &"Idle")
