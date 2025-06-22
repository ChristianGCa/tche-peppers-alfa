extends Control

@onready var vbox := $MarginContainer/MarginContainer/VBoxContainer

func _ready():
	ObjectiveManagement.connect("objectives_updated", Callable(self, "update_objectives"))
	ObjectiveManagement.connect("objective_completed", Callable(self, "animate_removal"))
	update_objectives()


func _on_objectives_updated(completed_text = ""):
	for child in vbox.get_children():
		if child.text.contains(completed_text):
			var tween = create_tween()
			tween.tween_property(child, "modulate", Color(0, 1, 0), 0.3)
			tween.tween_property(child, "modulate:a", 0.0, 0.4).set_delay(0.2)
			await tween.finished
			child.queue_free()
	update_objectives()


func update_objectives():
	for child in vbox.get_children():
		child.queue_free()

	for obj in ObjectiveManagement.get_objectives():
		create_animated_objective(obj)


func animate_removal(text: String):
	for label in vbox.get_children():
		if label.text.contains(text):
			var tween = create_tween()
			tween.tween_property(label, "modulate", Color(0, 1, 0), 0.3)
			tween.tween_property(label, "modulate:a", 0.0, 0.4).set_delay(0.3)
			await tween.finished
			if is_instance_valid(label):
				label.queue_free()
			break  # Evita repetir



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
