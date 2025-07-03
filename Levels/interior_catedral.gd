extends Node2D

func _ready():
	ObjectiveManagement.clear_all_objectives()
	ObjectiveManagement.add_objective("Fale com a mulher na entrada")
	await get_tree().process_frame
	Global._process_posicionamento()
	$AudioStreamPlayer2D.play()
	$HUD/ReturnToMapButton.visible = false
