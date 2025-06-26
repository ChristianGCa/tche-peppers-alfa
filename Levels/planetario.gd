extends Node2D

func _ready():
	ObjectiveManagement.add_objective("Fale com o cidadão local")
	if Global.posicao_marcador != "":
		var marcador = get_node_or_null(Global.posicao_marcador)
		if marcador:
			var player = get_tree().get_first_node_in_group("player")
			if player:
				player.global_position = marcador.global_position
	

func on_level_complete():
	var file = FileAccess.open("user://progress.save", FileAccess.READ_WRITE)
	var progress = {}
	if file.get_length() > 0:
		progress = file.get_var()
	progress["catedral"] = true
	file.seek(0)
	file.store_var(progress)
	file.flush()
	get_tree().change_scene_to_file("res://caminho_para_o_Map.tscn")
