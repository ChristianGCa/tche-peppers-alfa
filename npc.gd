extends Area2D

@export var npc_name: String = "NPC"
@export var sprite_texture: Texture

@onready var sprite_node = $AnimatedSprite2D

func _ready():
	if sprite_texture:
		sprite_node.texture = sprite_texture
