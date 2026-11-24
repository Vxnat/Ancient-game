class_name MasterNPC
extends Area2D
## Mentor NPC who assigns milestone quests and triggers Timeskip growth transitions.

@export var npc_id: StringName = &"npc_master"
@export var display_name: String = "Master Kael"
@export var quest_teen: QuestData
@export var quest_adult: QuestData
@export var intro_teen_dialogue: DialogueData
@export var turn_in_teen_dialogue: DialogueData
@export var intro_adult_dialogue: DialogueData
@export var turn_in_adult_dialogue: DialogueData
@export var progress_dialogue: DialogueData
@export var completed_dialogue: DialogueData

@onready var prompt_label: Label = $PromptLabel
@onready var quest_marker: Label = $QuestMarker

var _player_in_range: Player = null


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	EventBus.quest_started.connect(_on_quest_signal)
	EventBus.quest_updated.connect(_on_quest_signal)
	EventBus.quest_completed.connect(_on_quest_signal)
	if prompt_label != null:
		prompt_label.visible = false
	_refresh_quest_marker()


func _unhandled_input(event: InputEvent) -> void:
	if _player_in_range == null or GameManager.is_paused:
		return
	if event.is_action_pressed("interact"):
		await interact()


func interact() -> void:
	EventBus.npc_talked.emit(npc_id)
	var stage: StringName = GameManager.current_run_data.get("growth_stage", &"child")

	if stage == &"child" and quest_teen != null:
		if QuestManager.is_quest_ready_to_turn_in(quest_teen.id):
			QuestManager.turn_in_quest(quest_teen.id)
			await _trigger_timeskip(&"teen", "3 YEARS LATER...", turn_in_teen_dialogue)
		elif QuestManager.is_quest_active(quest_teen.id):
			_show_dialogue(progress_dialogue)
		else:
			_show_dialogue(intro_teen_dialogue)
			QuestManager.start_quest(quest_teen)
	elif stage == &"teen" and quest_adult != null:
		if QuestManager.is_quest_ready_to_turn_in(quest_adult.id):
			QuestManager.turn_in_quest(quest_adult.id)
			await _trigger_timeskip(&"adult", "4 YEARS LATER...", turn_in_adult_dialogue)
		elif QuestManager.is_quest_active(quest_adult.id):
			_show_dialogue(progress_dialogue)
		else:
			_show_dialogue(intro_adult_dialogue)
			QuestManager.start_quest(quest_adult)
	else:
		_show_dialogue(completed_dialogue)

	_refresh_quest_marker()


func _trigger_timeskip(next_stage: StringName, caption: String, dialogue: DialogueData) -> void:
	GameManager.set_growth_stage(next_stage)
	if is_inside_tree():
		await SceneManager.play_timeskip_flash(caption)
	_show_dialogue(dialogue)


func _show_dialogue(data: DialogueData) -> void:
	if data != null:
		EventBus.dialogue_requested.emit(data)


func _refresh_quest_marker() -> void:
	if quest_marker == null:
		return
	var stage: StringName = GameManager.current_run_data.get("growth_stage", &"child")
	var current_quest: QuestData = quest_teen if stage == &"child" else (quest_adult if stage == &"teen" else null)
	if current_quest == null or QuestManager.is_quest_completed(current_quest.id):
		quest_marker.text = ""
	elif QuestManager.is_quest_ready_to_turn_in(current_quest.id):
		quest_marker.text = "?"
		quest_marker.modulate = Color(1.0, 0.85, 0.2, 1.0)
	elif QuestManager.is_quest_active(current_quest.id):
		quest_marker.text = "..."
		quest_marker.modulate = Color(0.75, 0.8, 0.9, 1.0)
	else:
		quest_marker.text = "!"
		quest_marker.modulate = Color(1.0, 0.85, 0.2, 1.0)


func _on_quest_signal(_quest_id: StringName) -> void:
	_refresh_quest_marker()


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		_player_in_range = body as Player
		if prompt_label != null:
			prompt_label.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body == _player_in_range:
		_player_in_range = null
		if prompt_label != null:
			prompt_label.visible = false
