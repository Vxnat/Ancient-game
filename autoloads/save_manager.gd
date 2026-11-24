extends Node
## Handles saving and loading game progression to user://savegame.json.

const SAVE_PATH: String = "user://savegame.json"
const SAVE_VERSION: int = 1


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func save_game(current_scene_path: String = "") -> bool:
	var payload: Dictionary = {
		"save_version": SAVE_VERSION,
		"scene_path": current_scene_path,
		"run_data": GameManager.current_run_data.duplicate(true),
		"active_quests": QuestManager.export_active_quests(),
		"completed_quests": QuestManager.completed_quest_ids.duplicate(),
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: Could not open %s for writing." % SAVE_PATH)
		return false
	file.store_string(JSON.stringify(payload, "\t"))
	return true


func load_game() -> Dictionary:
	if not has_save():
		return {}
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}

	var data: Dictionary = parsed
	if data.has("run_data") and typeof(data["run_data"]) == TYPE_DICTIONARY:
		GameManager.current_run_data.merge(data["run_data"], true)
		_normalize_run_data()
	if data.has("completed_quests") and typeof(data["completed_quests"]) == TYPE_ARRAY:
		QuestManager.completed_quest_ids.clear()
		for qid in data["completed_quests"]:
			QuestManager.completed_quest_ids.append(StringName(qid))
	if data.has("active_quests") and typeof(data["active_quests"]) == TYPE_ARRAY:
		QuestManager.import_active_quests(data["active_quests"])
	return data


func _normalize_run_data() -> void:
	for key in ["unlocked_skills", "core_shards"]:
		var normalized: Array = []
		for item in GameManager.current_run_data.get(key, []):
			normalized.append(StringName(item))
		GameManager.current_run_data[key] = normalized
	GameManager.current_run_data["growth_stage"] = StringName(GameManager.current_run_data.get("growth_stage", &"child"))
	GameManager.current_run_data["current_form_id"] = StringName(GameManager.current_run_data.get("current_form_id", &"child_base"))
	GameManager.current_run_data["equipped_weapon_id"] = StringName(GameManager.current_run_data.get("equipped_weapon_id", &""))
