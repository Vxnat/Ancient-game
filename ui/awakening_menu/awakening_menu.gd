class_name AwakeningMenu
extends CanvasLayer
## Checkpoint menu for unlocking Awakening skills, repairing/upgrading weapons, and saving/loading.

const SKILL_PATHS: Array[String] = [
	"res://data/skills/vitality_surge.tres",
	"res://data/skills/ki_reservoir.tres",
	"res://data/skills/martial_focus.tres",
	"res://data/skills/swift_step.tres",
]

@onready var root_control: Control = $Root
@onready var essence_label: Label = $Root/Center/Panel/Margin/VBox/Header/EssenceLabel
@onready var status_label: Label = $Root/Center/Panel/Margin/VBox/StatusLabel
@onready var skills_list: VBoxContainer = $Root/Center/Panel/Margin/VBox/Body/SkillsColumn/SkillsList
@onready var weapon_info_label: Label = $Root/Center/Panel/Margin/VBox/Body/WeaponColumn/WeaponInfoLabel
@onready var repair_button: Button = $Root/Center/Panel/Margin/VBox/Body/WeaponColumn/RepairButton
@onready var upgrade_button: Button = $Root/Center/Panel/Margin/VBox/Body/WeaponColumn/UpgradeButton
@onready var save_button: Button = $Root/Center/Panel/Margin/VBox/Body/WeaponColumn/SaveLoadRow/SaveButton
@onready var load_button: Button = $Root/Center/Panel/Margin/VBox/Body/WeaponColumn/SaveLoadRow/LoadButton
@onready var close_button: Button = $Root/Center/Panel/Margin/VBox/CloseButton

var _player: Player = null
var _skills: Array[SkillData] = []
var _skill_buttons: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group(&"awakening_menu")
	visible = false

	for path in SKILL_PATHS:
		var skill := load(path) as SkillData
		if skill != null:
			_skills.append(skill)

	_build_skill_buttons()
	repair_button.pressed.connect(_on_repair_pressed)
	upgrade_button.pressed.connect(_on_upgrade_pressed)
	save_button.pressed.connect(_on_save_pressed)
	load_button.pressed.connect(_on_load_pressed)
	close_button.pressed.connect(close_menu)


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("pause") or event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close_menu()


func open_for_player(player: Player, initial_status: String = "") -> void:
	_player = player
	visible = true
	GameManager.set_paused(true)
	refresh_ui()
	status_label.text = initial_status
	if _skills.size() > 0 and _skill_buttons.has(_skills[0].id):
		(_skill_buttons[_skills[0].id] as Button).grab_focus()
	else:
		close_button.grab_focus()


func close_menu() -> void:
	visible = false
	GameManager.set_paused(false)


func refresh_ui() -> void:
	var essence: int = int(GameManager.current_run_data["essence"])
	essence_label.text = "Essence: %d" % essence

	for skill in _skills:
		var btn: Button = _skill_buttons.get(skill.id, null)
		if btn == null:
			continue
		if GameManager.has_skill(skill.id):
			btn.text = "%s [UNLOCKED]" % skill.display_name
			btn.disabled = true
		else:
			btn.text = "%s (%d) - %s" % [skill.display_name, skill.essence_cost, skill.description]
			btn.disabled = essence < skill.essence_cost

	if _player != null and _player.weapon_component.equipped_weapon != null:
		var w := _player.weapon_component.equipped_weapon
		var repair_cost: int = w.get_repair_cost()
		var upgrade_cost: int = w.get_upgrade_cost()
		weapon_info_label.text = "%s Lv.%d/%d\nDMG: +%d | DUR: %d/%d" % [
			w.data.display_name,
			w.upgrade_level,
			w.data.max_upgrade_level,
			int(w.get_effective_damage()),
			w.current_durability,
			w.data.max_durability,
		]
		repair_button.text = "Repair (Full)" if repair_cost <= 0 else "Repair (%d)" % repair_cost
		repair_button.disabled = repair_cost <= 0 or essence < repair_cost
		upgrade_button.text = "Upgrade (MAX)" if upgrade_cost < 0 else "Upgrade (%d)" % upgrade_cost
		upgrade_button.disabled = upgrade_cost < 0 or essence < upgrade_cost
	else:
		weapon_info_label.text = "No weapon equipped"
		repair_button.disabled = true
		upgrade_button.disabled = true

	load_button.disabled = not SaveManager.has_save()


func _build_skill_buttons() -> void:
	for child in skills_list.get_children():
		child.queue_free()
	_skill_buttons.clear()

	for skill in _skills:
		var btn := Button.new()
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.add_theme_font_size_override("font_size", 9)
		btn.focus_mode = Control.FOCUS_ALL
		btn.pressed.connect(_on_skill_pressed.bind(skill))
		skills_list.add_child(btn)
		_skill_buttons[skill.id] = btn


func _on_skill_pressed(skill: SkillData) -> void:
	if GameManager.has_skill(skill.id):
		return
	if not GameManager.spend_essence(skill.essence_cost):
		status_label.text = "Not enough Essence!"
		return
	GameManager.unlock_skill(skill.id)
	status_label.text = "Awakened: %s!" % skill.display_name
	refresh_ui()


func _on_repair_pressed() -> void:
	if _player == null:
		return
	if _player.weapon_component.try_repair_equipped():
		_player.sync_weapon_to_run_data()
		status_label.text = "Weapon repaired!"
	else:
		status_label.text = "Cannot repair weapon."
	refresh_ui()


func _on_upgrade_pressed() -> void:
	if _player == null:
		return
	if _player.weapon_component.try_upgrade_equipped():
		_player.sync_weapon_to_run_data()
		status_label.text = "Weapon upgraded!"
	else:
		status_label.text = "Cannot upgrade weapon."
	refresh_ui()


func _on_save_pressed() -> void:
	var scene_path: String = ""
	if get_tree().current_scene != null:
		scene_path = get_tree().current_scene.scene_file_path
	if SaveManager.save_game(scene_path):
		status_label.text = "Progress saved!"
	else:
		status_label.text = "Save failed."
	refresh_ui()


func _on_load_pressed() -> void:
	var loaded := SaveManager.load_game()
	if loaded.is_empty():
		status_label.text = "No save file found."
		return
	if _player != null:
		_player.restore_from_run_data()
	status_label.text = "Save loaded!"
	refresh_ui()
