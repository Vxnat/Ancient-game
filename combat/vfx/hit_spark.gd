class_name HitSpark
extends Node2D
## One-shot pixel hit spark VFX that auto-frees after completion.

@onready var particles: CPUParticles2D = $Particles


func setup(pos: Vector2, spark_color: Color = Color(0.6, 0.95, 1.0, 1.0)) -> void:
	global_position = pos
	if particles != null:
		particles.color = spark_color


func _ready() -> void:
	if particles != null:
		particles.emitting = true
	await get_tree().create_timer(0.35).timeout
	if is_inside_tree():
		queue_free()
