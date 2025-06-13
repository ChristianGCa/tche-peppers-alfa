extends Control

@onready var vbox := $CenterContainer/MarginContainer/VBoxContainer

var current_objectives: Array[String] = []

func _ready():
	update_objectives()

func set_objectives(new_objectives: Array[String]):
	current_objectives = new_objectives
	update_objectives()


func add_objective(objective: String):
	current_objectives.append(objective)
	update_objectives()

func complete_objective(objective: String):
	if objective in current_objectives:
		current_objectives.erase(objective)	
		update_objectives()

func update_objectives():
	for child in vbox.get_children():
		vbox.remove_child(child)
		child.queue_free()

	for obj in current_objectives:
		var label = Label.new()
		label.text = "• " + obj
		label.add_theme_color_override("font_color", Color.WHITE)
		vbox.add_child(label)
