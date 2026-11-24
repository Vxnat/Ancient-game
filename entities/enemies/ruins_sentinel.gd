class_name RuinsSentinel
extends CharacterBody2D
## First MVP Boss in Ancient Ruins; drops the Air-Dash Core Shard upon defeat.

const WAVE_SCENE: PackedScene = preload("res://combat/projectiles/enemy_wave.tscn")
const SHARD_SCENE: PackedScene = preload("res://world/shared/core_shard_pickup.tscn")
const MEMORY_DIALOGUE: DialogueData = preload("res://data/dialogues/memory_air_dash.tres")

@export var enemy_id: StringName = &"ruins_sentinel"
@export var essence_reward: int = 100
@export var aggro_range: float = 240.0
@export var lunge_speed: float = 230.0
@export var gravity: float = 980.0

@onready var health_component: HealthComponent = $HealthComponent
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var hitbox_component: HitboxComponent = $VisualPivot/HitboxComponent
@onready var visual_pivot: Node2D = $VisualPivot
@onready var body_rect: ColorRect = $VisualPivot/BodyRect
@onready var hp_bar: ProgressBar = $HpBar
@onready var title_label: Label = $TitleLabel

var _base_color: Color = Color(0.55, 0.16, 0.36, 1.0)
var _is_dead: bool = false
var _is_acting: bool = false
var _cooldown: float = 0.8
var _attack_index: int = 0
var _flash_tween: Tween


func _ready() -> void:
	if &"air_dash_core" in GameManager.current_run_data["core_shards"]:
		queue_free()
		return
	_base_color = body_rect.color
	hitbox_component.source_entity = self
	hurtbox_component.hit_received.connect(_on_hit_received)
	health_component.health_changed.connect(_on_health_changed)
	health_component.died.connect(_on_died)
	_update_hp_ui(health_component.current_health, health_component.max_health)


func _physics_process(delta: float) -> void:
	if _is_dead:
		return
	if _cooldown > 0.0:
		_cooldown = maxf(0.0, _cooldown - delta)

	if not is_on_floor():
		velocity.y = minf(velocity.y + gravity * delta, 380.0)

	if not _is_acting:
		velocity.x = move_toward(velocity.x, 0.0, 600.0 * delta)
		var player := _find_player()
		if player != null and global_position.distance_to(player.global_position) <= aggro_range and _cooldown <= 0.0:
			var dir: int = 1 if player.global_position.x >= global_position.x else -1
			visual_pivot.scale.x = float(dir)
			_run_next_attack(dir)

	move_and_slide()


func _run_next_attack(dir: int) -> void:
	_is_acting = true
	_attack_index = (_attack_index + 1) % 2
	if _attack_index == 1:
		await _lunge_attack(dir)
	else:
		await _wave_attack(dir)
	_cooldown = 1.05
	_is_acting = false


func _lunge_attack(dir: int) -> void:
	body_rect.color = Color(1.0, 0.82, 0.25, 1.0)
	await get_tree().create_timer(0.42).timeout
	if _is_dead or not is_inside_tree():
		return

	hitbox_component.set_active(true)
	velocity.x = float(dir) * lunge_speed
	await get_tree().create_timer(0.24).timeout
	hitbox_component.set_active(false)
	velocity.x = 0.0
	if not _is_dead and is_inside_tree():
		body_rect.color = _base_color


func _wave_attack(dir: int) -> void:
	body_rect.color = Color(0.75, 0.4, 1.0, 1.0)
	await get_tree().create_timer(0.45).timeout
	if _is_dead or not is_inside_tree():
		return

	var wave := WAVE_SCENE.instantiate() as EnemyWave
	if wave != null:
		var container: Node = get_parent() if get_parent() != null else get_tree().current_scene
		container.add_child(wave)
		wave.setup(global_position + Vector2(float(dir) * 18.0, -4.0), dir, 18.0, self)
	if not _is_dead and is_inside_tree():
		body_rect.color = _base_color


func _find_player() -> Player:
	for node in get_tree().get_nodes_in_group(&"player"):
		if node is Player:
			return node as Player
	return null


func _on_hit_received(_hitbox: HitboxComponent, _damage: float) -> void:
	if _is_dead:
		return
	if _flash_tween != null:
		_flash_tween.kill()
	body_rect.color = Color.WHITE
	_flash_tween = create_tween()
	_flash_tween.tween_property(body_rect, "color", _base_color, 0.14)


func _on_health_changed(current: float, maximum: float) -> void:
	_update_hp_ui(current, maximum)


func _update_hp_ui(current: float, maximum: float) -> void:
	if hp_bar != null:
		hp_bar.max_value = maximum
		hp_bar.value = current
	if title_label != null:
		title_label.text = "Ruins Sentinel (%d/%d)" % [int(ceil(current)), int(maximum)]


func _on_died() -> void:
	if _is_dead:
		return
	_is_dead = true
	hitbox_component.set_active(false)
	GameManager.add_essence(essence_reward)
	EventBus.enemy_killed.emit(enemy_id)

	var shard := SHARD_SCENE.instantiate() as CoreShardPickup
	if shard != null:
		shard.shard_id = &"air_dash_core"
		shard.unlock_skill_id = &"air_dash"
		shard.memory_dialogue = MEMORY_DIALOGUE
		shard.global_position = global_position + Vector2(0.0, -18.0)
		var container: Node = get_parent() if get_parent() != null else get_tree().current_scene
		container.call_deferred("add_child", shard)

	queue_free()
