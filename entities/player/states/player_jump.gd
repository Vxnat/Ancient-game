extends State
## Player Jump state while rising after a jump.


func enter() -> void:
	var player := entity as Player
	if player != null:
		player.notify_state_entered(&"Jump")
		player.play_animation(&"jump")


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

	if Input.is_action_just_released("jump") and player.velocity.y < 0.0:
		player.velocity.y *= player.jump_cut_mult

	player.handle_horizontal_movement(delta, false)
	player.apply_platformer_gravity(delta)
	player.move_and_slide()

	if player.velocity.y >= 0.0:
		transition_requested.emit(self, &"Fall")
