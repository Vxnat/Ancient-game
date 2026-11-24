class_name RepairShrine
extends Area2D
## Interactable shrine that spends Essence to repair the Player's equipped weapon.

@onready var prompt_label: Label = $PromptLabel
@onready var pillar_rect: ColorRect = $PillarRect

var _player_in_range: Player = null


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if prompt_label != null:
		prompt_label.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if _player_in_range == null:
		return
	if event.is_action_pressed("interact"):
		var repaired: bool = _player_in_range.weapon_component.try_repair_equipped()
		_flash_feedback(repaired)
		_refresh_prompt()


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		_player_in_range = body as Player
		_refresh_prompt()
		prompt_label.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body == _player_in_range:
		_player_in_range = null
		prompt_label.visible = false


func _refresh_prompt() -> void:
	if _player_in_range == null or prompt_label == null:
		return
	var weapon := _player_in_range.weapon_component.equipped_weapon
	if weapon == null or weapon.data == null:
		prompt_label.text = "No Weapon"
		return
	var cost: int = weapon.get_repair_cost()
	if cost <= 0:
		prompt_label.text = "[E] Full"
	else:
		prompt_label.text = "[E] Repair (%d)" % cost


func _flash_feedback(success: bool) -> void:
	if pillar_rect == null:
		return
	var base := Color(0.66, 0.33, 0.97, 1.0)
	pillar_rect.color = Color(0.2, 0.9, 0.4, 1.0) if success else Color(0.95, 0.25, 0.25, 1.0)
	var tw := create_tween()
	tw.tween_property(pillar_rect, "color", base, 0.22)
