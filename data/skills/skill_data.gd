class_name SkillData
extends Resource
## Static definition of an Awakening skill or passive power unlocked with Essence or Core Shards.

enum SkillType { PASSIVE, ACTIVE, MOVEMENT, TRANSFORMATION }

@export var id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D
@export var skill_type: SkillType = SkillType.PASSIVE
@export var essence_cost: int = 100
@export var required_core_shard: StringName = &""
@export var prerequisite_skill_id: StringName = &""
