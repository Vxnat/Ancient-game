class_name Player
extends CharacterBody2D
## Player controller delegating movement/combat behaviors to StateMachine child states.

signal state_changed(state_name: StringName)

const DEFAULT_WEAPON_PATH: String = "res://data/weapons/travelers_staff.tres"
const FUSION_FORM_PATH: String = "res://data/forms/fusion_form.tres"
const KI_BLAST_SCENE: PackedScene = preload("res://combat/projectiles/ki_blast.tscn")
const OVERDRIVE_BEAM_SCENE: PackedScene = preload("res://combat/projectiles/overdrive_beam.tscn")
const HIT_SPARK_SCENE: PackedScene = preload("res://combat/vfx/hit_spark.tscn")
const DASH_GHOST_SCRIPT: Script = preload("res://combat/vfx/dash_ghost.gd")

const GROWTH_FORMS: Dictionary = {
	&"child": {
		"base": "res://data/forms/child_base.tres",
		"overdrive": "res://data/forms/child_overdrive.tres",
		"sprite_frames": "res://assets/sprites/player/child/child_sprite_frames.tres",
		"visual_scale": Vector2(1.0, 1.0),
		"collider_scale": Vector2(1.0, 1.0),
	},
	&"teen": {
		"base": "res://data/forms/teen_base.tres",
		"overdrive": "res://data/forms/teen_overdrive.tres",
		"sprite_frames": "res://assets/sprites/player/teen/teen_sprite_frames.tres",
		"visual_scale": Vector2(1.0, 1.0),
		"collider_scale": Vector2(1.12, 1.14),
	},
	&"adult": {
		"base": "res://data/forms/adult_base.tres",
		"overdrive": "res://data/forms/adult_overdrive.tres",
		"sprite_frames": "res://assets/sprites/player/adult/adult_sprite_frames.tres",
		"overdrive_sprite_frames": "res://assets/sprites/player/adult_overdrive/adult_overdrive_sprite_frames.tres",
		"visual_scale": Vector2(1.0, 1.0),
		"collider_scale": Vector2(1.24, 1.28),
	},
}

const COYOTE_TICKS: int = 6       # ~0.10s at 60 Hz
const BUFFER_TICKS: int = 7       # ~0.12s at 60 Hz
const NEVER_TICK: int = -1000000

@export_group("Movement & Jump Feel")
@export var ground_accel: float = 2400.0
@export var air_control_mult: float = 0.65
@export var rise_gravity: float = 1150.0
@export var fall_gravity_mult: float = 1.8
@export var apex_hang_mult: float = 0.5
@export var apex_velocity_threshold: float = 55.0
@export var max_fall_speed: float = 520.0
@export var jump_cut_mult: float = 0.45

@export_group("Dash & Combat")
@export var dash_speed: float = 480.0
@export var dash_duration: float = 0.15
@export var dash_cooldown: float = 0.28
@export var bare_hand_range: float = 32.0
@export var hitstop_duration: float = 0.055
@export var hitstop_time_scale: float = 0.05

@export_group("Ki, Overdrive & Fusion")
@export var ki_blast_cost: float = 20.0
@export var ki_blast_damage: float = 14.0
@export var ki_gain_on_melee_hit: float = 6.0
@export var overdrive_min_ki: float = 25.0
@export var fusion_ki_cost: float = 40.0
@export var fusion_duration: float = 15.0
@export var fusion_cooldown: float = 30.0

@onready var state_machine: StateMachine = $StateMachine
@onready var health_component: HealthComponent = $HealthComponent
@onready var ki_component: KiComponent = $KiComponent
@onready var stats_component: StatsComponent = $StatsComponent
@onready var weapon_component: WeaponComponent = $WeaponComponent
@onready var hitbox_component: HitboxComponent = $VisualPivot/HitboxComponent
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var body_collision: CollisionShape2D = $CollisionShape2D
@onready var hurtbox_collision: CollisionShape2D = $HurtboxComponent/CollisionShape2D
@onready var visual_pivot: Node2D = $VisualPivot
@onready var aura_sprite: AnimatedSprite2D = $VisualPivot/KiAura
@onready var animated_sprite: AnimatedSprite2D = $VisualPivot/AnimatedSprite
@onready var hitbox_shape: CollisionShape2D = $VisualPivot/HitboxComponent/CollisionShape2D

