# Run: godot --headless --path . res://tests/test_phase3.tscn
extends Node

var passed: int = 0
var failed: int = 0


func _ready() -> void:
	await _run_all()
	print("Phase 3 Test Results: %d passed, %d failed" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)


func assert_true(cond: bool, label: String) -> void:
	if cond:
		passed += 1
	else:
		failed += 1
		push_error("FAIL: %s" % label)


func assert_eq(actual: Variant, expected: Variant, label: String) -> void:
	if actual == expected:
		passed += 1
	else:
		failed += 1
		push_error("FAIL %s: expected %s, got %s" % [label, str(expected), str(actual)])


func _run_all() -> void:
	await get_tree().process_frame
	for t: String in [
		"test_npc_quest_dialogue_flow",
		"test_ancient_ruins_spawn_and_boss_shard_air_dash",
		"test_active_quest_save_load",
		"test_dialogue_and_tracker_layout_960x540",
	]:
		var ok: Variant = await call(t)
		if ok != true:
			failed += 1
			push_error("FAIL %s: aborted with runtime error" % t)
	await get_tree().process_frame


func test_npc_quest_dialogue_flow() -> bool:
	GameManager.reset_run_data()
	QuestManager.reset_quests()
	GameManager.target_spawn_point = &"DefaultSpawn"

	var packed := load("res://world/peaceful_planet/peaceful_village.tscn") as PackedScene
	var scene := packed.instantiate()
	get_tree().root.add_child(scene)
	await get_tree().physics_frame

	var elder := scene.get_node_or_null("ElderNPC") as QuestNPC
	var dialogue_box := scene.get_node_or_null("DialogueBox") as DialogueBox
	assert_true(elder != null, "ElderNPC exists in peaceful_village")
	assert_true(dialogue_box != null, "DialogueBox exists in peaceful_village")

	elder.interact()
	assert_eq(QuestManager.is_quest_active(&"village_trial"), true, "Talking to Elder starts village_trial")
	assert_eq(dialogue_box.visible, true, "DialogueBox opens on NPC interact")
	dialogue_box.close()

	EventBus.enemy_killed.emit(&"training_dummy")
	EventBus.enemy_killed.emit(&"training_dummy")
	assert_eq(QuestManager.is_quest_ready_to_turn_in(&"village_trial"), true, "Killing 2 dummies completes objective")

	var essence_before: int = int(GameManager.current_run_data["essence"])
	elder.interact()
	dialogue_box.close()
	assert_eq(QuestManager.is_quest_completed(&"village_trial"), true, "Turning in completes quest")
	assert_eq(int(GameManager.current_run_data["essence"]), essence_before + 100, "Quest turn-in grants 100 Essence")

	scene.queue_free()
	await get_tree().process_frame
	GameManager.reset_run_data()
	QuestManager.reset_quests()
	return true


