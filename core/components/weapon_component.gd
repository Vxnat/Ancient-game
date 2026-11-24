class_name WeaponComponent
extends Node
## Manages equipped WeaponInstance, durability depletion, and fallback to bare-handed combat.

signal weapon_changed(weapon: WeaponInstance)
signal durability_changed(current: int, maximum: int)
signal weapon_broke(weapon_id: StringName)

var equipped_weapon: WeaponInstance = null


func equip_weapon(weapon: WeaponInstance) -> void:
	equipped_weapon = weapon
	weapon_changed.emit(equipped_weapon)
	if equipped_weapon != null and equipped_weapon.data != null:
		EventBus.weapon_equipped.emit(equipped_weapon.data.id)
		durability_changed.emit(equipped_weapon.current_durability, equipped_weapon.data.max_durability)
		EventBus.weapon_durability_changed.emit(
			equipped_weapon.data.id,
			equipped_weapon.current_durability,
			equipped_weapon.data.max_durability
		)


func is_using_bare_hands() -> bool:
	return equipped_weapon == null or equipped_weapon.is_broken()


func get_weapon_bonus_damage() -> float:
	if is_using_bare_hands():
		return 0.0
	return equipped_weapon.get_effective_damage()


func on_attack_hit(durability_loss: int = 1) -> void:
	if is_using_bare_hands():
		return
	var just_broke := equipped_weapon.reduce_durability(durability_loss)
	durability_changed.emit(equipped_weapon.current_durability, equipped_weapon.data.max_durability)
	EventBus.weapon_durability_changed.emit(
		equipped_weapon.data.id,
		equipped_weapon.current_durability,
		equipped_weapon.data.max_durability
	)
	if just_broke:
		weapon_broke.emit(equipped_weapon.data.id)
		EventBus.weapon_broken.emit(equipped_weapon.data.id)


func try_repair_equipped() -> bool:
	if equipped_weapon == null or equipped_weapon.data == null:
		return false
	var cost := equipped_weapon.get_repair_cost()
	if cost <= 0:
		return false
	if not GameManager.spend_essence(cost):
		return false
	equipped_weapon.repair_full()
	durability_changed.emit(equipped_weapon.current_durability, equipped_weapon.data.max_durability)
	EventBus.weapon_durability_changed.emit(
		equipped_weapon.data.id,
		equipped_weapon.current_durability,
		equipped_weapon.data.max_durability
	)
	return true


func try_upgrade_equipped() -> bool:
	if equipped_weapon == null or equipped_weapon.data == null:
		return false
	var cost := equipped_weapon.get_upgrade_cost()
	if cost < 0:
		return false
	if not GameManager.spend_essence(cost):
		return false
	equipped_weapon.upgrade_level += 1
	equipped_weapon.repair_full()
	weapon_changed.emit(equipped_weapon)
	durability_changed.emit(equipped_weapon.current_durability, equipped_weapon.data.max_durability)
	return true