var facing_direction: int = 1
var physics_tick: int = 0
var last_ground_tick: int = NEVER_TICK
var last_jump_press_tick: int = NEVER_TICK
var dash_cooldown_timer: float = 0.0
var has_air_dash: bool = true
var is_overdrive_active: bool = false
var is_fusion_active: bool = false
var fusion_active_timer: float = 0.0
var fusion_cooldown_timer: float = 0.0
var pending_power_up_mode: StringName = &""
var combo_step: int = 0
var combo_reset_timer: float = 0.0
var attack_hitstop_mult: float = 1.0

var _hitstop_id: int = 0
var _squash_tween: Tween
var _hurt_flash_tween: Tween


func _ready() -> void:
	add_to_group(&"player")
	hitbox_component.source_entity = self
	hitbox_component.hit_landed.connect(_on_attack_hit_landed)
	health_component.health_changed.connect(_on_health_changed)
	health_component.damaged.connect(_on_damaged)
	health_component.died.connect(_on_died)
	ki_component.ki_changed.connect(_on_ki_changed)
	ki_component.ki_depleted.connect(_on_ki_depleted)
	weapon_component.weapon_changed.connect(_on_weapon_changed)
	weapon_component.weapon_broke.connect(_on_weapon_broke)
	EventBus.skill_unlocked.connect(_on_skill_unlocked)
	EventBus.growth_stage_changed.connect(_on_growth_stage_changed)

	restore_from_run_data()
	_place_at_target_spawn()
	if aura_sprite != null:
		aura_sprite.visible = false
	play_animation(&"idle")


func _physics_process(delta: float) -> void:
	physics_tick += 1
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer = maxf(0.0, dash_cooldown_timer - delta)
	if combo_reset_timer > 0.0 and state_machine.current_state != null and state_machine.current_state.name != &"Attack":
		combo_reset_timer = maxf(0.0, combo_reset_timer - delta)
		if combo_reset_timer <= 0.0:
			combo_step = 0

	if is_fusion_active:
		fusion_active_timer = maxf(0.0, fusion_active_timer - delta)
		EventBus.fusion_status_updated.emit(fusion_active_timer, fusion_cooldown_timer)
		if fusion_active_timer <= 0.0:
			set_fusion(false)
	elif fusion_cooldown_timer > 0.0:
		fusion_cooldown_timer = maxf(0.0, fusion_cooldown_timer - delta)
		EventBus.fusion_status_updated.emit(0.0, fusion_cooldown_timer)

	if is_on_floor() and velocity.y >= 0.0:
		last_ground_tick = physics_tick
		has_air_dash = true
	if Input.is_action_just_pressed("jump"):
		last_jump_press_tick = physics_tick
	if Input.is_action_just_pressed("overdrive") and not is_fusion_active:
		toggle_overdrive()
	if Input.is_action_just_pressed("fusion"):
		begin_fusion_charge()

	if is_overdrive_active and not is_fusion_active and stats_component.active_form != null:
		var form := stats_component.active_form
		ki_component.drain_ki(form.ki_drain_per_sec * delta)
		if form.hp_drain_per_sec > 0.0 and health_component.current_health > 1.0:
			var next_hp: float = maxf(1.0, health_component.current_health - form.hp_drain_per_sec * delta)
			health_component.current_health = next_hp
			_on_health_changed(health_component.current_health, health_component.max_health)


func _unhandled_input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_T:
		debug_promote_to_adult()


func debug_promote_to_adult() -> void:
	if is_fusion_active:
		set_fusion(false)
	if is_overdrive_active:
		set_overdrive(false)
	GameManager.set_growth_stage(&"adult")
	health_component.initialize(health_component.max_health, health_component.max_health)
	ki_component.initialize(ki_component.max_ki, ki_component.max_ki)


func get_move_input() -> float:
	return Input.get_axis("move_left", "move_right")


func set_facing(dir: float) -> void:
	if dir > 0.01:
		facing_direction = 1
	elif dir < -0.01:
		facing_direction = -1
	var s := _get_visual_scale()
	visual_pivot.scale = Vector2(float(facing_direction) * s.x, s.y)


func has_animation(anim_name: StringName) -> bool:
	return animated_sprite != null and animated_sprite.sprite_frames != null and animated_sprite.sprite_frames.has_animation(anim_name)


