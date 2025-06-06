extends CharacterBody2D
class_name NPC

@export var dialog_intro: DialogData
@export var dialog_in_progress: DialogData
@export var dialog_completed: DialogData
@export var quest: QuestData = null
@export var sprite_frames: SpriteFrames

func _ready():
	$AnimatedSprite2D.frames = sprite_frames
	$Area2D.add_to_group("dialogue_area")
	$Area2D.set_meta("dialog_valid", true)
	$Area2D.set_meta("quest_npc", self)
	$DialogBaloon.visible = false

func get_current_dialog() -> DialogData:
	if quest == null:
		return dialog_intro

	match quest.state:
		QuestData.QuestState.NOT_STARTED:
			return dialog_intro
		QuestData.QuestState.IN_PROGRESS:
			return dialog_in_progress
		QuestData.QuestState.COMPLETED:
			return dialog_completed

	return dialog_intro
