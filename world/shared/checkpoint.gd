class_name Checkpoint
extends Area2D
## Rest checkpoint that restores HP/Ki, auto-saves progress, and opens the Awakening Menu.

@onready var prompt_label: Label = $PromptLabel
@onready var crystal_rect: ColorRect = $CrystalRect

var _player_in_range: Player = null


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if prompt_label != null:
		prompt_label.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if _player_in_range == null or GameManager.is_paused:
		return
	if event.is_action_pressed("interact"):
		activate_checkpoint(_player_in_range)


func activate_checkpoint(player: Player) -> void:
	player.set_overdrive(false)
	player.health_component.initialize(player.health_component.max_health, player.health_component.max_health)
	player.ki_component.initialize(player.ki_component.max_ki, player.ki_component.max_ki)
	player.sync_weapon_to_run_data()

	var scene_path: String = ""
	if get_tree().current_scene != null:
		scene_path = get_tree().current_scene.scene_file_path
	var saved: bool = SaveManager.save_game(scene_path)
	_flash_crystal()

	for node in get_tree().get_nodes_in_group(&"awakening_menu"):
		if node is AwakeningMenu:
			(node as AwakeningMenu).open_for_player(player, "Restored & Saved!" if saved else "HP & Ki Restored!")
			return


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		_player_in_range = body as Player
		prompt_label.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body == _player_in_range:
		_player_in_range = null
		prompt_label.visible = false


func _flash_crystal() -> void:
	if crystal_rect == null:
		return
	var base := Color(0.45, 0.85, 1.0, 1.0)
	crystal_rect.color = Color.WHITE
	var tw := create_tween()
	tw.tween_property(crystal_rect, "color", base, 0.25)
