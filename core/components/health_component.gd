class_name HealthComponent
extends Node
## Reusable health pool for Player, Allies, Enemies, and Bosses.

signal health_changed(current: float, maximum: float)
signal damaged(amount: float)
signal healed(amount: float)
signal died()

@export var max_health: float = 100.0
var current_health: float = 100.0
var is_invulnerable: bool = false


func _ready() -> void:
	current_health = max_health


func initialize(new_max: float, new_current: float = -1.0) -> void:
	max_health = maxf(1.0, new_max)
	current_health = max_health if new_current < 0.0 else clampf(new_current, 0.0, max_health)
	health_changed.emit(current_health, max_health)


func take_damage(amount: float) -> void:
	if is_invulnerable or current_health <= 0.0 or amount <= 0.0:
		return
	current_health = maxf(0.0, current_health - amount)
	damaged.emit(amount)
	health_changed.emit(current_health, max_health)
	if current_health <= 0.0:
		died.emit()


func heal(amount: float) -> void:
	if current_health <= 0.0 or amount <= 0.0:
		return
	current_health = minf(max_health, current_health + amount)
	healed.emit(amount)
	health_changed.emit(current_health, max_health)
