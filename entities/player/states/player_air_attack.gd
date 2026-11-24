extends State
## Player AirAttack state for single crisp mid-air strikes with light hang-time.

const ATTACK_DURATION: float = 0.34
const HITBOX_START: float = 0.10
const HITBOX_END: float = 0.24

var _elapsed: float = 0.0
var _hitbox_on: bool = false


func enter() -> void:
	var player := entity as Player
	if player == null:
		return
	player.notify_state_entered(&"AirAttack")
	_elapsed = 0.0
	_hitbox_on = false
	player.combo_step = 0
	player.combo_reset_timer = 0.0
	player.attack_hitstop_mult = 1.1
	player.configure_attack_hitbox(1.1, 1.1, 1.1)

	var anim: StringName = player.get_melee_air_anim()
	player.play_animation(anim, true)
	if player.velocity.y > 0.0:
		player.velocity.y *= 0.35


func exit() -> void:
	var player := entity as Player
	if player != null:
		player.hitbox_component.set_active(false)
		player.attack_hitstop_mult = 1.0


func physics_update(delta: float) -> void:
	var player := entity as Player
	if player == null:
		return

	if Input.is_action_just_pressed("dash") and player.can_air_dash():
		player.consume_air_dash()
		transition_requested.emit(self, &"Dash")
		return

	_elapsed += delta
	var should_hit: bool = _elapsed >= HITBOX_START and _elapsed <= HITBOX_END
	if should_hit != _hitbox_on:
		_hitbox_on = should_hit
		player.hitbox_component.set_active(_hitbox_on)

	player.handle_horizontal_movement(delta, false)
	var old_vy: float = player.velocity.y
	player.apply_platformer_gravity(delta)
	if player.velocity.y > 0.0 and _elapsed < HITBOX_END:
		player.velocity.y = lerpf(old_vy, player.velocity.y, 0.45)
	player.move_and_slide()

	if player.is_on_floor():
		player.play_squash(Vector2(1.14, 0.86), 0.10)
		if absf(player.get_move_input()) > 0.01:
			transition_requested.emit(self, &"Move")
		else:
			transition_requested.emit(self, &"Idle")
		return

	if _elapsed >= ATTACK_DURATION:
		transition_requested.emit(self, &"Fall")
