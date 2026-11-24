class_name GameCamera
extends Camera2D
## Smooth follow camera with trauma-based screen shake that decays in real time during hitstop.

@export var follow_target: Node2D
@export var follow_smoothing: float = 10.0
@export var decay_rate: float = 1.8
@export var max_offset: Vector2 = Vector2(10.0, 7.0)
@export var max_roll: float = 0.04
@export var shake_strength: float = 1.0

var _trauma: float = 0.0
var _noise_time: float = 0.0


func _ready() -> void:
	ignore_rotation = false
	add_to_group(&"game_camera")
	if follow_target != null:
		global_position = follow_target.global_position


func add_trauma(amount: float) -> void:
	_trauma = clampf(_trauma + amount, 0.0, 1.0)


func _process(delta: float) -> void:
	var real_dt: float = delta / maxf(Engine.time_scale, 0.0001)
	if follow_target != null:
		global_position = global_position.lerp(follow_target.global_position, minf(1.0, follow_smoothing * real_dt))

	if _trauma <= 0.0:
		return

	_trauma = maxf(0.0, _trauma - decay_rate * real_dt)
	var shake: float = _trauma * _trauma * shake_strength
	_noise_time += real_dt * 32.0
	offset = Vector2(
		max_offset.x * shake * sin(_noise_time * 1.7),
		max_offset.y * shake * sin(_noise_time * 2.3)
	)
	rotation = max_roll * shake * sin(_noise_time * 1.1)
	if _trauma <= 0.0:
		offset = Vector2.ZERO
		rotation = 0.0
