class_name CoreShardPickup
extends Area2D
## Collectible Core Shard dropped by Bosses that unlocks a Metroidvania ability and triggers memory dialogue.

@export var shard_id: StringName = &"air_dash_core"
@export var unlock_skill_id: StringName = &"air_dash"
@export var memory_dialogue: DialogueData

@onready var glow_rect: ColorRect = $GlowRect

var _bob_time: float = 0.0
var _base_y: float = 0.0
var _collected: bool = false


func _ready() -> void:
	_base_y = position.y
	if shard_id in GameManager.current_run_data["core_shards"]:
		queue_free()
		return
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_bob_time += delta * 4.0
	position.y = _base_y + sin(_bob_time) * 3.0


func _on_body_entered(body: Node2D) -> void:
	if _collected or not (body is Player):
		return
	_collected = true
	var shards: Array = GameManager.current_run_data["core_shards"]
	if shard_id not in shards:
		shards.append(shard_id)
	if unlock_skill_id != &"":
		GameManager.unlock_skill(unlock_skill_id)
	EventBus.core_shard_collected.emit(shard_id)
	if memory_dialogue != null:
		EventBus.dialogue_requested.emit(memory_dialogue)
	queue_free()
