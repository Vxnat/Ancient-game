class_name Phase1HUD
extends CanvasLayer
## Minimal Phase 1 HUD displaying HP, State, Weapon Durability, Essence, and controls.

@onready var hp_label: Label = $Panel/VBox/HpLabel
@onready var state_label: Label = $Panel/VBox/StateLabel
@onready var weapon_label: Label = $Panel/VBox/WeaponLabel
@onready var essence_label: Label = $Panel/VBox/EssenceLabel

var _current_weapon_name: String = "Bare Hands"


func _ready() -> void:
	EventBus.player_health_changed.connect(_on_health_changed)
	EventBus.essence_changed.connect(_on_essence_changed)
	EventBus.weapon_equipped.connect(_on_weapon_equipped)
	EventBus.weapon_durability_changed.connect(_on_weapon_durability_changed)
	EventBus.weapon_broken.connect(_on_weapon_broken)

	_on_essence_changed(int(GameManager.current_run_data["essence"]))
	_on_health_changed(float(GameManager.current_run_data["current_hp"]), float(GameManager.current_run_data["max_hp"]))

	await get_tree().process_frame
	for node in get_tree().get_nodes_in_group(&"player"):
		if node is Player:
			var player := node as Player
			player.state_changed.connect(_on_player_state_changed)
			if player.weapon_component.equipped_weapon != null and player.weapon_component.equipped_weapon.data != null:
				var w := player.weapon_component.equipped_weapon
				_current_weapon_name = w.data.display_name
				_on_weapon_durability_changed(w.data.id, w.current_durability, w.data.max_durability)


func _on_health_changed(current: float, maximum: float) -> void:
	if hp_label != null:
		hp_label.text = "HP: %d / %d" % [int(ceil(current)), int(maximum)]


func _on_player_state_changed(state_name: StringName) -> void:
	if state_label != null:
		state_label.text = "State: %s" % state_name


func _on_essence_changed(new_amount: int) -> void:
	if essence_label != null:
		essence_label.text = "Essence: %d" % new_amount


func _on_weapon_equipped(weapon_id: StringName) -> void:
	_current_weapon_name = String(weapon_id).capitalize()


func _on_weapon_durability_changed(_weapon_id: StringName, current: int, maximum: int) -> void:
	if weapon_label == null:
		return
	if current <= 0:
		weapon_label.text = "Weapon: BARE HANDS (Broken)"
		weapon_label.modulate = Color(1.0, 0.72, 0.3, 1.0)
	else:
		weapon_label.text = "Weapon: %s (%d/%d)" % [_current_weapon_name, current, maximum]
		weapon_label.modulate = Color.WHITE


func _on_weapon_broken(_weapon_id: StringName) -> void:
	if weapon_label != null:
		weapon_label.text = "Weapon: BARE HANDS (Broken)"
		weapon_label.modulate = Color(1.0, 0.72, 0.3, 1.0)
