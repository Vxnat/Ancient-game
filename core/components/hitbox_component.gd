class_name HitboxComponent
extends Area2D
## Deals damage once per activation when overlapping a HurtboxComponent.

signal hit_landed(hurtbox: HurtboxComponent)

@export var damage: float = 10.0
@export var knockback_force: Vector2 = Vector2(140.0, -70.0)
@export var source_entity: Node2D

var _hit_targets: Array[HurtboxComponent] = []


func _ready() -> void:
	set_active(false)


func set_active(active: bool) -> void:
	if active:
		_hit_targets.clear()
	set_deferred("monitoring", active)
	set_deferred("monitorable", active)
	for child in get_children():
		if child is CollisionShape2D:
			(child as CollisionShape2D).set_deferred("disabled", not active)


func register_hit(hurtbox: HurtboxComponent) -> bool:
	if hurtbox in _hit_targets:
		return false
	_hit_targets.append(hurtbox)
	return true
