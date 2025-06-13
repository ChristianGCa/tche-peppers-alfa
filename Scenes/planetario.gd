extends Node2D

var objectives: Array[String] = [
	"Explore o lugar"
]

func _ready():
	$HUD/Objetivos.set_objectives(objectives)
	if Global.posicao_marcador != "":
		var marcador = get_node_or_null(Global.posicao_marcador)
		if marcador:
			var player = get_tree().get_first_node_in_group("player")
			if player:
				player.global_position = marcador.global_position
	
