class_name GameHUD
extends CanvasLayer
## HUD displaying HP, Ki, Overdrive/Fusion status, Growth Stage, Weapon Durability, Essence, and controls.

@onready var hp_bar: ProgressBar = $TopLeft/Margin/VBox/HpRow/HpBar
@onready var hp_value: Label = $TopLeft/Margin/VBox/HpRow/HpValue
@onready var ki_bar: ProgressBar = $TopLeft/Margin/VBox/KiRow/KiBar
@onready var ki_value: Label = $TopLeft/Margin/VBox/KiRow/KiValue
@onready var weapon_label: Label = $TopLeft/Margin/VBox/WeaponLabel
@onready var essence_label: Label = $TopLeft/Margin/VBox/InfoRow/EssenceLabel
@onready var state_label: Label = $TopLeft/Margin/VBox/InfoRow/StateLabel
@onready var stage_label: Label = $TopLeft/Margin/VBox/AbilityRow/StageLabel
@onready var air_dash_label: Label = $TopLeft/Margin/VBox/AbilityRow/AirDashLabel
@onready var overdrive_label: Label = $TopLeft/Margin/VBox/OverdriveLabel
@onready var special_skill_label: Label = $TopLeft/Margin/VBox/SpecialSkillLabel
@onready var fusion_label: Label = $TopLeft/Margin/VBox/FusionLabel
@onready var overdrive_badge: Label = $TopLeft/Margin/VBox/OverdriveBadge

var _current_weapon_name: String = "Traveler's Staff"
var _weapon_cur_durability: int = 8
var _weapon_max_durability: int = 8
var _is_overdrive_active: bool = false
var _is_fusion_active: bool = false
var _current_ki: float = 100.0


func _ready() -> void:
	EventBus.player_health_changed.connect(_on_health_changed)
	EventBus.player_ki_changed.connect(_on_ki_changed)
	EventBus.essence_changed.connect(_on_essence_changed)
	EventBus.weapon_equipped.connect(_on_weapon_equipped)
	EventBus.weapon_durability_changed.connect(_on_weapon_durability_changed)
	EventBus.weapon_broken.connect(_on_weapon_broken)
	EventBus.overdrive_toggled.connect(_on_overdrive_toggled)
	EventBus.skill_unlocked.connect(_on_skill_unlocked)
	EventBus.growth_stage_changed.connect(_on_growth_stage_changed)
	EventBus.disciple_recruited.connect(_on_disciple_recruited)
	EventBus.fusion_toggled.connect(_on_fusion_toggled)
	EventBus.fusion_status_updated.connect(_on_fusion_status_updated)

	_on_essence_changed(int(GameManager.current_run_data["essence"]))
	_on_health_changed(float(GameManager.current_run_data["current_hp"]), float(GameManager.current_run_data["max_hp"]))
	_on_ki_changed(float(GameManager.current_run_data["current_ki"]), float(GameManager.current_run_data["max_ki"]))
	_on_overdrive_toggled(false)
	_refresh_stage_label()
	_refresh_air_dash_label()
	_refresh_overdrive_label()
	_refresh_special_skill_label()
	_refresh_fusion_label(0.0, 0.0)

	await get_tree().process_frame
	for node in get_tree().get_nodes_in_group(&"player"):
		if node is Player:
			var player := node as Player
			player.state_changed.connect(_on_player_state_changed)
			_on_overdrive_toggled(player.is_overdrive_active)
			_refresh_fusion_label(player.fusion_active_timer, player.fusion_cooldown_timer)
			if player.weapon_component.equipped_weapon != null and player.weapon_component.equipped_weapon.data != null:
				var w := player.weapon_component.equipped_weapon
				_current_weapon_name = w.data.display_name
				_on_weapon_durability_changed(w.data.id, w.current_durability, w.data.max_durability)


func _on_health_changed(current: float, maximum: float) -> void:
	if hp_bar != null:
		hp_bar.max_value = maximum
		hp_bar.value = current
	if hp_value != null:
		hp_value.text = "%d/%d" % [int(ceil(current)), int(maximum)]


func _on_ki_changed(current: float, maximum: float) -> void:
	_current_ki = current
	if ki_bar != null:
		ki_bar.max_value = maximum
		ki_bar.value = current
	if ki_value != null:
		ki_value.text = "%d/%d" % [int(floor(current)), int(maximum)]
	_refresh_overdrive_label()
	_refresh_special_skill_label()


func _on_overdrive_toggled(active: bool) -> void:
	_is_overdrive_active = active
	if overdrive_badge != null:
		overdrive_badge.visible = active
	if ki_bar != null:
		ki_bar.modulate = Color(1.0, 0.78, 0.25, 1.0) if active else Color(0.35, 0.88, 1.0, 1.0)
	_refresh_overdrive_label()
	_refresh_special_skill_label()
	_refresh_weapon_label()


func _on_fusion_toggled(active: bool) -> void:
	_is_fusion_active = active
	if ki_bar != null and active:
		ki_bar.modulate = Color(0.78, 0.42, 1.0, 1.0)
	elif ki_bar != null and not active:
		ki_bar.modulate = Color(0.35, 0.88, 1.0, 1.0)
	_refresh_overdrive_label()
	_refresh_special_skill_label()
	_refresh_weapon_label()


