extends State
## Player PowerDown state playing the Overdrive detransformation animation before reverting to Base Adult.

const TRANSFORM_OUT_DURATION: float = 0.40

var _elapsed: float = 0.0
var _completed: bool = false


func enter() -> void:
	var player := entity as Player
	if player == null:
		return
	_elapsed = 0.0
	_completed = false
	player.notify_state_entered(&"PowerDown")
	player.velocity.x = 0.0
	player.begin_overdrive_out_visual()


func exit() -> void:
	var player := entity as Player
	if player == null:
		return
	player.end_transform_frame_offset()
	if not _completed and player.is_overdrive_active:
		player.set_overdrive(false)


func physics_update(delta: float) -> void:
	var player := entity as Player
	if player == null:
		return

	_elapsed += delta
	if not player.is_on_floor():
		player.apply_platformer_gravity(delta)
	player.move_and_slide()

	if _elapsed >= TRANSFORM_OUT_DURATION:
		_completed = true
		player.end_transform_frame_offset()
		if player.is_overdrive_active:
			player.set_overdrive(false)
		if not player.is_on_floor():
			transition_requested.emit(self, &"Fall")
		elif absf(player.get_move_input()) > 0.01:
			transition_requested.emit(self, &"Move")
		else:
			transition_requested.emit(self, &"Idle")
