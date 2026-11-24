class_name PrisonWarden
extends CharacterBody2D
## Boss guarding the captive Disciple in the Ruins; defeating it frees the captive.

@export var enemy_id: StringName = &"prison_warden"
@export var essence_reward: int = 120
@export var aggro_range: float = 220.0
@export var dash_speed: float = 220.0
@export var gravity: float = 980.0

@onready var health_component: HealthComponent = $HealthComponent
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var hitbox_component: HitboxComponent = $VisualPivot/HitboxComponent
@onready var visual_pivot: Node2D = $VisualPivot
@onready var body_rect: ColorRect = $VisualPivot/BodyRect
@onready var hp_bar: ProgressBar = $HpBar
@onready var title_label: Label = $TitleLabel

var _base_color: Color = Color(0.68, 0.2, 0.22, 1.0)
var _is_dead: bool = false
var _is_acting: bool = false
var _cooldown: float = 0.85
var _flash_tween: Tween


func _ready() -> void:
	if GameManager.get_story_flag(&"warden_defeated") or bool(GameManager.current_run_data.get("has_disciple", false)):
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
			_strike(dir)

	move_and_slide()


func _strike(dir: int) -> void:
	_is_acting = true
	body_rect.color = Color(1.0, 0.78, 0.25, 1.0)
	await get_tree().create_timer(0.4).timeout
	if _is_dead or not is_inside_tree():
		return

	hitbox_component.set_active(true)
	velocity.x = float(dir) * dash_speed
	await get_tree().create_timer(0.24).timeout
	hitbox_component.set_active(false)
	velocity.x = 0.0
	if not _is_dead and is_inside_tree():
		body_rect.color = _base_color
	_cooldown = 0.95
	_is_acting = false


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
		title_label.text = "Prison Warden (%d/%d)" % [int(ceil(current)), int(maximum)]


func _on_died() -> void:
	if _is_dead:
		return
	_is_dead = true
	hitbox_component.set_active(false)
	GameManager.set_story_flag(&"warden_defeated", true)
	GameManager.add_essence(essence_reward)
	EventBus.enemy_killed.emit(enemy_id)
	queue_free()
