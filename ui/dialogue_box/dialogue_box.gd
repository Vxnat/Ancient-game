class_name DialogueBox
extends CanvasLayer
## Modal dialogue box displaying speaker lines and pausing gameplay until dismissed.

signal dialogue_started()
signal dialogue_finished()

@onready var speaker_label: Label = $Root/Margin/Panel/InnerMargin/VBox/SpeakerLabel
@onready var line_label: Label = $Root/Margin/Panel/InnerMargin/VBox/LineLabel
@onready var prompt_label: Label = $Root/Margin/Panel/InnerMargin/VBox/PromptLabel

var _lines: Array[String] = []
var _current_index: int = 0
var _was_paused_before: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group(&"dialogue_box")
	visible = false
	EventBus.dialogue_requested.connect(_on_dialogue_requested)


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		advance()
	elif event.is_action_pressed("pause") or event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close()


func show_dialogue(speaker: String, lines: Array[String]) -> void:
	if lines.is_empty():
		return
	_lines = lines.duplicate()
	_current_index = 0
	_was_paused_before = GameManager.is_paused
	speaker_label.text = speaker
	_update_line()
	visible = true
	GameManager.set_paused(true)
	dialogue_started.emit()


func advance() -> void:
	_current_index += 1
	if _current_index >= _lines.size():
		close()
		return
	_update_line()


func close() -> void:
	if not visible:
		return
	visible = false
	GameManager.set_paused(_was_paused_before)
	dialogue_finished.emit()


func _update_line() -> void:
	line_label.text = _lines[_current_index]
	var is_last: bool = _current_index >= _lines.size() - 1
	prompt_label.text = "[E / Space] Close" if is_last else "[E / Space] Next (%d/%d)" % [_current_index + 1, _lines.size()]


func _on_dialogue_requested(dialogue_data: Resource) -> void:
	if dialogue_data is DialogueData:
		var data := dialogue_data as DialogueData
		show_dialogue(data.speaker_name, data.lines)
