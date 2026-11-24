# Run: godot --headless --path . res://tests/test_phase1.tscn
extends Node

var passed: int = 0
var failed: int = 0


func _ready() -> void:
	await _run_all()
	print("Phase 1 Test Results: %d passed, %d failed" % [passed, failed])
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
		"test_weapon_durability_and_bare_hands_fallback",
		"test_weapon_repair_with_essence",
		"test_health_and_hitbox_single_hit",
		"test_peaceful_village_scene_and_player_landing",
	]:
		var ok: Variant = await call(t)
		if ok != true:
			failed += 1
			push_error("FAIL %s: aborted with runtime error" % t)
	await get_tree().process_frame


func test_weapon_durability_and_bare_hands_fallback() -> bool:
	var weapon_data := load("res://data/weapons/travelers_staff.tres") as WeaponData
	assert_true(weapon_data != null, "travelers_staff.tres loads")
	if weapon_data == null:
		return false

	var wc := WeaponComponent.new()
	var wi := WeaponInstance.new(weapon_data, 2, 0)
	wc.equip_weapon(wi)

	assert_eq(wc.is_using_bare_hands(), false, "weapon equipped initially")
	assert_eq(wc.get_weapon_bonus_damage(), weapon_data.base_damage, "weapon bonus damage active")

	wc.on_attack_hit(1)
	assert_eq(wi.current_durability, 1, "durability drops to 1 after 1 hit")
	assert_eq(wc.is_using_bare_hands(), false, "still usable at durability 1")

	wc.on_attack_hit(1)
	assert_eq(wi.current_durability, 0, "durability drops to 0 after 2nd hit")
	assert_eq(wc.is_using_bare_hands(), true, "falls back to bare hands when broken")
	assert_eq(wc.get_weapon_bonus_damage(), 0.0, "weapon bonus damage is 0 when broken")

	wc.free()
	return true


func test_weapon_repair_with_essence() -> bool:
	GameManager.reset_run_data()
	var weapon_data := load("res://data/weapons/travelers_staff.tres") as WeaponData
	var wc := WeaponComponent.new()
	var wi := WeaponInstance.new(weapon_data, 0, 0)
	wc.equip_weapon(wi)

	assert_eq(wc.try_repair_equipped(), false, "cannot repair with 0 essence")

	GameManager.add_essence(50)
	assert_eq(wc.try_repair_equipped(), true, "repair succeeds with enough essence")
	assert_eq(wi.current_durability, weapon_data.max_durability, "durability restored to max")
	assert_eq(wc.is_using_bare_hands(), false, "weapon active again after repair")
	assert_eq(int(GameManager.current_run_data["essence"]), 50 - weapon_data.repair_essence_cost, "essence deducted")

	wc.free()
	GameManager.reset_run_data()
	return true


func test_health_and_hitbox_single_hit() -> bool:
	var hc := HealthComponent.new()
	hc.initialize(50.0, 50.0)
	var hb := HitboxComponent.new()
	hb.damage = 20.0
	var hurt := HurtboxComponent.new()
	hurt.health_component = hc

	hb.set_active(true)
	assert_eq(hb.register_hit(hurt), true, "first hit in swing registers")
	assert_eq(hb.register_hit(hurt), false, "duplicate hit in same swing blocked")

	hc.take_damage(hb.damage)
	assert_eq(hc.current_health, 30.0, "health reduced by 20")

	hc.is_invulnerable = true
	hc.take_damage(99.0)
	assert_eq(hc.current_health, 30.0, "invulnerability blocks damage")

	hurt.free()
	hb.free()
	hc.free()
	return true


