extends Control

@export var display_time := 2.0  # segundos que a notificação fica visível
@onready var label := $MarginContainer/Label
@onready var anim := $AnimationPlayer

func show_message(text: String):
	label.text = text
	visible = true
	await get_tree().create_timer(display_time).timeout
	visible = false
