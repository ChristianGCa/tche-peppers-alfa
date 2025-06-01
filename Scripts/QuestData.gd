extends Resource
class_name QuestData

enum QuestState { NOT_STARTED, IN_PROGRESS, COMPLETED }

@export var quest_name: String
@export var item_required: String
var state: QuestState = QuestState.NOT_STARTED
