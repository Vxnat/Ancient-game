class_name FormData
extends Resource
## Static definition of a character form (Child, Adult, Overdrive, Fusion).

@export var id: StringName = &"child_base"
@export var display_name: String = "Child Form"
@export var sprite_frames: SpriteFrames
@export var damage_multiplier: float = 1.0
@export var speed_multiplier: float = 1.0
@export var hitbox_scale: Vector2 = Vector2.ONE
@export var ki_drain_per_sec: float = 0.0
@export var hp_drain_per_sec: float = 0.0
@export var form_skills: Array[StringName] = []
