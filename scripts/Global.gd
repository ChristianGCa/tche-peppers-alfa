extends Node

var posicao_marcador: String = ""

func _on_scene_changed(new_scene):
	await get_tree().process_frame # Garante que tudo foi carregado
	if posicao_marcador != "":
		var marcador = new_scene.get_node_or_null(posicao_marcador)
		if marcador:
			var player = new_scene.get_node_or_null("Player")  # Ou use grupo
			if player:
				player.global_position = marcador.global_position
		posicao_marcador = ""
