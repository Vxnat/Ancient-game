extends State
## Player Attack state handling a 3-hit melee combo with input buffering and Step-3 lunge.

const COMBO_RESET_WINDOW: float = 0.45
const BUFFER_ACCEPT_TIME: float = 0.08

const COMBO_STEPS: Array[Dictionary] = [
	{
		"duration": 0.34,
		"hit_start": 0.11,
		"hit_end": 0.23,
		"damage_mult": 1.0,
		"range_mult": 1.0,
		"knockback_mult": 1.0,
		"hitstop_mult": 1.0,
		"lunge_speed": 90.0,
	},
	{
		"duration": 0.36,
		"hit_start": 0.11,
		"hit_end": 0.25,
		"damage_mult": 1.15,
		"range_mult": 1.12,
		"knockback_mult": 1.15,
		"hitstop_mult": 1.0,
		"lunge_speed": 115.0,
	},
	{
		"duration": 0.44,
		"hit_start": 0.14,
		"hit_end": 0.31,
		"damage_mult": 1.45,
		"range_mult": 1.25,
		"knockback_mult": 1.65,
		"hitstop_mult": 1.4,
		"lunge_speed": 290.0,
	},
]

var _step_index: int = 0
var _elapsed: float = 0.0
var _hitbox_on: bool = false
var _combo_queued: bool = false


func enter() -> void:
	var player := entity as Player
	if player == null:
		return
	player.notify_state_entered(&"Attack")
	var start_step: int = player.combo_step if player.combo_reset_timer > 0.0 else 0
	_start_step(player, clampi(start_step, 0, COMBO_STEPS.size() - 1))


func exit() -> void:
	var player := entity as Player
	if player != null:
		player.hitbox_component.set_active(false)
		player.attack_hitstop_mult = 1.0


func physics_update(delta: float) -> void:
	var player := entity as Player
	if player == null:
		return

	if Input.is_action_just_pressed("dash"):
		if player.can_dash() if player.is_on_floor() else player.can_air_dash():
			player.combo_step = 0
			player.combo_reset_timer = 0.0
			transition_requested.emit(self, &"Dash")
			return

	_elapsed += delta
	var cfg: Dictionary = COMBO_STEPS[_step_index]

	if _step_index < COMBO_STEPS.size() - 1 and _elapsed >= BUFFER_ACCEPT_TIME:
		if Input.is_action_just_pressed("attack"):
			_combo_queued = true

	var should_hit: bool = _elapsed >= float(cfg["hit_start"]) and _elapsed <= float(cfg["hit_end"])
	if should_hit != _hitbox_on:
		_hitbox_on = should_hit
		player.hitbox_component.set_active(_hitbox_on)

	if player.is_on_floor():
		player.velocity.x = move_toward(player.velocity.x, 0.0, 1400.0 * delta)
	else:
		player.handle_horizontal_movement(delta, false)
		player.apply_platformer_gravity(delta)
	player.move_and_slide()

	if _elapsed >= float(cfg["duration"]):
		if _combo_queued and _step_index < COMBO_STEPS.size() - 1:
			_start_step(player, _step_index + 1)
			return

		if _step_index < COMBO_STEPS.size() - 1:
			player.combo_step = _step_index + 1
			player.combo_reset_timer = COMBO_RESET_WINDOW
		else:
			player.combo_step = 0
			player.combo_reset_timer = 0.0

		if not player.is_on_floor():
			transition_requested.emit(self, &"Fall")
		elif absf(player.get_move_input()) > 0.01:
			transition_requested.emit(self, &"Move")
		else:
			transition_requested.emit(self, &"Idle")


func _start_step(player: Player, step: int) -> void:
	_step_index = step
	_elapsed = 0.0
	_hitbox_on = false
	_combo_queued = false
	player.hitbox_component.set_active(false)

	var move_dir: float = player.get_move_input()
	if absf(move_dir) > 0.01:
		player.set_facing(move_dir)

	var cfg: Dictionary = COMBO_STEPS[_step_index]
	player.attack_hitstop_mult = float(cfg["hitstop_mult"])
	player.configure_attack_hitbox(
		float(cfg["damage_mult"]),
		float(cfg["range_mult"]),
		float(cfg["knockback_mult"])
	)

	var prefix: String = "attack_bare_" if player.is_using_bare_hands() else "attack_weapon_"
	var anim_name := StringName("%s%d" % [prefix, _step_index + 1])
	player.play_animation(anim_name, true)

	if player.is_on_floor():
		player.velocity.x = float(player.facing_direction) * float(cfg["lunge_speed"])
	elif _step_index == COMBO_STEPS.size() - 1:
		player.velocity.x = float(player.facing_direction) * float(cfg["lunge_speed"]) * 0.6
