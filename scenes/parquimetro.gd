extends Node2D
@export var transparent_opacity := 0.4 

@onready var sprite = $Sprite2D  # Ajusta o nome aqui se teu sprite tiver outro nome
func _process(delta):
	if Input.is_action_just_pressed("ok"):
		print("legal")
		
func _on_area_2d_body_entered(body):
	print("entrou")
	print(body.name)
	if body.name == "Player":
		sprite.modulate.a = transparent_opacity

func _on_area_2d_body_exited(body):
	if body.name == "Player":
		sprite.modulate.a = 1.0
		
