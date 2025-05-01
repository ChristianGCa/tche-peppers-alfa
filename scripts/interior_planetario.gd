extends Node2D

func _ready():
	if Global.ponto_entrada != "":
		var marcador = get_node_or_null(Global.ponto_entrada)
		if marcador:
			var player = get_tree().get_first_node_in_group("player")
			if player:
				player.global_position = marcador.global_position
