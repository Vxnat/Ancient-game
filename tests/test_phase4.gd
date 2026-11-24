# Run: godot --headless --path . res://tests/test_phase4.tscn
extends Node

var passed: int = 0
var failed: int = 0


func _ready() -> void:
	await _run_all()
	print("Phase 4 Test Results: %d passed, %d failed" % [passed, failed])
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
		"test_growth_stages_child_teen_adult",
		"test_rescue_warden_disciple_and_fusion_lifecycle",
		"test_master_npc_timeskip_quests",
		"test_menus_layout_960x540",
	]:
		var ok: Variant = await call(t)
		if ok != true:
			failed += 1
			push_error("FAIL %s: aborted with runtime error" % t)
	await get_tree().process_frame


func test_growth_stages_child_teen_adult() -> bool:
	GameManager.reset_run_data()
	var packed := load("res://world/peaceful_planet/peaceful_village.tscn") as PackedScene
	var scene := packed.instantiate()
	get_tree().root.add_child(scene)
	await get_tree().physics_frame

	var player := scene.get_node("Player") as Player
	assert_eq(player.stats_component.damage_multiplier, 1.0, "Child base damage_multiplier is 1.0")

	GameManager.set_growth_stage(&"teen")
	assert_eq(player.stats_component.damage_multiplier, 1.25, "Teen stage scales damage_multiplier to 1.25")
	assert_eq(player.animated_sprite.sprite_frames, load("res://assets/sprites/player/teen/teen_sprite_frames.tres"), "Teen stage switches to teen_sprite_frames.tres")
	assert_true((player.body_collision.shape as RectangleShape2D).size.y > 55.0, "Teen stage increases Player collider height")

	GameManager.set_growth_stage(&"adult")
	assert_eq(player.stats_component.damage_multiplier, 1.5, "Adult stage scales damage_multiplier to 1.5")
	assert_eq(player.animated_sprite.sprite_frames, load("res://assets/sprites/player/adult/adult_sprite_frames.tres"), "Adult stage switches to adult_sprite_frames.tres")
	assert_true((player.body_collision.shape as RectangleShape2D).size.y > 62.0, "Adult stage increases Player collider height")

	scene.queue_free()
	await get_tree().process_frame
	GameManager.reset_run_data()
	return true


func test_rescue_warden_disciple_and_fusion_lifecycle() -> bool:
	GameManager.reset_run_data()
	QuestManager.reset_quests()
	GameManager.target_spawn_point = &"FromVillageSpawn"

	var packed := load("res://world/ruins/ancient_ruins.tscn") as PackedScene
	var scene := packed.instantiate()
	get_tree().root.add_child(scene)
	await get_tree().physics_frame

	var player := scene.get_node("Player") as Player
	var disciple := scene.get_node("Disciple") as Disciple
	var warden := scene.get_node("PrisonWarden") as PrisonWarden
	var captive := scene.get_node("CaptiveAlly") as CaptiveAlly
	var dialogue_box := scene.get_node("DialogueBox") as DialogueBox

	assert_eq(disciple.visible, false, "Disciple hidden before rescue")
	assert_eq(player.can_activate_fusion(), false, "Fusion locked before recruiting Disciple")

	warden.health_component.take_damage(999.0)
	await get_tree().process_frame
	assert_eq(GameManager.get_story_flag(&"warden_defeated"), true, "Defeating PrisonWarden sets flag")

	captive.rescue()
	if dialogue_box != null and dialogue_box.visible:
		dialogue_box.close()
	await get_tree().process_frame

	assert_eq(bool(GameManager.current_run_data["has_disciple"]), true, "Disciple recruited")
	assert_eq(disciple.visible, true, "Disciple becomes active in scene")
	assert_eq(player.can_activate_fusion(), true, "Fusion ready with Disciple and >=40 Ki")

	player.begin_fusion_charge()
	assert_eq(player.state_machine.current_state.name, &"PowerUp", "Fusion begins in PowerUp state")
	assert_eq(player.aura_sprite.visible, true, "KiAura shows while charging Fusion")
	for i in 32:
		await get_tree().physics_frame
	assert_eq(player.is_fusion_active, true, "Player is in Fusion form after PowerUp")
	assert_eq(player.is_weapon_suppressed(), true, "Weapon suppressed while Fused")
	assert_eq(player.aura_sprite.visible, false, "KiAura hides after Fusion activates")
	assert_eq(player.stats_component.damage_multiplier, 2.2, "Fusion multiplier is 2.2x")
	assert_eq(disciple.visible, false, "Disciple hides while fused")

	player.set_fusion(false)
	assert_eq(player.is_fusion_active, false, "Fusion ends cleanly")
	assert_eq(disciple.visible, true, "Disciple reappears after Fusion ends")
	assert_eq(player.fusion_cooldown_timer, 30.0, "30s Fusion cooldown starts")
	assert_eq(player.can_activate_fusion(), false, "Cannot re-fuse while on cooldown")

	scene.queue_free()
	await get_tree().process_frame
	GameManager.reset_run_data()
	QuestManager.reset_quests()
	return true


func test_master_npc_timeskip_quests() -> bool:
	GameManager.reset_run_data()
	QuestManager.reset_quests()

	var packed := load("res://world/peaceful_planet/peaceful_village.tscn") as PackedScene
	var scene := packed.instantiate()
	get_tree().root.add_child(scene)
	await get_tree().physics_frame

	var master := scene.get_node("MasterNPC") as MasterNPC
	var dialogue_box := scene.get_node("DialogueBox") as DialogueBox
	assert_true(master != null, "MasterNPC exists")

	master.interact()
	if dialogue_box.visible:
		dialogue_box.close()
	assert_eq(QuestManager.is_quest_active(&"rescue_disciple"), true, "Master starts rescue_disciple quest")

	EventBus.enemy_killed.emit(&"prison_warden")
	assert_eq(QuestManager.is_quest_ready_to_turn_in(&"rescue_disciple"), true, "Warden kill completes Master quest")

	await master.interact()
	if dialogue_box.visible:
		dialogue_box.close()
	assert_eq(GameManager.current_run_data["growth_stage"], &"teen", "Timeskip advances Player to Teen stage")

	scene.queue_free()
	await get_tree().process_frame
	GameManager.reset_run_data()
	QuestManager.reset_quests()
	return true


func test_menus_layout_960x540() -> bool:
	var vp := SubViewport.new()
	vp.size = Vector2i(960, 540)
	get_tree().root.add_child(vp)

	var main_menu := (load("res://ui/menus/main_menu.tscn") as PackedScene).instantiate() as Control
	vp.add_child(main_menu)
	await get_tree().process_frame
	await get_tree().process_frame
	var screen := Rect2(Vector2.ZERO, Vector2(960, 540))
	var mm_panel := main_menu.get_node("Center/Panel") as Control
	assert_true(screen.encloses(mm_panel.get_global_rect()), "MainMenu fits inside 960x540")
	assert_true(vp.gui_get_focus_owner() != null, "MainMenu grabs focus")
	main_menu.queue_free()

	var pause_menu := (load("res://ui/menus/pause_menu.tscn") as PackedScene).instantiate() as PauseMenu
	vp.add_child(pause_menu)
	pause_menu.open_menu()
	await get_tree().process_frame
	await get_tree().process_frame
	var pm_panel := pause_menu.get_node("Root/Center/Panel") as Control
	assert_true(screen.encloses(pm_panel.get_global_rect()), "PauseMenu fits inside 960x540")
	pause_menu.close_menu()

	vp.queue_free()
	await get_tree().process_frame
	return true
