extends Node2D


@export var transparent_opacity := 0.4  # Pode ajustar a opacidade no editor

@onready var sprite = $Sprite2D  # Ajusta o nome aqui se teu sprite tiver outro nome

func _on_area_2d_body_exited(body):
	if body.name == "Player":
		sprite.modulate.a = 1.0


func _on_area_2d_2_body_entered(body):
	print("entrou")
	print(body.name)
	if body.name == "Player":
		sprite.modulate.a = transparent_opacity


func _on_area_2d_2_body_exited(body):
	if body.name == "Player":
		sprite.modulate.a = 1.0
