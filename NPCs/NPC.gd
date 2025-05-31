extends CharacterBody2D
class_name NPC

@export var dialog_resource: DialogData
@export var sprite_frames: SpriteFrames

func _ready():
	$AnimatedSprite2D.frames = sprite_frames
	$Area2D.add_to_group("dialogue_area")
	$Area2D.set_meta("dialog_valid", true)