func play_animation(anim_name: StringName, force_restart: bool = false) -> void:
	if has_animation(anim_name):
		if force_restart or animated_sprite.animation != anim_name or not animated_sprite.is_playing():
			animated_sprite.play(anim_name)


func is_weapon_suppressed() -> bool:
	return is_overdrive_active or is_fusion_active


func is_using_bare_hands() -> bool:
	return is_weapon_suppressed() or weapon_component.is_using_bare_hands()


func get_melee_air_anim() -> StringName:
	if is_using_bare_hands():
		return &"air_attack_bare" if has_animation(&"air_attack_bare") else &"attack_bare_2"
	return &"air_attack_weapon"


func get_melee_dash_anim() -> StringName:
	if is_using_bare_hands():
		return &"dash_attack_bare" if has_animation(&"dash_attack_bare") else &"attack_bare_1"
	return &"dash_attack_weapon"


func has_dedicated_overdrive_sprites() -> bool:
	var stage: StringName = GameManager.current_run_data.get("growth_stage", &"child")
	var cfg: Dictionary = GROWTH_FORMS.get(stage, {})
	var od_path: String = cfg.get("overdrive_sprite_frames", "")
	return od_path != "" and ResourceLoader.exists(od_path)


func begin_transform_frame_offset() -> void:
	if animated_sprite != null:
		animated_sprite.offset = Vector2(0.0, -12.0)


func end_transform_frame_offset() -> void:
	if animated_sprite != null:
		animated_sprite.offset = Vector2.ZERO


func begin_overdrive_out_visual() -> void:
	ki_component.is_draining = false
	if has_animation(&"overdrive_out"):
		begin_transform_frame_offset()
		play_animation(&"overdrive_out", true)
	else:
		play_animation(&"idle")


func handle_horizontal_movement(delta: float, is_grounded: bool) -> void:
	var dir := get_move_input()
	if dir != 0.0:
		set_facing(dir)
	var target_speed: float = dir * stats_component.get_move_speed()
	var accel: float = ground_accel if is_grounded else ground_accel * air_control_mult
	velocity.x = move_toward(velocity.x, target_speed, accel * delta)


func apply_platformer_gravity(delta: float) -> void:
	var grav: float = rise_gravity * fall_gravity_mult if velocity.y > 0.0 else rise_gravity
	if Input.is_action_pressed("jump") and absf(velocity.y) < apex_velocity_threshold:
		grav *= apex_hang_mult
	velocity.y = minf(velocity.y + grav * delta, max_fall_speed)


func can_consume_buffered_jump() -> bool:
	return (physics_tick - last_jump_press_tick) <= BUFFER_TICKS and (physics_tick - last_ground_tick) <= COYOTE_TICKS


func consume_jump() -> void:
	velocity.y = stats_component.base_jump_velocity
	last_jump_press_tick = NEVER_TICK
	last_ground_tick = NEVER_TICK
	if not Input.is_action_pressed("jump"):
		velocity.y *= jump_cut_mult
	play_squash(Vector2(0.84, 1.18))


func can_dash() -> bool:
	return dash_cooldown_timer <= 0.0


func can_air_dash() -> bool:
	return GameManager.has_skill(&"air_dash") and has_air_dash and dash_cooldown_timer <= 0.0


func consume_air_dash() -> void:
	has_air_dash = false


func spawn_dash_ghost() -> void:
	if animated_sprite == null or animated_sprite.sprite_frames == null:
		return
	var tex := animated_sprite.sprite_frames.get_frame_texture(animated_sprite.animation, animated_sprite.frame)
	if tex == null:
		return
	var container: Node = get_parent() if get_parent() != null else get_tree().current_scene
	if container == null:
		return
	var ghost := DASH_GHOST_SCRIPT.new() as DashGhost
	container.add_child(ghost)
	var ghost_tint := Color(0.78, 0.42, 1.0, 0.55) if is_fusion_active else (Color(1.0, 0.72, 0.2, 0.55) if is_overdrive_active else Color(0.35, 0.88, 1.0, 0.55))
	ghost.setup(tex, animated_sprite.global_position, facing_direction < 0, _get_visual_scale(), ghost_tint)


func can_cast_ki_blast() -> bool:
	return ki_component.has_ki(ki_blast_cost)


func can_use_special_skill() -> bool:
	return (is_overdrive_active or is_fusion_active) and ki_component.has_ki(30.0)


