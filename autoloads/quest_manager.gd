extends Node
## Tracks active and completed quests by listening to EventBus signals.

## Structure: { quest_id: { "data": QuestData, "progress": int, "completed": bool } }
var active_quests: Dictionary = {}
var completed_quest_ids: Array[StringName] = []


func _ready() -> void:
	EventBus.enemy_killed.connect(_on_enemy_killed)
	EventBus.item_collected.connect(_on_item_collected)
	EventBus.npc_talked.connect(_on_npc_talked)
	EventBus.area_entered.connect(_on_area_entered)


func start_quest(quest_data: QuestData) -> void:
	if quest_data == null:
		return
	if active_quests.has(quest_data.id) or quest_data.id in completed_quest_ids:
		return
	active_quests[quest_data.id] = {
		"data": quest_data,
		"progress": 0,
		"completed": false,
	}
	EventBus.quest_started.emit(quest_data.id)


func turn_in_quest(quest_id: StringName) -> bool:
	if not active_quests.has(quest_id):
		return false
	var entry: Dictionary = active_quests[quest_id]
	if not bool(entry["completed"]):
		return false

	var data: QuestData = entry["data"]
	if data.reward_essence > 0:
		GameManager.add_essence(data.reward_essence)
	if data.reward_skill_id != &"":
		GameManager.unlock_skill(data.reward_skill_id)

	active_quests.erase(quest_id)
	completed_quest_ids.append(quest_id)
	EventBus.quest_completed.emit(quest_id)
	return true


func is_quest_active(quest_id: StringName) -> bool:
	return active_quests.has(quest_id)


func is_quest_ready_to_turn_in(quest_id: StringName) -> bool:
	return active_quests.has(quest_id) and bool(active_quests[quest_id]["completed"])


func is_quest_completed(quest_id: StringName) -> bool:
	return quest_id in completed_quest_ids


func export_active_quests() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for quest_id in active_quests.keys():
		var entry: Dictionary = active_quests[quest_id]
		var data: QuestData = entry["data"]
		if data == null or data.resource_path.is_empty():
			continue
		result.append({
			"path": data.resource_path,
			"progress": int(entry["progress"]),
			"completed": bool(entry["completed"]),
		})
	return result


func import_active_quests(entries: Array) -> void:
	active_quests.clear()
	for raw in entries:
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = raw
		var path: String = str(item.get("path", ""))
		if path.is_empty() or not ResourceLoader.exists(path):
			continue
		var data := load(path) as QuestData
		if data == null:
			continue
		active_quests[data.id] = {
			"data": data,
			"progress": int(item.get("progress", 0)),
			"completed": bool(item.get("completed", false)),
		}
		EventBus.quest_started.emit(data.id)


func reset_quests() -> void:
	active_quests.clear()
	completed_quest_ids.clear()


func _advance_quests(objective_type: int, target_id: StringName, amount: int = 1) -> void:
	for quest_id in active_quests.keys():
		var entry: Dictionary = active_quests[quest_id]
		if bool(entry["completed"]):
			continue
		var data: QuestData = entry["data"]
		if data.objective_type == objective_type and data.target_id == target_id:
			entry["progress"] = mini(int(entry["progress"]) + amount, data.required_amount)
			if int(entry["progress"]) >= data.required_amount:
				entry["completed"] = true
			EventBus.quest_updated.emit(quest_id)


func _on_enemy_killed(enemy_id: StringName) -> void:
	_advance_quests(QuestData.ObjectiveType.KILL_ENEMY, enemy_id, 1)


func _on_item_collected(item_id: StringName, amount: int) -> void:
	_advance_quests(QuestData.ObjectiveType.COLLECT_ITEM, item_id, amount)


func _on_npc_talked(npc_id: StringName) -> void:
	_advance_quests(QuestData.ObjectiveType.TALK_TO_NPC, npc_id, 1)


func _on_area_entered(area_id: StringName) -> void:
	_advance_quests(QuestData.ObjectiveType.REACH_AREA, area_id, 1)
