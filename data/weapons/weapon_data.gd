class_name WeaponData
extends Resource
## Static definition of a weapon. Runtime durability/upgrade state lives in WeaponInstance.

enum WeaponCategory { SWORD, BLADE, SPEAR, GAUNTLET, STAFF }

@export var id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D
@export var category: WeaponCategory = WeaponCategory.SWORD

@export_group("Combat")
@export var base_damage: float = 12.0
@export var attack_range: float = 28.0
@export var attack_speed_multiplier: float = 1.0

@export_group("Durability & Upgrades")
@export var max_durability: int = 50
@export var repair_essence_cost: int = 30
@export var max_upgrade_level: int = 5
@export var damage_per_upgrade: float = 4.0
@export var upgrade_base_cost: int = 50