func spawn_overdrive_beam() -> bool:
	if not (is_overdrive_active or is_fusion_active):
		return false
	if not ki_component.consume_ki(30.0):
		return false
	var beam := OVERDRIVE_BEAM_SCENE.instantiate() as OverdriveBeam
	if beam == null:
		return false
	var spawn_pos: Vector2 = global_position + Vector2(float(facing_direction) * 26.0, -32.0)
	var dmg: float = stats_component.get_attack_damage(0.0) * 3.0
	var container: Node = get_parent() if get_parent() != null else get_tree().current_scene
	if container == null:
		beam.free()
		return false
	container.add_child(beam)
	beam.setup(float(facing_direction), dmg, self)
	beam.global_position = spawn_pos
	play_squash(Vector2(1.16, 0.88), 0.14)
	add_trauma(0.45)
	return true


func fire_ki_blast() -> bool:
	if not ki_component.consume_ki(ki_blast_cost):
		return false
	var blast := KI_BLAST_SCENE.instantiate() as KiBlast
	if blast == null:
		return false
	var spawn_pos: Vector2 = global_position + Vector2(float(facing_direction) * 24.0, -28.0)
	var dmg: float = (ki_blast_damage + (stats_component.base_attack_damage - 10.0)) * stats_component.damage_multiplier
	var container: Node = get_parent() if get_parent() != null else get_tree().current_scene
	container.add_child(blast)
	blast.setup(spawn_pos, facing_direction, dmg, self, is_overdrive_active or is_fusion_active)
	return true


func can_activate_overdrive() -> bool:
	var stage: StringName = GameManager.current_run_data.get("growth_stage", &"child")
	return (
		not is_overdrive_active
		and not is_fusion_active
		and stage == &"adult"
		and ki_component.has_ki(overdrive_min_ki)
	)


func toggle_overdrive() -> void:
	if is_overdrive_active:
		if has_dedicated_overdrive_sprites() and state_machine.current_state.name != &"PowerDown" and state_machine.current_state.name != &"PowerUp":
			state_machine.change_state(&"PowerDown")
		else:
			set_overdrive(false)
	elif can_activate_overdrive() and state_machine.current_state.name != &"PowerUp" and state_machine.current_state.name != &"PowerDown":
		pending_power_up_mode = &"overdrive"
		state_machine.change_state(&"PowerUp")


func set_overdrive(active: bool) -> void:
	if is_fusion_active:
		return
	if active == is_overdrive_active:
		return
	if active and not can_activate_overdrive():
		return

	is_overdrive_active = active
	ki_component.is_draining = active
	_apply_active_form()
	_apply_growth_visuals()
	if active:
		play_squash(Vector2(1.18, 0.86), 0.16)
		add_trauma(0.4)
	EventBus.overdrive_toggled.emit(active)


func can_activate_fusion() -> bool:
	return (
		not is_fusion_active
		and bool(GameManager.current_run_data.get("has_disciple", false))
		and fusion_cooldown_timer <= 0.0
		and ki_component.has_ki(fusion_ki_cost)
	)


func begin_fusion_charge() -> void:
	if can_activate_fusion() and state_machine.current_state.name != &"PowerUp":
		pending_power_up_mode = &"fusion"
		state_machine.change_state(&"PowerUp")


func try_activate_fusion() -> bool:
	if not can_activate_fusion():
		return false
	ki_component.consume_ki(fusion_ki_cost)
	set_fusion(true)
	return true


func set_fusion(active: bool) -> void:
	if active == is_fusion_active:
		return
	if active and is_overdrive_active:
		set_overdrive(false)

	is_fusion_active = active
	ki_component.is_draining = false
	if active:
		fusion_active_timer = fusion_duration
		var fusion_form := load(FUSION_FORM_PATH) as FormData
		stats_component.apply_form(fusion_form)
		if fusion_form != null:
			GameManager.current_run_data["current_form_id"] = fusion_form.id
			EventBus.form_changed.emit(fusion_form.id)
		play_squash(Vector2(1.22, 0.82), 0.18)
		add_trauma(0.55)
		EventBus.fusion_status_updated.emit(fusion_active_timer, fusion_cooldown_timer)
	else:
		fusion_active_timer = 0.0
		fusion_cooldown_timer = fusion_cooldown
		_apply_active_form()
		EventBus.fusion_status_updated.emit(0.0, fusion_cooldown_timer)

	_update_palette_shader()
	EventBus.fusion_toggled.emit(active)


