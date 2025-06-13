extends Resource
class_name QuestData

enum QuestState { NOT_STARTED, IN_PROGRESS, COMPLETED }

@export var quest_name: String = ""
@export var item_required: String = "" # Ex: "luneta"
@export var objective_text: String = "" # ← Adicionado para exibir no HUD

var state: QuestState = QuestState.NOT_STARTED

func is_completed() -> bool:
	# Verifica se o item foi adquirido (ajuste conforme seu GameState ou inventário)
	return GameState.has_item(item_required)
