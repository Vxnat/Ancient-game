class_name MainMenu
extends Control
## Title screen offering New Game, Continue Save, and Quit.

@onready var new_game_button: Button = $Center/Panel/Margin/VBox/NewGameButton
@onready var continue_button: Button = $Center/Panel/Margin/VBox/ContinueButton
@onready var quit_button: Button = $Center/Panel/Margin/VBox/QuitButton


func _ready() -> void:
	new_game_button.pressed.connect(_on_new_game_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	continue_button.disabled = not SaveManager.has_save()
	new_game_button.grab_focus()


func _on_new_game_pressed() -> void:
	GameManager.reset_run_data()
	QuestManager.reset_quests()
	SceneManager.change_scene("res://world/peaceful_planet/peaceful_village.tscn", &"DefaultSpawn")


func _on_continue_pressed() -> void:
	var data := SaveManager.load_game()
	var target_scene: String = str(data.get("scene_path", "res://world/peaceful_planet/peaceful_village.tscn"))
	if target_scene.is_empty():
		target_scene = "res://world/peaceful_planet/peaceful_village.tscn"
	SceneManager.change_scene(target_scene, &"DefaultSpawn")


func _on_quit_pressed() -> void:
	get_tree().quit()
