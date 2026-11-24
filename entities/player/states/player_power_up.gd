extends State
## Player PowerUp charge state: bursts KiAura before completing Overdrive or Fusion.

const CHARGE_DURATION: float = 0.45

var _elapsed: float = 0.0


func enter() -> void:
	var player := entity as Player
	if player == null:
		return
	player.notify_state_entered(&"PowerUp")
	_elapsed = 0.0
	player.health_component.is_invulnerable = true
	player.set_power_up_aura(true, player.pending_power_up_mode)
	player.play_squash(Vector2(1.18, 0.86), 0.16)
	player.add_trauma(0.28)


func exit() -> void:
	var player := entity as Player
	if player != null:
		player.health_component.is_invulnerable = false
		player.set_power_up_aura(false, &"")


func physics_update(delta: float) -> void:
	var player := entity as Player
	if player == null:
		return

	_elapsed += delta
	player.velocity.x = move_toward(player.velocity.x, 0.0, 2200.0 * delta)
	if not player.is_on_floor():
		player.apply_platformer_gravity(delta)
	player.move_and_slide()

	if _elapsed >= CHARGE_DURATION:
		player.complete_pending_power_up()
		if not player.is_on_floor():
			transition_requested.emit(self, &"Fall")
		elif absf(player.get_move_input()) > 0.01:
			transition_requested.emit(self, &"Move")
		else:
			transition_requested.emit(self, &"Idle")
