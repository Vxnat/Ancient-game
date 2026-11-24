class_name Disciple
extends CharacterBody2D
## AI ally companion who follows Player, attacks nearby enemies, and merges during Fusion.

@export var follow_distance: float = 34.0
@export var move_speed: float = 145.0
@export var aggro_range: float = 160.0
@export var attack_range: float = 30.0
@export var jump_velocity: float = -360.0
@export var gravity: float = 980.0

@onready var health_component: HealthComponent = $HealthComponent
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var hitbox_component: HitboxComponent = $VisualPivot/HitboxComponent
@onready var body_collision: CollisionShape2D = $CollisionShape2D
@onready var visual_pivot: Node2D = $VisualPivot
@onready var body_rect: ColorRect = $VisualPivot/BodyRect
@onready var slash_rect: ColorRect = $VisualPivot/SlashRect

var _is_fused: bool = false
var _is_attacking: bool = false
var _attack_cooldown: float = 0.0
var _base_color: Color = Color(0.25, 0.9, 0.72, 1.0)


func _ready() -> void:
	add_to_group(&"allies")
	_base_color = body_rect.color
	hitbox_component.source_entity = self
	slash_rect.visible = false
	hurtbox_component.hit_received.connect(_on_hit_received)
	health_component.died.connect(_on_died)
	EventBus.disciple_recruited.connect(_on_disciple_recruited)
	EventBus.fusion_toggled.connect(_on_fusion_toggled)

	_sync_active_state()


func _physics_process(delta: float) -> void:
	if _is_fused or not bool(GameManager.current_run_data.get("has_disciple", false)):
		return

	if _attack_cooldown > 0.0:
		_attack_cooldown = maxf(0.0, _attack_cooldown - delta)

	if not is_on_floor():
		velocity.y = minf(velocity.y + gravity * delta, 380.0)

	if not _is_attacking:
		var enemy := _find_nearest_enemy()
		if enemy != null:
			_pursue_and_attack(enemy, delta)
		else:
			_follow_player(delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, 700.0 * delta)

	move_and_slide()


func _pursue_and_attack(enemy: Node2D, _delta: float) -> void:
	var dx: float = enemy.global_position.x - global_position.x
	var dir: int = 1 if dx >= 0.0 else -1
	visual_pivot.scale.x = float(dir)

	if absf(dx) <= attack_range and absf(enemy.global_position.y - global_position.y) < 34.0 and _attack_cooldown <= 0.0:
		_perform_attack()
	else:
		velocity.x = float(dir) * move_speed
		if enemy.global_position.y < global_position.y - 28.0 and is_on_floor():
			velocity.y = jump_velocity


func _follow_player(delta: float) -> void:
	var player := _find_player()
	if player == null:
		velocity.x = move_toward(velocity.x, 0.0, 700.0 * delta)
		return

	var dist: float = global_position.distance_to(player.global_position)
	if dist > 260.0:
		global_position = player.global_position + Vector2(-28.0 * player.facing_direction, 0.0)
		velocity = Vector2.ZERO
		return

	var target_x: float = player.global_position.x - float(player.facing_direction) * follow_distance
	var dx: float = target_x - global_position.x
	if absf(dx) > 10.0:
		var dir: int = 1 if dx > 0.0 else -1
		visual_pivot.scale.x = float(dir)
		velocity.x = float(dir) * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)

	if player.global_position.y < global_position.y - 34.0 and is_on_floor():
		velocity.y = jump_velocity


func _perform_attack() -> void:
	_is_attacking = true
	_attack_cooldown = 0.7
	slash_rect.visible = true
	hitbox_component.set_active(true)
	await get_tree().create_timer(0.14).timeout
	hitbox_component.set_active(false)
	slash_rect.visible = false
	_is_attacking = false


func _find_player() -> Player:
	for node in get_tree().get_nodes_in_group(&"player"):
		if node is Player:
			return node as Player
	return null


func _find_nearest_enemy() -> Node2D:
	var best: Node2D = null
	var best_dist: float = aggro_range
	var parent_node := get_parent()
	if parent_node == null:
		return null
	for child in parent_node.get_children():
		if child is CharacterBody2D and (child.collision_layer & 8) != 0 and child.visible:
			var d: float = global_position.distance_to((child as Node2D).global_position)
			if d < best_dist:
				best_dist = d
				best = child as Node2D
	return best


func _sync_active_state() -> void:
	var unlocked: bool = bool(GameManager.current_run_data.get("has_disciple", false))
	var active: bool = unlocked and not _is_fused
	visible = active
	body_collision.set_deferred("disabled", not active)
	hurtbox_component.set_deferred("monitoring", active)
	hurtbox_component.set_deferred("monitorable", active)
	if not active:
		hitbox_component.set_active(false)


func _on_disciple_recruited() -> void:
	var player := _find_player()
	if player != null:
		global_position = player.global_position + Vector2(-28.0 * player.facing_direction, 0.0)
	_sync_active_state()


func _on_fusion_toggled(active: bool) -> void:
	_is_fused = active
	if not active:
		var player := _find_player()
		if player != null:
			global_position = player.global_position + Vector2(-26.0 * player.facing_direction, 0.0)
			velocity = Vector2.ZERO
	_sync_active_state()


func _on_hit_received(_hitbox: HitboxComponent, _damage: float) -> void:
	body_rect.color = Color.WHITE
	var tw := create_tween()
	tw.tween_property(body_rect, "color", _base_color, 0.14)


func _on_died() -> void:
	# Disciple briefly recovers instead of permanently dying.
	health_component.initialize(health_component.max_health, health_component.max_health)
	var player := _find_player()
	if player != null:
		global_position = player.global_position + Vector2(-28.0 * player.facing_direction, 0.0)
