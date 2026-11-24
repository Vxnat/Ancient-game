extends State
## Player Move state when running horizontally on the ground.


func enter() -> void:
	var player := entity as Player
	if player != null:
		player.notify_state_entered(&"Move")
		player.play_animation(&"run")


func physics_update(delta: float) -> void:
	var player := entity as Player
	if player == null:
		return

	if Input.is_action_just_pressed("attack"):
		transition_requested.emit(self, &"Attack")
		return
	if Input.is_action_just_pressed("ki_blast") and player.can_cast_ki_blast():
		transition_requested.emit(self, &"KiBlast")
		return
	if Input.is_action_just_pressed("special_skill") and player.can_use_special_skill():
		transition_requested.emit(self, &"SpecialSkill")
		return
	if Input.is_action_just_pressed("dash") and player.can_dash():
		transition_requested.emit(self, &"Dash")
		return
	if player.can_consume_buffered_jump():
		player.consume_jump()
		transition_requested.emit(self, &"Jump")
		return

	player.handle_horizontal_movement(delta, true)
	player.apply_platformer_gravity(delta)
	player.move_and_slide()

	if not player.is_on_floor():
		transition_requested.emit(self, &"Fall")
		return
	if absf(player.get_move_input()) <= 0.01 and absf(player.velocity.x) < 5.0:
		transition_requested.emit(self, &"Idle")
