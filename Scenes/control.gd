extends Control

@onready var vbox := $MarginContainer/MarginContainer/VBoxContainer

func _ready():
	ObjectiveManagement.connect("objectives_updated", Callable(self, "update_objectives"))
	update_objectives()

func update_objectives():
	# Remove os objetivos antigos
	for child in vbox.get_children():
		vbox.remove_child(child)
		child.queue_free()

	# Adiciona os objetivos atuais com animação
	for obj in ObjectiveManagement.get_objectives():
		create_animated_objective(obj)

func create_animated_objective(text: String):
	var label = Label.new()
	label.text = "• " + text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.modulate.a = 0.0  # Começa invisível
	label.position.x = -20  # Leve desvio para animação de slide

	vbox.add_child(label)

	# Animação de entrada
	var tween = create_tween()
	tween.tween_property(label, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(label, "position:x", 0.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
