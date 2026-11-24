extends Node
## Handles map/scene transitions with fade effects and spawn-point placement.

var _fade_layer: CanvasLayer
var _fade_rect: ColorRect
var _is_transitioning: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_fade_overlay()


func _setup_fade_overlay() -> void:
	_fade_layer = CanvasLayer.new()
	_fade_layer.layer = 100
	add_child(_fade_layer)

	_fade_rect = ColorRect.new()
	_fade_rect.color = Color(0.0, 0.0, 0.0, 0.0)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_fade_layer.add_child(_fade_rect)


func change_scene(scene_path: String, spawn_point: StringName = &"DefaultSpawn", fade_duration: float = 0.25) -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	GameManager.target_spawn_point = spawn_point

	var fade_out := create_tween()
	fade_out.tween_property(_fade_rect, "color:a", 1.0, fade_duration)
	await fade_out.finished

	var err := get_tree().change_scene_to_file(scene_path)
	if err != OK:
		push_error("SceneManager failed to load scene: %s (error %d)" % [scene_path, err])

	await get_tree().process_frame

	var fade_in := create_tween()
	fade_in.tween_property(_fade_rect, "color:a", 0.0, fade_duration)
	await fade_in.finished

	_is_transitioning = false


func play_timeskip_flash(caption: String = "3 YEARS LATER...") -> void:
	var label := Label.new()
	label.text = caption
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.modulate.a = 0.0
	_fade_layer.add_child(label)

	var tw := create_tween()
	tw.tween_property(_fade_rect, "color:a", 1.0, 0.35)
	tw.tween_property(label, "modulate:a", 1.0, 0.25)
	tw.tween_interval(0.9)
	tw.tween_property(label, "modulate:a", 0.0, 0.25)
	tw.tween_property(_fade_rect, "color:a", 0.0, 0.35)
	await tw.finished
	label.queue_free()
