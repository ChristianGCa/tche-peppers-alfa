extends Node2D

func _ready():
	ObjectiveManagement.add_objective("Fale com o professor")
	await get_tree().process_frame
	Global._process_posicionamento()
	$AudioStreamPlayer2D.play()
