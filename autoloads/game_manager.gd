extends Node
## Manages global game state, pause, and persistent runtime data across scene transitions.

var is_paused: bool = false
var target_spawn_point: StringName = &"DefaultSpawn"

## Persistent runtime state kept alive when SceneManager swaps map scenes.
var current_run_data: Dictionary = {
	"growth_stage": &"child",
	"current_form_id": &"child_base",
	"current_hp": 100.0,
	"max_hp": 100.0,
	"current_ki": 100.0,
	"max_ki": 100.0,
	"essence": 0,
	"unlocked_skills": [],
	"core_shards": [],
	"equipped_weapon_id": &"",
	"weapon_states": {}, # { weapon_id: { "durability": int, "upgrade_level": int } }
	"has_disciple": false,
	"story_flags": {},
}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	EventBus.enemy_killed.connect(_on_enemy_killed)


func toggle_pause() -> void:
	is_paused = not is_paused
	get_tree().paused = is_paused


func set_paused(paused: bool) -> void:
	is_paused = paused
	get_tree().paused = is_paused


func reset_run_data() -> void:
	current_run_data = {
		"growth_stage": &"child",
		"current_form_id": &"child_base",
		"current_hp": 100.0,
		"max_hp": 100.0,
		"current_ki": 100.0,
		"max_ki": 100.0,
		"essence": 0,
		"unlocked_skills": [],
		"core_shards": [],
		"equipped_weapon_id": &"",
		"weapon_states": {},
		"has_disciple": false,
		"story_flags": {},
	}


func add_essence(amount: int) -> void:
	if amount <= 0:
		return
	current_run_data["essence"] = int(current_run_data["essence"]) + amount
	EventBus.essence_changed.emit(current_run_data["essence"])


func spend_essence(amount: int) -> bool:
	var current: int = int(current_run_data["essence"])
	if amount <= 0 or current < amount:
		return false
	current_run_data["essence"] = current - amount
	EventBus.essence_changed.emit(current_run_data["essence"])
	return true


func unlock_skill(skill_id: StringName) -> void:
	var skills: Array = current_run_data["unlocked_skills"]
	if skill_id not in skills:
		skills.append(skill_id)
		EventBus.skill_unlocked.emit(skill_id)


func has_skill(skill_id: StringName) -> bool:
	return skill_id in current_run_data["unlocked_skills"]


func set_story_flag(flag_name: StringName, value: bool = true) -> void:
	current_run_data["story_flags"][flag_name] = value


func get_story_flag(flag_name: StringName) -> bool:
	return bool(current_run_data["story_flags"].get(flag_name, false))


func set_growth_stage(stage: StringName) -> void:
	if current_run_data["growth_stage"] == stage:
		return
	current_run_data["growth_stage"] = stage
	EventBus.growth_stage_changed.emit(stage)


func recruit_disciple() -> void:
	if bool(current_run_data.get("has_disciple", false)):
		return
	current_run_data["has_disciple"] = true
	EventBus.disciple_recruited.emit()


func _on_enemy_killed(_enemy_id: StringName) -> void:
	pass
