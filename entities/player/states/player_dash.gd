extends State
## Player Dash state providing a burst of horizontal speed, afterimage ghosts, and invulnerability.

const GHOST_INTERVAL: float = 0.03

var _timer: float = 0.0
var _ghost_timer: float = 0.0


func enter() -> void:
	var player := entity as Player
	if player == null:
		return
	player.notify_state_entered(&"Dash")
	_timer = player.dash_duration
	_ghost_timer = 0.0
	player.dash_cooldown_timer = player.dash_cooldown
	player.health_component.is_invulnerable = true

	var input_dir: float = player.get_move_input()
	if input_dir != 0.0:
		player.set_facing(input_dir)

	player.play_animation(&"dash")
	player.velocity = Vector2(player.facing_direction * player.dash_speed, 0.0)
	player.play_squash(Vector2(1.18, 0.85), 0.14)
	player.spawn_dash_ghost()


func exit() -> void:
	var player := entity as Player
	if player != null:
		player.health_component.is_invulnerable = false


func physics_update(delta: float) -> void:
	var player := entity as Player
	if player == null:
		return

	if Input.is_action_just_pressed("attack"):
		transition_requested.emit(self, &"DashAttack")
		return

	_timer -= delta
	_ghost_timer += delta
	if _ghost_timer >= GHOST_INTERVAL:
		_ghost_timer = 0.0
		player.spawn_dash_ghost()

	player.velocity.y = 0.0
	player.move_and_slide()

	if _timer <= 0.0:
		player.velocity.x *= 0.45
		if player.is_on_floor():
			transition_requested.emit(self, &"Idle")
		else:
			transition_requested.emit(self, &"Fall")
