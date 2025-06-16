extends Node
class_name ObjectiveManager

signal objectives_updated

var current_objectives: Array[String] = []

func add_objective(text: String):
	if text not in current_objectives:
		current_objectives.append(text)
		emit_signal("objectives_updated")

func complete_objective(text: String):
	if text in current_objectives:
		current_objectives.erase(text)
		emit_signal("objectives_updated")

func get_objectives() -> Array[String]:
	return current_objectives
