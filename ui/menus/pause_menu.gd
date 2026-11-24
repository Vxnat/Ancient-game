class_name PauseMenu
extends CanvasLayer
## Pause menu opened with Esc when no other modal menu is active.

@onready var resume_button: Button = $Root/Center/Panel/Margin/VBox/ResumeButton
@onready var save_button: Button = $Root/Center/Panel/Margin/VBox/SaveButton
@onready var main_menu_button: Button = $Root/Center/Panel/Margin/VBox/MainMenuButton
@onready var status_label: Label = $Root/Center/Panel/Margin/VBox/StatusLabel


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	resume_button.pressed.connect(close_menu)
	save_button.pressed.connect(_on_save_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if visible:
			get_viewport().set_input_as_handled()
			close_menu()
		elif not GameManager.is_paused:
			get_viewport().set_input_as_handled()
			open_menu()


func open_menu() -> void:
	visible = true
	status_label.text = ""
	GameManager.set_paused(true)
	resume_button.grab_focus()


func close_menu() -> void:
	visible = false
	GameManager.set_paused(false)


func _on_save_pressed() -> void:
	var scene_path: String = ""
	if get_tree().current_scene != null:
		scene_path = get_tree().current_scene.scene_file_path
	status_label.text = "Saved!" if SaveManager.save_game(scene_path) else "Save failed."


func _on_main_menu_pressed() -> void:
	close_menu()
	SceneManager.change_scene("res://ui/menus/main_menu.tscn", &"DefaultSpawn")