func _on_fusion_status_updated(active_remaining: float, cooldown_remaining: float) -> void:
	_refresh_fusion_label(active_remaining, cooldown_remaining)


func _on_player_state_changed(state_name: StringName) -> void:
	if state_label != null:
		state_label.text = "State: %s" % state_name


func _on_essence_changed(new_amount: int) -> void:
	if essence_label != null:
		essence_label.text = "Essence: %d" % new_amount


func _on_weapon_equipped(weapon_id: StringName) -> void:
	_current_weapon_name = String(weapon_id).replace("_", " ").capitalize()


func _on_weapon_durability_changed(_weapon_id: StringName, current: int, maximum: int) -> void:
	_weapon_cur_durability = current
	_weapon_max_durability = maximum
	_refresh_weapon_label()


func _refresh_weapon_label() -> void:
	if weapon_label == null:
		return
	if _is_overdrive_active or _is_fusion_active:
		weapon_label.text = "Weapon: BARE HANDS (Transform)"
		weapon_label.modulate = Color(1.0, 0.84, 0.35, 1.0)
	elif _weapon_cur_durability <= 0:
		weapon_label.text = "Weapon: BARE HANDS (Broken)"
		weapon_label.modulate = Color(1.0, 0.72, 0.3, 1.0)
	else:
		weapon_label.text = "Weapon: %s (%d/%d)" % [_current_weapon_name, _weapon_cur_durability, _weapon_max_durability]
		weapon_label.modulate = Color.WHITE


func _on_weapon_broken(_weapon_id: StringName) -> void:
	_weapon_cur_durability = 0
	_refresh_weapon_label()


func _on_skill_unlocked(_skill_id: StringName) -> void:
	_refresh_air_dash_label()


func _on_growth_stage_changed(_stage: StringName) -> void:
	_refresh_stage_label()
	_refresh_overdrive_label()


func _on_disciple_recruited() -> void:
	_refresh_fusion_label(0.0, 0.0)


func _refresh_stage_label() -> void:
	if stage_label == null:
		return
	var stage: StringName = GameManager.current_run_data.get("growth_stage", &"child")
	stage_label.text = "Form: %s" % String(stage).to_upper()


func _refresh_air_dash_label() -> void:
	if air_dash_label == null:
		return
	if GameManager.has_skill(&"air_dash"):
		air_dash_label.text = "Air-Dash: ON"
		air_dash_label.modulate = Color(0.45, 0.95, 1.0, 1.0)
	else:
		air_dash_label.text = "Air-Dash: OFF"
		air_dash_label.modulate = Color(0.6, 0.65, 0.75, 1.0)


func _refresh_overdrive_label() -> void:
	if overdrive_label == null:
		return
	var stage: StringName = GameManager.current_run_data.get("growth_stage", &"child")
	if stage != &"adult":
		overdrive_label.text = "Overdrive [L]: LOCKED (Adult)"
		overdrive_label.modulate = Color(0.6, 0.65, 0.75, 1.0)
	elif _is_overdrive_active:
		overdrive_label.text = "Overdrive [L]: ACTIVE"
		overdrive_label.modulate = Color(1.0, 0.82, 0.28, 1.0)
	elif _is_fusion_active:
		overdrive_label.text = "Overdrive [L]: LOCKED (Fused)"
		overdrive_label.modulate = Color(0.72, 0.58, 0.9, 1.0)
	elif _current_ki < 25.0:
		overdrive_label.text = "Overdrive [L]: NEED 25 KI"
		overdrive_label.modulate = Color(0.85, 0.75, 0.55, 1.0)
	else:
		overdrive_label.text = "Overdrive [L]: READY (25 Ki)"
		overdrive_label.modulate = Color(1.0, 0.88, 0.45, 1.0)


func _refresh_special_skill_label() -> void:
	if special_skill_label == null:
		return
	if not (_is_overdrive_active or _is_fusion_active):
		special_skill_label.text = "Beam [U]: LOCKED (Transform)"
		special_skill_label.modulate = Color(0.6, 0.65, 0.75, 1.0)
	elif _current_ki < 30.0:
		special_skill_label.text = "Beam [U]: NEED 30 KI"
		special_skill_label.modulate = Color(0.85, 0.75, 0.55, 1.0)
	else:
		special_skill_label.text = "Beam [U]: READY (30 Ki)"
		special_skill_label.modulate = Color(0.45, 0.96, 1.0, 1.0)


func _refresh_fusion_label(active_remaining: float, cooldown_remaining: float) -> void:
	if fusion_label == null:
		return
	if not bool(GameManager.current_run_data.get("has_disciple", false)):
		fusion_label.text = "Fusion [F]: LOCKED (Need Disciple)"
		fusion_label.modulate = Color(0.6, 0.65, 0.75, 1.0)
	elif active_remaining > 0.0:
		fusion_label.text = "Fusion [F]: ACTIVE %.1fs" % active_remaining
		fusion_label.modulate = Color(0.85, 0.55, 1.0, 1.0)
	elif cooldown_remaining > 0.0:
		fusion_label.text = "Fusion [F]: CD %.1fs" % cooldown_remaining
		fusion_label.modulate = Color(0.85, 0.75, 0.55, 1.0)
	else:
		fusion_label.text = "Fusion [F]: READY (40 Ki)"
		fusion_label.modulate = Color(0.55, 0.95, 0.78, 1.0)
