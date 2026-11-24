extends State
## Player KiBlast state firing a decoupled Ki energy projectile.

const CAST_DURATION: float = 0.20
var _elapsed: float = 0.0


func enter() -> void:
	var player := entity as Player
	if player == null:
		return
	player.notify_state_entered(&"KiBlast")
	_elapsed = 0.0
	player.play_animation(&"ki_blast")
	player.fire_ki_blast()


func physics_update(delta: float) -> void:
	var player := entity as Player
	if player == null:
		return

	_elapsed += delta
	player.handle_horizontal_movement(delta, player.is_on_floor())
	if not player.is_on_floor():
		player.apply_platformer_gravity(delta)
	player.move_and_slide()

	if _elapsed >= CAST_DURATION:
		if not player.is_on_floor():
			transition_requested.emit(self, &"Fall")
		elif absf(player.get_move_input()) > 0.01:
			transition_requested.emit(self, &"Move")
		else:
			transition_requested.emit(self, &"Idle")
