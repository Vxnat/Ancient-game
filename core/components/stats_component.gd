class_name StatsComponent
extends Node
## Holds base and form-modified combat/movement statistics for an entity.

signal stats_updated()

@export var base_attack_damage: float = 10.0
@export var base_move_speed: float = 230.0
@export var base_jump_velocity: float = -470.0
@export var damage_multiplier: float = 1.0
@export var speed_multiplier: float = 1.0

var active_form: FormData


func apply_form(form: FormData) -> void:
	active_form = form
	if form != null:
		damage_multiplier = form.damage_multiplier
		speed_multiplier = form.speed_multiplier
	else:
		damage_multiplier = 1.0
		speed_multiplier = 1.0
	stats_updated.emit()


func get_attack_damage(weapon_bonus: float = 0.0) -> float:
	return (base_attack_damage + weapon_bonus) * damage_multiplier


func get_move_speed() -> float:
	return base_move_speed * speed_multiplier
