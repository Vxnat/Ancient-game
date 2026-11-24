class_name QuestNPC
extends Area2D
## Interactable NPC delivering dialogue and managing QuestData lifecycle via QuestManager.

@export var npc_id: StringName = &"npc_elder"
@export var display_name: String = "Elder"
@export var body_color: Color = Color(0.35, 0.82, 0.55, 1.0)
@export var quest_data: QuestData
@export var intro_dialogue: DialogueData
@export var in_progress_dialogue: DialogueData
@export var turn_in_dialogue: DialogueData
@export var completed_dialogue: DialogueData

@onready var body_rect: ColorRect = $BodyRect
@onready var name_label: Label = $NameLabel
@onready var prompt_label: Label = $PromptLabel
@onready var quest_marker: Label = $QuestMarker

var _player_in_range: Player = null


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	EventBus.quest_started.connect(_on_quest_signal)
	EventBus.quest_updated.connect(_on_quest_signal)
	EventBus.quest_completed.connect(_on_quest_signal)

	if body_rect != null:
		body_rect.color = body_color
	if name_label != null:
		name_label.text = display_name
	if prompt_label != null:
		prompt_label.visible = false
	_refresh_quest_marker()


func _unhandled_input(event: InputEvent) -> void:
	if _player_in_range == null or GameManager.is_paused:
		return
	if event.is_action_pressed("interact"):
		interact()


func interact() -> void:
	EventBus.npc_talked.emit(npc_id)
	if quest_data == null:
		_show_dialogue(completed_dialogue)
		return

	if QuestManager.is_quest_completed(quest_data.id):
		_show_dialogue(completed_dialogue)
	elif QuestManager.is_quest_ready_to_turn_in(quest_data.id):
		QuestManager.turn_in_quest(quest_data.id)
		_show_dialogue(turn_in_dialogue)
	elif QuestManager.is_quest_active(quest_data.id):
		_show_dialogue(in_progress_dialogue)
	else:
		_show_dialogue(intro_dialogue)
		QuestManager.start_quest(quest_data)

	_refresh_quest_marker()


func _show_dialogue(data: DialogueData) -> void:
	if data != null:
		EventBus.dialogue_requested.emit(data)


func _refresh_quest_marker() -> void:
	if quest_marker == null or quest_data == null:
		return
	if QuestManager.is_quest_completed(quest_data.id):
		quest_marker.text = ""
	elif QuestManager.is_quest_ready_to_turn_in(quest_data.id):
		quest_marker.text = "?"
		quest_marker.modulate = Color(1.0, 0.85, 0.2, 1.0)
	elif QuestManager.is_quest_active(quest_data.id):
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
