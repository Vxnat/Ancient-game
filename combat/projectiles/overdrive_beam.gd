class_name OverdriveBeam
extends Node2D
## High-power piercing energy wave unleashed during transformed Special Skill [U].

const DRIFT_SPEED: float = 35.0
const ACTIVE_WINDOW: float = 0.24
const MAX_LIFETIME: float = 0.42

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: HitboxComponent = $HitboxComponent

var _direction: float = 1.0
var _elapsed: float = 0.0
var _active: bool = true


func setup(direction_x: float, damage_amount: float, beam_source: Node2D) -> void:
	_direction = -1.0 if direction_x < 0.0 else 1.0
	scale.x = _direction
	if is_node_ready():
		_apply_setup(damage_amount, beam_source)
	else:
		ready.connect(_apply_setup.bind(damage_amount, beam_source), CONNECT_ONE_SHOT)


func _apply_setup(damage_amount: float, beam_source: Node2D) -> void:
	hitbox.damage = damage_amount
	hitbox.source_entity = beam_source
	hitbox.knockback_force = Vector2(220.0 * _direction, -95.0)
	hitbox.set_active(true)
	sprite.play(&"beam")


func _ready() -> void:
	if not sprite.animation_finished.is_connected(_on_animation_finished):
		sprite.animation_finished.connect(_on_animation_finished)


func _physics_process(delta: float) -> void:
	_elapsed += delta
	position.x += _direction * DRIFT_SPEED * delta
	if _active and _elapsed >= ACTIVE_WINDOW:
		_active = false
		hitbox.set_active(false)
	if _elapsed >= MAX_LIFETIME:
		queue_free()


func _on_animation_finished() -> void:
	hitbox.set_active(false)
	queue_free()
