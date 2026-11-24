class_name QuestTracker
extends CanvasLayer
## Compact top-right HUD widget displaying active quests and completion notices.

@onready var quests_label: Label = $TopRight/Margin/VBox/QuestsLabel


func _ready() -> void:
	EventBus.quest_started.connect(_on_quest_changed)
	EventBus.quest_updated.connect(_on_quest_changed)
	EventBus.quest_completed.connect(_on_quest_changed)
	refresh()


func refresh() -> void:
	if quests_label == null:
		return
	if QuestManager.active_quests.is_empty():
		quests_label.text = "No active quest.\nTalk to NPCs [E]."
		return

	var lines: PackedStringArray = []
	for quest_id in QuestManager.active_quests.keys():
		var entry: Dictionary = QuestManager.active_quests[quest_id]
		var data: QuestData = entry["data"]
		var progress: int = int(entry["progress"])
		if bool(entry["completed"]):
			lines.append("[DONE] %s\n-> Return to NPC" % data.title)
		else:
			lines.append("- %s (%d/%d)" % [data.title, progress, data.required_amount])
	quests_label.text = "\n".join(lines)


func _on_quest_changed(_quest_id: StringName) -> void:
	refresh()
