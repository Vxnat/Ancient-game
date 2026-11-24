class_name KiBlast
extends Node2D
## Decoupled Ki energy projectile with animated orb flight and impact burst VFX.

@export var speed: float = 380.0
@export var lifetime: float = 1.4

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var wall_detector: Area2D = $WallDetector

var direction: int = 1
var _age: float = 0.0
var _consumed: bool = false


func setup(spawn_pos: Vector2, dir: int, damage_amount: float, shooter: Node2D, is_overdrive: bool = false) -> void:
	global_position = spawn_pos
	direction = 1 if dir >= 0 else -1
	var scale_mult: float = 1.35 if is_overdrive else 1.0
	scale = Vector2(float(direction) * scale_mult, scale_mult)
	if hitbox_component != null:
		hitbox_component.damage = damage_amount
		hitbox_component.source_entity = shooter
		hitbox_component.set_active(true)
	if animated_sprite != null and animated_sprite.sprite_frames != null and animated_sprite.sprite_frames.has_animation(&"fly"):
		animated_sprite.play(&"fly")


func _ready() -> void:
	hitbox_component.hit_landed.connect(_on_hit_landed)
	wall_detector.body_entered.connect(_on_wall_hit)
	hitbox_component.set_active(true)
	if animated_sprite != null and animated_sprite.sprite_frames != null and animated_sprite.sprite_frames.has_animation(&"fly"):
		animated_sprite.play(&"fly")


func _physics_process(delta: float) -> void:
	if _consumed:
		return
	position.x += float(direction) * speed * delta
	_age += delta
	if _age >= lifetime:
		queue_free()


func _on_hit_landed(_hurtbox: HurtboxComponent) -> void:
	_consume()


func _on_wall_hit(_body: Node2D) -> void:
	_consume()


func _consume() -> void:
	if _consumed:
		return
	_consumed = true
	if hitbox_component != null:
		hitbox_component.set_active(false)
	if wall_detector != null:
		wall_detector.set_deferred("monitoring", false)
	if animated_sprite != null and animated_sprite.sprite_frames != null and animated_sprite.sprite_frames.has_animation(&"hit"):
		animated_sprite.play(&"hit")
		await animated_sprite.animation_finished
	if is_inside_tree():
		queue_free()
