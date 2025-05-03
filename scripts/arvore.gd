extends Node2D

@export var transparent_opacity := 0.4  # Pode ajustar a opacidade no editor

@onready var sprite = $sprite  # Ajusta o nome aqui se teu sprite tiver outro nome

func _on_area_2d_body_entered(body):
	if body.name == "player":
		sprite.modulate.a = transparent_opacity

func _on_area_2d_body_exited(body):
	if body.name == "player":
		sprite.modulate.a = 1.0
