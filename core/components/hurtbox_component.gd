class_name HurtboxComponent
extends Area2D
## Receives damage from overlapping HitboxComponent areas and forwards it to HealthComponent.

signal hit_received(hitbox: HitboxComponent, damage: float)

@export var health_component: HealthComponent


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	if area is HitboxComponent:
		var hitbox := area as HitboxComponent
		if not hitbox.register_hit(self):
			return
		if health_component != null:
			health_component.take_damage(hitbox.damage)
		hit_received.emit(hitbox, hitbox.damage)
		hitbox.hit_landed.emit(self)
