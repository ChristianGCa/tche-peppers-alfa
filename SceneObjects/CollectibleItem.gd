extends Area2D

@export var item_name: String
@export var related_quest: QuestData

var has_been_activated := false

func _ready():
	visible = false
	if related_quest:
		related_quest.quest_state_changed.connect(_on_quest_state_changed)
		if related_quest.state == QuestData.QuestState.IN_PROGRESS:
			visible = true

func _on_quest_state_changed(new_state):
	if new_state == QuestData.QuestState.IN_PROGRESS:
		visible = true

func _process(delta):
	if not has_been_activated and related_quest and related_quest.state == QuestData.QuestState.IN_PROGRESS:
		print("Item ativado! Quest em progresso.")
		visible = true
		has_been_activated = true

func _on_body_entered(body):
	if body.name == "Player":
		if item_name != "":
			body.inventory.append(item_name)
			queue_free()
