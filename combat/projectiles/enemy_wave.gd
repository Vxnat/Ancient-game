class_name EnemyWave
extends Node2D
## Horizontal energy shockwave fired by RuinsSentinel on enemy_hitbox layer.

@export var speed: float = 210.0
@export var lifetime: float = 1.6

@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var wall_detector: Area2D = $WallDetector

var direction: int = 1
var _age: float = 0.0
var _consumed: bool = false


func setup(spawn_pos: Vector2, dir: int, damage_amount: float, shooter: Node2D) -> void:
	global_position = spawn_pos
	direction = 1 if dir >= 0 else -1
	scale.x = float(direction)
	if hitbox_component != null:
		hitbox_component.damage = damage_amount
		hitbox_component.source_entity = shooter
		hitbox_component.set_active(true)


func _ready() -> void:
	hitbox_component.hit_landed.connect(_on_hit)
	wall_detector.body_entered.connect(_on_wall)
	hitbox_component.set_active(true)


func _physics_process(delta: float) -> void:
	if _consumed:
		return
	position.x += float(direction) * speed * delta
	_age += delta
	if _age >= lifetime:
		queue_free()


func _on_hit(_hurtbox: HurtboxComponent) -> void:
	_consume()


func _on_wall(_body: Node2D) -> void:
	_consume()


func _consume() -> void:
	if _consumed:
		return
	_consumed = true
	hitbox_component.set_active(false)
	queue_free()
