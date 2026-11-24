extends State
## Player SpecialSkill state casting OverdriveBeam [U] while Overdrive or Fusion is active.

const WINDUP_TIME: float = 0.12
const TOTAL_DURATION: float = 0.42

var _elapsed: float = 0.0
var _beam_spawned: bool = false


func enter() -> void:
	var player := entity as Player
	if player == null:
		return
	_elapsed = 0.0
	_beam_spawned = false
	player.notify_state_entered(&"SpecialSkill")
	player.velocity.x *= 0.25
	player.play_animation(&"beam_cast" if player.has_animation(&"beam_cast") else &"ki_blast", true)


func physics_update(delta: float) -> void:
	var player := entity as Player
	if player == null:
		return

	_elapsed += delta
	player.velocity.x = move_toward(player.velocity.x, 0.0, 900.0 * delta)
	if not player.is_on_floor():
		player.apply_platformer_gravity(delta * 0.35)
		player.velocity.y = minf(player.velocity.y, 45.0)
	player.move_and_slide()

	if not _beam_spawned and _elapsed >= WINDUP_TIME:
		_beam_spawned = true
		player.spawn_overdrive_beam()

	if _elapsed >= TOTAL_DURATION:
		if not player.is_on_floor():
			transition_requested.emit(self, &"Fall")
		elif absf(player.get_move_input()) > 0.01:
			transition_requested.emit(self, &"Move")
		else:
			transition_requested.emit(self, &"Idle")
