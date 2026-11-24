class_name TrainingDummy
extends CharacterBody2D
## Phase 1 test enemy with knockback, hit flash, Essence drop, and optional auto-respawn.

@export var enemy_id: StringName = &"training_dummy"
@export var essence_reward: int = 25
@export var auto_respawn: bool = true
@export var respawn_delay: float = 2.0
@export var gravity: float = 980.0

@onready var health_component: HealthComponent = $HealthComponent
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var body_rect: ColorRect = $BodyRect
@onready var hp_label: Label = $HpLabel
@onready var body_collider: CollisionShape2D = $CollisionShape2D

var _base_color: Color = Color(0.93, 0.27, 0.27, 1.0)
var _spawn_position: Vector2 = Vector2.ZERO
var _is_dead: bool = false
var _flash_tween: Tween


func _ready() -> void:
	_spawn_position = global_position
	_base_color = body_rect.color
	hurtbox_component.hit_received.connect(_on_hit_received)
	health_component.health_changed.connect(_on_health_changed)
	health_component.died.connect(_on_died)
	_update_hp_label()


func _physics_process(delta: float) -> void:
	if _is_dead:
		return
	if not is_on_floor():
		velocity.y = minf(velocity.y + gravity * delta, 380.0)
	velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)
	move_and_slide()


func _on_hit_received(hitbox: HitboxComponent, _damage: float) -> void:
	if _is_dead:
		return
	var knock_dir: float = 1.0
	if hitbox.source_entity != null:
		knock_dir = signf(global_position.x - hitbox.source_entity.global_position.x)
		if knock_dir == 0.0:
			knock_dir = 1.0
	velocity = Vector2(knock_dir * hitbox.knockback_force.x, hitbox.knockback_force.y)
	_play_hit_feedback()


func _play_hit_feedback() -> void:
	if _flash_tween != null:
		_flash_tween.kill()
	body_rect.color = Color.WHITE
	body_rect.scale = Vector2(1.25, 0.75)
	_flash_tween = create_tween().set_parallel(true)
	_flash_tween.tween_property(body_rect, "color", _base_color, 0.14)
	_flash_tween.tween_property(body_rect, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_health_changed(_current: float, _maximum: float) -> void:
	_update_hp_label()


func _update_hp_label() -> void:
	if hp_label != null:
		hp_label.text = "%d/%d" % [int(ceil(health_component.current_health)), int(health_component.max_health)]


func _on_died() -> void:
	if _is_dead:
		return
	_is_dead = true
	GameManager.add_essence(essence_reward)
	EventBus.enemy_killed.emit(enemy_id)

	if not auto_respawn:
		queue_free()
		return

	visible = false
	body_collider.set_deferred("disabled", true)
	hurtbox_component.set_deferred("monitorable", false)
	hurtbox_component.set_deferred("monitoring", false)
	await get_tree().create_timer(respawn_delay).timeout
	if not is_inside_tree():
		return
	_respawn()


func _respawn() -> void:
	_is_dead = false
	global_position = _spawn_position
	velocity = Vector2.ZERO
	health_component.initialize(health_component.max_health, health_component.max_health)
	body_rect.color = _base_color
	body_rect.scale = Vector2.ONE
	visible = true
	body_collider.set_deferred("disabled", false)
	hurtbox_component.set_deferred("monitorable", true)
	hurtbox_component.set_deferred("monitoring", true)
