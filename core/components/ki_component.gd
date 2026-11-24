class_name KiComponent
extends Node
## Manages Ki energy for dashes, Ki blasts, Overdrive, and Fusion.

signal ki_changed(current: float, maximum: float)
signal ki_depleted()

@export var max_ki: float = 100.0
@export var passive_regen_per_sec: float = 4.0

var current_ki: float = 100.0
var is_draining: bool = false


func _ready() -> void:
	current_ki = max_ki


func _process(delta: float) -> void:
	if not is_draining and current_ki < max_ki and passive_regen_per_sec > 0.0:
		restore_ki(passive_regen_per_sec * delta)


func initialize(new_max: float, new_current: float = -1.0) -> void:
	max_ki = maxf(1.0, new_max)
	current_ki = max_ki if new_current < 0.0 else clampf(new_current, 0.0, max_ki)
	ki_changed.emit(current_ki, max_ki)


func has_ki(amount: float) -> bool:
	return current_ki >= amount


func consume_ki(amount: float) -> bool:
	if amount <= 0.0:
		return true
	if current_ki < amount:
		return false
	current_ki = maxf(0.0, current_ki - amount)
	ki_changed.emit(current_ki, max_ki)
	if current_ki <= 0.0:
		ki_depleted.emit()
	return true


func drain_ki(amount: float) -> void:
	if amount <= 0.0:
		return
	current_ki = maxf(0.0, current_ki - amount)
	ki_changed.emit(current_ki, max_ki)
	if current_ki <= 0.0:
		ki_depleted.emit()


func restore_ki(amount: float) -> void:
	if amount <= 0.0 or current_ki >= max_ki:
		return
	current_ki = minf(max_ki, current_ki + amount)
	ki_changed.emit(current_ki, max_ki)
