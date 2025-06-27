extends Button

func _ready():
	# Estilização básica (opcional)
	add_theme_color_override("font_color", Color.WHITE)
	add_theme_color_override("font_color_hover", Color.YELLOW)

	# Animação de entrada
	position.y = -50
	var tween := create_tween()
	tween.tween_property(self, "position:y", 20, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# Conecta o clique
	pressed.connect(_on_pressed)

func _on_pressed():
	get_tree().change_scene_to_file("res://UI/Map/map.tscn")
