class_name RuinsStalker
extends CharacterBody2D
## Patrolling melee enemy in the Ruins with aggro chase, telegraphed strike, and Essence drop.

@export var enemy_id: StringName = &"ruins_stalker"
@export var essence_reward: int = 35
@export var patrol_range: float = 65.0
@export var patrol_speed: float = 55.0
@export var chase_speed: float = 95.0
@export var aggro_range: float = 150.0
@export var attack_range: float = 30.0
@export var gravity: float = 980.0

@onready var health_component: HealthComponent = $HealthComponent
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var hitbox_component: HitboxComponent = $VisualPivot/HitboxComponent
@onready var visual_pivot: Node2D = $VisualPivot
@onready var body_rect: ColorRect = $VisualPivot/BodyRect
@onready var hp_label: Label = $HpLabel

var _spawn_x: float = 0.0
var _patrol_dir: int = 1
var _base_color: Color = Color(0.75, 0.25, 0.45, 1.0)
var _is_dead: bool = false
var _is_attacking: bool = false
var _attack_cooldown: float = 0.0
var _flash_tween: Tween


func _ready() -> void:
	_spawn_x = global_position.x
	_base_color = body_rect.color
	hitbox_component.source_entity = self
	hurtbox_component.hit_received.connect(_on_hit_received)
	health_component.health_changed.connect(_on_health_changed)
	health_component.died.connect(_on_died)
	_update_hp_label()


func _physics_process(delta: float) -> void:
	if _is_dead:
		return
	if _attack_cooldown > 0.0:
		_attack_cooldown = maxf(0.0, _attack_cooldown - delta)

	if not is_on_floor():
		velocity.y = minf(velocity.y + gravity * delta, 380.0)

	if not _is_attacking:
		var player := _find_player()
		if player != null and global_position.distance_to(player.global_position) <= aggro_range:
			var dx: float = player.global_position.x - global_position.x
			var dir: int = 1 if dx >= 0.0 else -1
			_set_facing(dir)
			if absf(dx) <= attack_range and absf(player.global_position.y - global_position.y) < 36.0 and _attack_cooldown <= 0.0:
				_perform_attack()
			else:
				velocity.x = float(dir) * chase_speed
		else:
			if global_position.x > _spawn_x + patrol_range:
				_patrol_dir = -1
			elif global_position.x < _spawn_x - patrol_range:
				_patrol_dir = 1
			elif is_on_wall():
				_patrol_dir *= -1
			_set_facing(_patrol_dir)
			velocity.x = float(_patrol_dir) * patrol_speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, 600.0 * delta)

	move_and_slide()


func _perform_attack() -> void:
	_is_attacking = true
	_attack_cooldown = 0.75
	body_rect.color = Color(1.0, 0.75, 0.25, 1.0)
	await get_tree().create_timer(0.28).timeout
	if _is_dead or not is_inside_tree():
		return

	hitbox_component.set_active(true)
	await get_tree().create_timer(0.14).timeout
	hitbox_component.set_active(false)
	if not _is_dead and is_inside_tree():
		body_rect.color = _base_color
	_is_attacking = false


func _set_facing(dir: int) -> void:
	visual_pivot.scale.x = float(dir)


func _find_player() -> Player:
	for node in get_tree().get_nodes_in_group(&"player"):
		if node is Player:
			return node as Player
	return null


func _on_hit_received(hitbox: HitboxComponent, _damage: float) -> void:
	if _is_dead:
		return
	var knock_dir: float = 1.0
	if hitbox.source_entity != null:
		knock_dir = signf(global_position.x - hitbox.source_entity.global_position.x)
		if knock_dir == 0.0:
			knock_dir = 1.0
	velocity = Vector2(knock_dir * hitbox.knockback_force.x * 0.7, hitbox.knockback_force.y * 0.7)
	if _flash_tween != null:
		_flash_tween.kill()
	body_rect.color = Color.WHITE
	_flash_tween = create_tween()
	_flash_tween.tween_property(body_rect, "color", _base_color, 0.14)


func _on_health_changed(_current: float, _maximum: float) -> void:
	_update_hp_label()


func _update_hp_label() -> void:
	if hp_label != null:
		hp_label.text = "%d/%d" % [int(ceil(health_component.current_health)), int(health_component.max_health)]


func _on_died() -> void:
	if _is_dead:
		return
	_is_dead = true
	hitbox_component.set_active(false)
	GameManager.add_essence(essence_reward)
	EventBus.enemy_killed.emit(enemy_id)
	queue_free()