func test_ancient_ruins_spawn_and_boss_shard_air_dash() -> bool:
	GameManager.reset_run_data()
	QuestManager.reset_quests()
	GameManager.target_spawn_point = &"FromVillageSpawn"

	var scout_quest := load("res://data/quests/quest_ruins_sentinel.tres") as QuestData
	QuestManager.start_quest(scout_quest)

	var packed := load("res://world/ruins/ancient_ruins.tscn") as PackedScene
	var scene := packed.instantiate()
	get_tree().root.add_child(scene)
	await get_tree().physics_frame

	var player := scene.get_node_or_null("Player") as Player
	var boss := scene.get_node_or_null("RuinsSentinel") as RuinsSentinel
	assert_true(player != null, "Player exists in ancient_ruins")
	assert_true(boss != null, "RuinsSentinel Boss exists in ancient_ruins")
	assert_eq(int(player.global_position.x), 140, "Player spawns at FromVillageSpawn")
	assert_eq(player.can_air_dash(), false, "Air-Dash is locked before Boss defeat")

	boss.health_component.take_damage(999.0)
	await get_tree().process_frame
	await get_tree().process_frame

	assert_eq(QuestManager.is_quest_ready_to_turn_in(&"ruins_sentinel"), true, "Defeating Boss satisfies Scout quest")

	var shard: CoreShardPickup = null
	for child in scene.get_children():
		if child is CoreShardPickup:
			shard = child as CoreShardPickup
			break
	assert_true(shard != null, "Boss drops CoreShardPickup")
	if shard != null:
		shard._on_body_entered(player)
		assert_eq(GameManager.has_skill(&"air_dash"), true, "Core Shard unlocks air_dash skill")
		assert_eq(&"air_dash_core" in GameManager.current_run_data["core_shards"], true, "Core Shard recorded in run data")
		assert_eq(player.can_air_dash(), true, "Player can now Air-Dash")

		var dialogue_box := scene.get_node_or_null("DialogueBox") as DialogueBox
		if dialogue_box != null and dialogue_box.visible:
			dialogue_box.close()

		var ev_space := InputEventKey.new()
		ev_space.physical_keycode = KEY_SPACE
		ev_space.pressed = true
		Input.parse_input_event(ev_space)
		await get_tree().physics_frame
		await get_tree().physics_frame
		var ev_shift := InputEventKey.new()
		ev_shift.physical_keycode = KEY_SHIFT
		ev_shift.shift_pressed = true
		ev_shift.pressed = true
		Input.parse_input_event(ev_shift)
		await get_tree().physics_frame
		await get_tree().physics_frame
		assert_eq(player.state_machine.current_state.name, &"Dash", "Space + Shift triggers Air-Dash mid-air")
		ev_shift.pressed = false
		Input.parse_input_event(ev_shift)
		ev_space.pressed = false
		Input.parse_input_event(ev_space)

	scene.queue_free()
	await get_tree().process_frame
	GameManager.reset_run_data()
	QuestManager.reset_quests()
	return true


func test_active_quest_save_load() -> bool:
	GameManager.reset_run_data()
	QuestManager.reset_quests()
	var trial := load("res://data/quests/quest_village_trial.tres") as QuestData
	QuestManager.start_quest(trial)
	EventBus.enemy_killed.emit(&"training_dummy")

	assert_eq(SaveManager.save_game("res://world/peaceful_planet/peaceful_village.tscn"), true, "Saves active quest")
	QuestManager.reset_quests()
	assert_eq(QuestManager.is_quest_active(&"village_trial"), false, "Active quests cleared before load")

	SaveManager.load_game()
	assert_eq(QuestManager.is_quest_active(&"village_trial"), true, "Active quest restored from save")
	assert_eq(int(QuestManager.active_quests[&"village_trial"]["progress"]), 1, "Quest progress restored")

	if FileAccess.file_exists(SaveManager.SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SaveManager.SAVE_PATH))
	GameManager.reset_run_data()
	QuestManager.reset_quests()
	return true


func test_dialogue_and_tracker_layout_960x540() -> bool:
	var vp := SubViewport.new()
	vp.size = Vector2i(960, 540)
	get_tree().root.add_child(vp)

	var dlg := (load("res://ui/dialogue_box/dialogue_box.tscn") as PackedScene).instantiate() as DialogueBox
	var tracker := (load("res://ui/quest_log/quest_tracker.tscn") as PackedScene).instantiate() as QuestTracker
	vp.add_child(dlg)
	vp.add_child(tracker)
	dlg.show_dialogue("Elder", ["Welcome to the peaceful planet."])
	await get_tree().process_frame
	await get_tree().process_frame

	var screen := Rect2(Vector2.ZERO, Vector2(960, 540))
	var dlg_panel := dlg.get_node("Root/Margin/Panel") as Control
	var tracker_panel := tracker.get_node("TopRight") as Control
	assert_true(screen.encloses(dlg_panel.get_global_rect()), "DialogueBox fits inside 960x540")
	assert_true(screen.encloses(tracker_panel.get_global_rect()), "QuestTracker fits inside 960x540")

	dlg.close()
	vp.queue_free()
	await get_tree().process_frame
	return true