func set_power_up_aura(visible_aura: bool, mode: StringName) -> void:
	if visible_aura and mode == &"overdrive" and has_dedicated_overdrive_sprites() and has_animation(&"overdrive_in"):
		if aura_sprite != null:
			aura_sprite.visible = false
			aura_sprite.stop()
		begin_transform_frame_offset()
		play_animation(&"overdrive_in", true)
		return
	if not visible_aura:
		end_transform_frame_offset()
	else:
		play_animation(&"idle")
	if aura_sprite == null:
		return
	aura_sprite.visible = visible_aura
	if visible_aura:
		var mat := aura_sprite.material as ShaderMaterial
		if mat != null:
			mat.set_shader_parameter("aura_mode", 2 if mode == &"fusion" else 1)
		aura_sprite.play(&"aura")
	else:
		aura_sprite.stop()


func complete_pending_power_up() -> void:
	var mode := pending_power_up_mode
	pending_power_up_mode = &""
	if mode == &"overdrive":
		set_overdrive(true)
	elif mode == &"fusion":
		try_activate_fusion()


func trigger_hitstop(duration: float = hitstop_duration, slow_scale: float = hitstop_time_scale) -> void:
	_hitstop_id += 1
	var my_id: int = _hitstop_id
	Engine.time_scale = slow_scale
	await get_tree().create_timer(duration, true, false, true).timeout
	if my_id == _hitstop_id:
		Engine.time_scale = 1.0


