extends State
## Player DashAttack state chaining out of Dash into a fast lunging thrust with afterimages.

const ATTACK_DURATION: float = 0.34
const HITBOX_START: float = 0.05
const HITBOX_END: float = 0.24
const THRUST_SPEED: float = 330.0
const GHOST_INTERVAL: float = 0.045
const GHOST_WINDOW: float = 0.14

var _elapsed: float = 0.0
var _ghost_timer: float = 0.0
var _hitbox_on: bool = false


func enter() -> void:
	var player := entity as Player
	if player == null:
		return
	player.notify_state_entered(&"DashAttack")
	_elapsed = 0.0
	_ghost_timer = 0.0
	_hitbox_on = false
	player.combo_step = 0
	player.combo_reset_timer = 0.0
	player.attack_hitstop_mult = 1.2
	player.configure_attack_hitbox(1.25, 1.2, 1.4)

	var anim: StringName = player.get_melee_dash_anim()
	player.play_animation(anim, true)
	player.velocity.x = float(player.facing_direction) * THRUST_SPEED
	if not player.is_on_floor():
		player.velocity.y = 0.0
	player.spawn_dash_ghost()


func exit() -> void:
	var player := entity as Player
	if player != null:
		player.hitbox_component.set_active(false)
		player.attack_hitstop_mult = 1.0


func physics_update(delta: float) -> void:
	var player := entity as Player
	if player == null:
		return

	_elapsed += delta
	if _elapsed <= GHOST_WINDOW:
		_ghost_timer += delta
		if _ghost_timer >= GHOST_INTERVAL:
			_ghost_timer = 0.0
			player.spawn_dash_ghost()

	var should_hit: bool = _elapsed >= HITBOX_START and _elapsed <= HITBOX_END
	if should_hit != _hitbox_on:
		_hitbox_on = should_hit
		player.hitbox_component.set_active(_hitbox_on)

	player.velocity.x = move_toward(player.velocity.x, 0.0, 1100.0 * delta)
	if not player.is_on_floor() and _elapsed > 0.10:
		player.apply_platformer_gravity(delta)
	player.move_and_slide()

	if _elapsed >= ATTACK_DURATION:
		if not player.is_on_floor():
			transition_requested.emit(self, &"Fall")
		elif absf(player.get_move_input()) > 0.01:
			transition_requested.emit(self, &"Move")
		else:
			transition_requested.emit(self, &"Idle")
