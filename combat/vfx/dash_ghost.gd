class_name DashGhost
extends Sprite2D
## Afterimage ghost sprite spawned during Dash that fades out cleanly.


func setup(tex: Texture2D, pos: Vector2, flip_horizontal: bool, ghost_scale: Vector2, tint: Color) -> void:
	texture = tex
	global_position = pos
	flip_h = flip_horizontal
	scale = ghost_scale
	centered = true
	modulate = tint


func _ready() -> void:
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.18).set_ease(Tween.EASE_OUT)
	await tw.finished
	if is_inside_tree():
		queue_free()
