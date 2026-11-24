class_name WeaponInstance
extends RefCounted
## Runtime instance of a WeaponData resource, keeping durability and upgrade state separate from .tres.

var data: WeaponData
var current_durability: int = 0
var upgrade_level: int = 0


func _init(weapon_data: WeaponData, durability: int = -1, level: int = 0) -> void:
	data = weapon_data
	upgrade_level = level
	if data != null:
		current_durability = data.max_durability if durability < 0 else clampi(durability, 0, data.max_durability)


func is_broken() -> bool:
	return data == null or current_durability <= 0


func get_effective_damage() -> float:
	if is_broken():
		return 0.0
	return data.base_damage + (upgrade_level * data.damage_per_upgrade)


func reduce_durability(amount: int = 1) -> bool:
	if is_broken():
		return true
	current_durability = maxi(0, current_durability - amount)
	return is_broken()


func repair_full() -> void:
	if data != null:
		current_durability = data.max_durability


func get_repair_cost() -> int:
	if data == null or current_durability >= data.max_durability:
		return 0
	var missing_ratio: float = float(data.max_durability - current_durability) / float(maxi(1, data.max_durability))
	return maxi(1, int(ceil(missing_ratio * data.repair_essence_cost)))


func get_upgrade_cost() -> int:
	if data == null or upgrade_level >= data.max_upgrade_level:
		return -1
	return data.upgrade_base_cost * (upgrade_level + 1)