func test_peaceful_village_scene_and_player_landing() -> bool:
	GameManager.reset_run_data()
	var packed := load("res://world/peaceful_planet/peaceful_village.tscn") as PackedScene
	assert_true(packed != null, "peaceful_village.tscn loads")
	if packed == null:
		return false

	var scene := packed.instantiate()
	get_tree().root.add_child(scene)

	for i in 20:
		await get_tree().physics_frame

	var player := scene.get_node_or_null("Player") as Player
	var dummy := scene.get_node_or_null("TrainingDummyGround") as TrainingDummy
	assert_true(player != null, "Player node exists in scene")
	assert_true(dummy != null, "TrainingDummyGround node exists in scene")
	if player != null:
		assert_true(player.is_on_floor(), "Player lands cleanly on ground floor")
		assert_true(player.state_machine.current_state != null, "StateMachine initialized")
		assert_eq(player.weapon_component.is_using_bare_hands(), false, "Player starts with Traveler's Staff equipped")
		assert_true(player.animated_sprite != null and player.animated_sprite.sprite_frames != null, "Player AnimatedSprite2D has SpriteFrames")
		for anim_name: StringName in [&"attack_weapon_1", &"attack_weapon_2", &"attack_weapon_3", &"attack_bare_1", &"attack_bare_2", &"attack_bare_3", &"air_attack_weapon", &"dash_attack_weapon"]:
			assert_true(player.animated_sprite.sprite_frames.has_animation(anim_name), "SpriteFrames has %s" % anim_name)

		# Verify 3-hit combo chaining with input buffer and Step 3 lunge
		Input.action_press("attack")
		await get_tree().physics_frame
		await get_tree().physics_frame
		Input.action_release("attack")
		assert_eq(player.state_machine.current_state.name, &"Attack", "J enters Attack state")
		assert_eq(player.animated_sprite.animation, &"attack_weapon_1", "Hit 1 plays attack_weapon_1")

		for i in 6:
			await get_tree().physics_frame
		Input.action_press("attack")
		await get_tree().physics_frame
		await get_tree().physics_frame
		Input.action_release("attack")
		for i in 14:
			await get_tree().physics_frame
		assert_eq(player.animated_sprite.animation, &"attack_weapon_2", "Buffered J chains into attack_weapon_2")

		for i in 6:
			await get_tree().physics_frame
		Input.action_press("attack")
		await get_tree().physics_frame
		await get_tree().physics_frame
		Input.action_release("attack")
		for i in 16:
			await get_tree().physics_frame
		assert_eq(player.animated_sprite.animation, &"attack_weapon_3", "Buffered J chains into attack_weapon_3")
		assert_true(absf(player.velocity.x) > 100.0, "Hit 3 Finisher lunges forward cleanly")

		for i in 30:
			await get_tree().physics_frame

		var ghosts_before: int = 0
		for child in scene.get_children():
			if child is DashGhost:
				ghosts_before += 1
		player.spawn_dash_ghost()
		var ghosts_after: int = 0
		for child in scene.get_children():
			if child is DashGhost:
				ghosts_after += 1
		assert_eq(ghosts_after, ghosts_before + 1, "spawn_dash_ghost creates DashGhost node")

		var start_y: float = player.global_position.y
		Input.action_press("jump")
		var min_y: float = start_y
		for i in 30:
			await get_tree().physics_frame
			min_y = minf(min_y, player.global_position.y)
		Input.action_release("jump")
		var jump_height: float = start_y - min_y
		assert_true(jump_height > 80.0, "Player jump height (%.1f px) clears 75-px platforms" % jump_height)

		# Verify Dash + Attack -> DashAttack and Jump + Attack -> AirAttack
		for i in 24:
			await get_tree().physics_frame
		Input.action_press("dash")
		await get_tree().physics_frame
		await get_tree().physics_frame
		Input.action_release("dash")
		Input.action_press("attack")
		await get_tree().physics_frame
		await get_tree().physics_frame
		Input.action_release("attack")
		assert_eq(player.state_machine.current_state.name, &"DashAttack", "Dash + J enters DashAttack")
		assert_eq(player.animated_sprite.animation, &"dash_attack_weapon", "DashAttack plays dash_attack_weapon")
		for i in 26:
			await get_tree().physics_frame

		Input.action_press("jump")
		await get_tree().physics_frame
		await get_tree().physics_frame
		Input.action_release("jump")
		for i in 3:
			await get_tree().physics_frame
		Input.action_press("attack")
		await get_tree().physics_frame
		await get_tree().physics_frame
		Input.action_release("attack")
		assert_eq(player.state_machine.current_state.name, &"AirAttack", "Jump + J enters AirAttack")
		assert_eq(player.animated_sprite.animation, &"air_attack_weapon", "AirAttack plays air_attack_weapon")

	scene.queue_free()
	await get_tree().process_frame
	GameManager.reset_run_data()
	return true
