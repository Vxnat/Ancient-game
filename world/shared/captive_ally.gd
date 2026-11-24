class_name CaptiveAlly
extends Area2D
## Captive warrior freed after defeating PrisonWarden; recruits the Disciple upon interaction.

@export var rescue_dialogue: DialogueData

@onready var cage_rect: ColorRect = $CageRect
@onready var prompt_label: Label = $PromptLabel

var _player_in_range: Player = null


func _ready() -> void:
	if bool(GameManager.current_run_data.get("has_disciple", false)):
		queue_free()
		return
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	EventBus.enemy_killed.connect(_on_enemy_killed)
	_refresh_cage_state()


func _unhandled_input(event: InputEvent) -> void:
	if _player_in_range == null or GameManager.is_paused:
		return
	if event.is_action_pressed("interact"):
		if not GameManager.get_story_flag(&"warden_defeated"):
			return
		rescue()


func rescue() -> void:
	GameManager.recruit_disciple()
	EventBus.npc_talked.emit(&"captive_ally")
	if rescue_dialogue != null:
		EventBus.dialogue_requested.emit(rescue_dialogue)
	queue_free()


func _refresh_cage_state() -> void:
	var freed: bool = GameManager.get_story_flag(&"warden_defeated")
	if cage_rect != null:
		cage_rect.visible = not freed
	if prompt_label != null:
		prompt_label.text = "[E] Recruit Disciple" if freed else "Defeat Prison Warden first!"


func _on_enemy_killed(enemy_id: StringName) -> void:
	if enemy_id == &"prison_warden":
		_refresh_cage_state()


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		_player_in_range = body as Player
		_refresh_cage_state()
		if prompt_label != null:
			prompt_label.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body == _player_in_range:
		_player_in_range = null
		if prompt_label != null:
			prompt_label.visible = false
