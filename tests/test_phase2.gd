# Run: godot --headless --path . res://tests/test_phase2.tscn
extends Node

var passed: int = 0
var failed: int = 0


func _ready() -> void:
	await _run_all()
	print("Phase 2 Test Results: %d passed, %d failed" % [passed, failed])
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
		"test_ki_blast_and_overdrive",
		"test_awakening_skills_and_weapon_upgrade",
		"test_save_and_load_roundtrip",
		"test_awakening_menu_layout_960x540",
	]:
		var ok: Variant = await call(t)
		if ok != true:
			failed += 1
			push_error("FAIL %s: aborted with runtime error" % t)
	await get_tree().process_frame


func test_ki_blast_and_overdrive() -> bool:
	GameManager.reset_run_data()
	var packed := load("res://world/peaceful_planet/peaceful_village.tscn") as PackedScene
	var scene := packed.instantiate()
	get_tree().root.add_child(scene)
	await get_tree().physics_frame

	var player := scene.get_node("Player") as Player
	assert_true(player.ki_component != null, "Player has KiComponent")

	var ki_before: float = player.ki_component.current_ki
	assert_eq(player.fire_ki_blast(), true, "KiBlast fires when enough Ki")
	assert_eq(player.ki_component.current_ki, ki_before - player.ki_blast_cost, "KiBlast consumes Ki")
	var fired_blast: KiBlast = null
	for child in scene.get_children():
		if child is KiBlast:
			fired_blast = child as KiBlast
			break
	assert_true(fired_blast != null and fired_blast.animated_sprite != null, "KiBlast uses AnimatedSprite2D")
	if fired_blast != null and fired_blast.animated_sprite != null:
		assert_eq(fired_blast.animated_sprite.animation, &"fly", "KiBlast starts with fly animation")
		fired_blast._consume()
		assert_eq(fired_blast.animated_sprite.animation, &"hit", "KiBlast plays hit burst animation on impact")

	assert_eq(player.can_activate_overdrive(), false, "Overdrive locked in Child stage")
	player.set_overdrive(true)
	assert_eq(player.is_overdrive_active, false, "Child cannot activate Overdrive")

	GameManager.set_growth_stage(&"adult")
	assert_eq(player.can_activate_overdrive(), true, "Overdrive unlocked in Adult stage")
	player.toggle_overdrive()
	assert_eq(player.state_machine.current_state.name, &"PowerUp", "Overdrive charge enters PowerUp state")
	assert_eq(player.animated_sprite.animation, &"overdrive_in", "Adult PowerUp plays dedicated overdrive_in animation")
	assert_eq(player.aura_sprite.visible, false, "Legacy KiAura stays hidden when dedicated overdrive_in plays")

	for i in 32:
		await get_tree().physics_frame
	assert_eq(player.is_overdrive_active, true, "Overdrive activates after PowerUp")
	assert_eq(player.animated_sprite.sprite_frames, load("res://assets/sprites/player/adult_overdrive/adult_overdrive_sprite_frames.tres"), "Adult Overdrive switches to adult_overdrive_sprite_frames.tres")
	assert_eq(player.animated_sprite.offset, Vector2.ZERO, "Sprite offset resets to zero after overdrive_in")
	assert_eq(player.stats_component.damage_multiplier, 2.1, "Adult Overdrive increases damage multiplier")
	assert_eq(player.is_weapon_suppressed(), true, "Weapon suppressed during Overdrive (unarmed combat)")
	assert_eq(player.get_melee_air_anim(), &"air_attack_bare", "Adult Overdrive uses dedicated air_attack_bare")
	assert_eq(player.get_melee_dash_anim(), &"dash_attack_bare", "Adult Overdrive uses dedicated dash_attack_bare")
	player.configure_attack_hitbox(1.0, 1.0, 1.0)
	assert_eq(player.hitbox_component.damage, 21.0, "Overdrive melee excludes weapon bonus (10 * 2.1)")

	var beam_ki_before: float = player.ki_component.current_ki
	assert_eq(player.can_use_special_skill(), true, "SpecialSkill [U] ready while Overdrive active")
	player.state_machine.change_state(&"SpecialSkill")
	assert_eq(player.state_machine.current_state.name, &"SpecialSkill", "Player enters SpecialSkill state")
	for i in 12:
		await get_tree().physics_frame
	var fired_beam: OverdriveBeam = null
	for child in scene.get_children():
		if child is OverdriveBeam:
			fired_beam = child as OverdriveBeam
			break
	assert_true(fired_beam != null, "SpecialSkill spawns OverdriveBeam in scene")
	assert_true(player.ki_component.current_ki < beam_ki_before - 29.0, "SpecialSkill consumes 30 Ki")
	for i in 22:
		await get_tree().physics_frame

	player.ki_component.drain_ki(999.0)
	assert_eq(player.state_machine.current_state.name, &"PowerDown", "Depleting Ki in Adult Overdrive enters PowerDown")
	assert_eq(player.animated_sprite.animation, &"overdrive_out", "PowerDown plays dedicated overdrive_out animation")
	for i in 30:
		await get_tree().physics_frame
	assert_eq(player.is_overdrive_active, false, "Overdrive auto-disables after PowerDown completes")
	assert_eq(player.animated_sprite.sprite_frames, load("res://assets/sprites/player/adult/adult_sprite_frames.tres"), "Reverts to adult_sprite_frames.tres after PowerDown")

	scene.queue_free()
	await get_tree().process_frame
	GameManager.reset_run_data()
	return true