func play_squash(start_scale: Vector2, duration: float = 0.14) -> void:
	if animated_sprite == null:
		return
	if _squash_tween != null:
		_squash_tween.kill()
	animated_sprite.scale = start_scale
	_squash_tween = create_tween()
	_squash_tween.tween_property(animated_sprite, "scale", Vector2.ONE, duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func add_trauma(amount: float) -> void:
	for cam in get_tree().get_nodes_in_group(&"game_camera"):
		if cam is GameCamera:
			(cam as GameCamera).add_trauma(amount)


func configure_attack_hitbox(damage_mult: float = 1.0, range_mult: float = 1.0, knockback_mult: float = 1.0) -> void:
	var weapon_bonus: float = 0.0 if is_weapon_suppressed() else weapon_component.get_weapon_bonus_damage()
	hitbox_component.damage = stats_component.get_attack_damage(weapon_bonus) * damage_mult
	hitbox_component.knockback_force = Vector2(140.0 * knockback_mult, -70.0 * knockback_mult)

	var attack_range: float = bare_hand_range
	if not is_using_bare_hands():
		attack_range = weapon_component.equipped_weapon.data.attack_range

	var scale_mult: float = 1.0
	if stats_component.active_form != null:
		scale_mult = stats_component.active_form.hitbox_scale.x
	attack_range *= scale_mult * range_mult

	var rect_shape := hitbox_shape.shape as RectangleShape2D
	if rect_shape != null:
		rect_shape.size = Vector2(attack_range, 40.0)
	hitbox_shape.position = Vector2(attack_range * 0.5 + 6.0, -26.0)


func notify_state_entered(state_name: StringName) -> void:
	state_changed.emit(state_name)


func restore_from_run_data() -> void:
	apply_unlocked_skills(false)
	var run_data: Dictionary = GameManager.current_run_data
	health_component.initialize(float(run_data["max_hp"]), float(run_data["current_hp"]))
	ki_component.initialize(float(run_data["max_ki"]), float(run_data["current_ki"]))

	_apply_growth_visuals()
	_apply_active_form()
	_update_palette_shader()

	if ResourceLoader.exists(DEFAULT_WEAPON_PATH):
		var weapon_res := load(DEFAULT_WEAPON_PATH) as WeaponData
		if weapon_res != null:
			var weapon_states: Dictionary = run_data["weapon_states"]
			var saved: Dictionary = weapon_states.get(weapon_res.id, {})
			var dur: int = int(saved.get("durability", weapon_res.max_durability))
			var lvl: int = int(saved.get("upgrade_level", 0))
			var instance := WeaponInstance.new(weapon_res, dur, lvl)
			weapon_component.equip_weapon(instance)
			_sync_weapon_to_run_data()


func apply_unlocked_skills(emit_updates: bool = true) -> void:
	var unlocked: Array = GameManager.current_run_data["unlocked_skills"]
	var target_max_hp: float = 100.0 + (25.0 if &"vitality_surge" in unlocked else 0.0)
	var target_max_ki: float = 100.0 + (30.0 if &"ki_reservoir" in unlocked else 0.0)
	var target_ki_regen: float = 6.0 + (2.0 if &"ki_reservoir" in unlocked else 0.0)
	var target_attack: float = 10.0 + (4.0 if &"martial_focus" in unlocked else 0.0)
	var target_speed: float = 230.0 + (35.0 if &"swift_step" in unlocked else 0.0)

	stats_component.base_attack_damage = target_attack
	stats_component.base_move_speed = target_speed
	ki_component.passive_regen_per_sec = target_ki_regen

	GameManager.current_run_data["max_hp"] = target_max_hp
	GameManager.current_run_data["max_ki"] = target_max_ki
	if emit_updates:
		health_component.initialize(target_max_hp, minf(target_max_hp, health_component.current_health + 25.0))
		ki_component.initialize(target_max_ki, minf(target_max_ki, ki_component.current_ki + 30.0))


func sync_weapon_to_run_data() -> void:
	_sync_weapon_to_run_data()


func _get_visual_scale() -> Vector2:
	var stage: StringName = GameManager.current_run_data.get("growth_stage", &"child")
	var cfg: Dictionary = GROWTH_FORMS.get(stage, GROWTH_FORMS[&"child"])
	return cfg["visual_scale"]


func _get_collider_scale() -> Vector2:
	var stage: StringName = GameManager.current_run_data.get("growth_stage", &"child")
	var cfg: Dictionary = GROWTH_FORMS.get(stage, GROWTH_FORMS[&"child"])
	return cfg["collider_scale"]


func _apply_growth_visuals() -> void:
	var stage: StringName = GameManager.current_run_data.get("growth_stage", &"child")
	var cfg: Dictionary = GROWTH_FORMS.get(stage, GROWTH_FORMS[&"child"])
	var use_dedicated_overdrive: bool = is_overdrive_active and not is_fusion_active and cfg.has("overdrive_sprite_frames")
	var sf_path: String = cfg.get("overdrive_sprite_frames", "") if use_dedicated_overdrive else cfg.get("sprite_frames", "")
	if animated_sprite != null and sf_path != "" and ResourceLoader.exists(sf_path):
		var target_sf := load(sf_path) as SpriteFrames
		if target_sf != null and animated_sprite.sprite_frames != target_sf:
			var cur_anim: StringName = animated_sprite.animation
			animated_sprite.sprite_frames = target_sf
			if cur_anim == &"overdrive_in" or cur_anim == &"overdrive_out":
				animated_sprite.play(&"idle")
			elif target_sf.has_animation(cur_anim):
				animated_sprite.play(cur_anim)
			elif target_sf.has_animation(&"idle"):
				animated_sprite.play(&"idle")

	var vs: Vector2 = _get_visual_scale()
	if visual_pivot != null:
		visual_pivot.scale = Vector2(float(facing_direction) * vs.x, vs.y)
	_update_palette_shader()
	var cs: Vector2 = _get_collider_scale()
	var scaled_size := Vector2(20.0 * cs.x, 52.0 * cs.y)
	var scaled_pos := Vector2(0.0, -scaled_size.y * 0.5)
	if body_collision != null and body_collision.shape is RectangleShape2D:
		(body_collision.shape as RectangleShape2D).size = scaled_size
		body_collision.position = scaled_pos
	if hurtbox_collision != null and hurtbox_collision.shape is RectangleShape2D:
		(hurtbox_collision.shape as RectangleShape2D).size = scaled_size
		hurtbox_collision.position = scaled_pos


func _apply_active_form() -> void:
	if is_fusion_active:
		return
	var stage: StringName = GameManager.current_run_data.get("growth_stage", &"child")
	var cfg: Dictionary = GROWTH_FORMS.get(stage, GROWTH_FORMS[&"child"])
	var path: String = cfg["overdrive"] if is_overdrive_active else cfg["base"]
	var form := load(path) as FormData
	stats_component.apply_form(form)
	if form != null:
		GameManager.current_run_data["current_form_id"] = form.id
		EventBus.form_changed.emit(form.id)


func _update_palette_shader() -> void:
	if animated_sprite == null:
		return
	var mat := animated_sprite.material as ShaderMaterial
	if mat == null:
		return
	var mode: int = 0
	if is_fusion_active:
		mode = 2
	elif is_overdrive_active and not has_dedicated_overdrive_sprites():
		mode = 1
	var stage: StringName = GameManager.current_run_data.get("growth_stage", &"child")
	var cutoff: float = 0.60 if stage == &"child" else 0.55
	mat.set_shader_parameter("transform_mode", mode)
	mat.set_shader_parameter("hair_uv_cutoff", cutoff)


func _place_at_target_spawn() -> void:
	if GameManager.target_spawn_point == &"" or get_parent() == null:
		return
	var marker := get_parent().get_node_or_null(NodePath(GameManager.target_spawn_point)) as Node2D
	if marker != null:
		global_position = marker.global_position


func _sync_weapon_to_run_data() -> void:
	var w := weapon_component.equipped_weapon
	if w != null and w.data != null:
		GameManager.current_run_data["equipped_weapon_id"] = w.data.id
		GameManager.current_run_data["weapon_states"][w.data.id] = {
			"durability": w.current_durability,
			"upgrade_level": w.upgrade_level,
		}


func _spawn_hit_spark(pos: Vector2) -> void:
	var spark := HIT_SPARK_SCENE.instantiate() as HitSpark
	if spark == null:
		return
	var container: Node = get_parent() if get_parent() != null else get_tree().current_scene
	if container == null:
		spark.free()
		return
	container.add_child(spark)
	var col := Color(0.85, 0.55, 1.0, 1.0) if is_fusion_active else (Color(1.0, 0.7, 0.25, 1.0) if is_overdrive_active else Color(0.6, 0.95, 1.0, 1.0))
	spark.setup(pos, col)


func _on_attack_hit_landed(hurtbox: HurtboxComponent) -> void:
	if not is_weapon_suppressed():
		weapon_component.on_attack_hit(1)
		_sync_weapon_to_run_data()
	if not is_overdrive_active:
		ki_component.restore_ki(ki_gain_on_melee_hit)
	if hurtbox != null:
		_spawn_hit_spark(hurtbox.global_position + Vector2(0.0, -24.0))
	trigger_hitstop(hitstop_duration * attack_hitstop_mult)
	add_trauma(0.35 * attack_hitstop_mult)


func _on_weapon_changed(_weapon: WeaponInstance) -> void:
	_sync_weapon_to_run_data()


func _on_weapon_broke(_weapon_id: StringName) -> void:
	_sync_weapon_to_run_data()


func _on_skill_unlocked(_skill_id: StringName) -> void:
	apply_unlocked_skills(true)


func _on_growth_stage_changed(_stage: StringName) -> void:
	_apply_growth_visuals()
	_apply_active_form()
	play_squash(Vector2(1.18, 1.18), 0.20)


func _on_health_changed(current: float, maximum: float) -> void:
	GameManager.current_run_data["current_hp"] = current
	GameManager.current_run_data["max_hp"] = maximum
	EventBus.player_health_changed.emit(current, maximum)


func _on_ki_changed(current: float, maximum: float) -> void:
	GameManager.current_run_data["current_ki"] = current
	GameManager.current_run_data["max_ki"] = maximum
	EventBus.player_ki_changed.emit(current, maximum)


func _on_ki_depleted() -> void:
	if is_overdrive_active:
		if has_dedicated_overdrive_sprites() and state_machine.current_state.name != &"PowerDown":
			state_machine.change_state(&"PowerDown")
		else:
			set_overdrive(false)


func _on_damaged(_amount: float) -> void:
	play_squash(Vector2(1.18, 0.84), 0.14)
	add_trauma(0.45)
	if animated_sprite != null:
		if _hurt_flash_tween != null:
			_hurt_flash_tween.kill()
		animated_sprite.modulate = Color(1.0, 0.45, 0.45, 1.0)
		_hurt_flash_tween = create_tween()
		_hurt_flash_tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.16)


func _on_died() -> void:
	set_fusion(false)
	set_overdrive(false)
	EventBus.player_died.emit()
	health_component.initialize(health_component.max_health, health_component.max_health)
	ki_component.initialize(ki_component.max_ki, ki_component.max_ki)
	global_position = Vector2(140.0, 480.0)
	velocity = Vector2.ZERO
