class_name QuestData
extends Resource
## Static definition of a quest tracked by QuestManager.

enum ObjectiveType { KILL_ENEMY, COLLECT_ITEM, TALK_TO_NPC, REACH_AREA }

@export var id: StringName = &""
@export var title: String = ""
@export_multiline var description: String = ""
@export var giver_npc_id: StringName = &""

@export_group("Objective")
@export var objective_type: ObjectiveType = ObjectiveType.KILL_ENEMY
@export var target_id: StringName = &""
@export var required_amount: int = 1

@export_group("Rewards")
@export var reward_essence: int = 100
@export var reward_skill_id: StringName = &""