func test_awakening_skills_and_weapon_upgrade() -> bool:
	GameManager.reset_run_data()
	var packed := load("res://world/peaceful_planet/peaceful_village.tscn") as PackedScene
	var scene := packed.instantiate()
	get_tree().root.add_child(scene)
	await get_tree().physics_frame

	var player := scene.get_node("Player") as Player
	GameManager.add_essence(200)
	GameManager.spend_essence(50)
	GameManager.unlock_skill(&"vitality_surge")
	GameManager.spend_essence(75)
	GameManager.unlock_skill(&"martial_focus")

	assert_eq(player.health_component.max_health, 125.0, "Vitality Surge raises max HP to 125")
	assert_eq(player.stats_component.base_attack_damage, 14.0, "Martial Focus raises base damage to 14")

	assert_eq(player.weapon_component.try_upgrade_equipped(), true, "Weapon upgrades with remaining Essence")
	assert_eq(player.weapon_component.equipped_weapon.upgrade_level, 1, "Weapon upgrade level is 1")

	scene.queue_free()
	await get_tree().process_frame
	GameManager.reset_run_data()
	return true


func test_save_and_load_roundtrip() -> bool:
	GameManager.reset_run_data()
	GameManager.add_essence(123)
	GameManager.unlock_skill(&"swift_step")
	GameManager.current_run_data["weapon_states"][&"travelers_staff"] = {"durability": 5, "upgrade_level": 2}
	assert_eq(SaveManager.save_game("res://world/peaceful_planet/peaceful_village.tscn"), true, "SaveManager writes save file")

	GameManager.reset_run_data()
	assert_eq(int(GameManager.current_run_data["essence"]), 0, "Essence reset before load")

	var loaded := SaveManager.load_game()
	assert_true(not loaded.is_empty(), "SaveManager loads save file")
	assert_eq(int(GameManager.current_run_data["essence"]), 123, "Essence restored from save")
	assert_eq(GameManager.has_skill(&"swift_step"), true, "Unlocked skill restored from save")
	assert_eq(int(GameManager.current_run_data["weapon_states"]["travelers_staff"]["upgrade_level"]), 2, "Weapon upgrade restored")

	if FileAccess.file_exists(SaveManager.SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SaveManager.SAVE_PATH))
	GameManager.reset_run_data()
	return true


func test_awakening_menu_layout_960x540() -> bool:
	var vp := SubViewport.new()
	vp.size = Vector2i(960, 540)
	get_tree().root.add_child(vp)

	var menu := (load("res://ui/awakening_menu/awakening_menu.tscn") as PackedScene).instantiate() as AwakeningMenu
	vp.add_child(menu)
	menu.open_for_player(null)
	await get_tree().process_frame
	await get_tree().process_frame

	var panel := menu.get_node("Root/Center/Panel") as Control
	var screen := Rect2(Vector2.ZERO, Vector2(960, 540))
	assert_true(screen.encloses(panel.get_global_rect()), "AwakeningMenu panel fits inside 960x540 viewport")
	assert_true(vp.gui_get_focus_owner() != null, "AwakeningMenu grabs focus when opened")

	menu.close_menu()
	vp.queue_free()
	await get_tree().process_frame
	return true
