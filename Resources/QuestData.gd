# QuestData.gd
extends Resource
class_name QuestData

enum QuestState { NOT_STARTED, IN_PROGRESS, COMPLETED }

@export var item_required: String = ""
@export var objective_text: String = ""
@export var state: QuestState = QuestState.NOT_STARTED

func is_completed() -> bool:
	return state == QuestState.COMPLETED

func try_progress(inventory: Array[String]) -> bool:
	if state == QuestState.NOT_STARTED:
		state = QuestState.IN_PROGRESS
	elif state == QuestState.IN_PROGRESS and inventory.has(item_required):
		state = QuestState.COMPLETED
		inventory.erase(item_required)
		return true
	return false

signal quest_state_changed(new_state)

func set_state(new_state: QuestState):
	if state != new_state:
		state = new_state
		emit_signal("quest_state_changed", state)
