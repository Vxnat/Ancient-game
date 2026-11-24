class_name Portal
extends Area2D
## Transitions Player to another map scene via SceneManager and places them at target_spawn_point.

@export_file("*.tscn") var target_scene_path: String = ""
@export var target_spawn_point: StringName = &"DefaultSpawn"
@export var portal_label: String = "Portal"

@onready var prompt_label: Label = $PromptLabel

var _player_in_range: Player = null


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if prompt_label != null:
		prompt_label.text = "[E] %s" % portal_label
		prompt_label.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if _player_in_range == null or GameManager.is_paused:
		return
	if event.is_action_pressed("interact") and not target_scene_path.is_empty():
		_player_in_range.sync_weapon_to_run_data()
		SceneManager.change_scene(target_scene_path, target_spawn_point)


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
