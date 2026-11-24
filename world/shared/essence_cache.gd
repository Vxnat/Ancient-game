class_name EssenceCache
extends Area2D
## One-time Essence reward tucked behind exploration or ability gates.

@export var cache_flag: StringName = &"ruins_secret_cache_1"
@export var essence_amount: int = 120

var _collected: bool = false


func _ready() -> void:
	if GameManager.get_story_flag(cache_flag):
		queue_free()
		return
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _collected or not (body is Player):
		return
	_collected = true
	GameManager.set_story_flag(cache_flag, true)
	GameManager.add_essence(essence_amount)
	queue_free()
