extends Node

var posicao_marcador: String = ""

func _ready():
	await get_tree().process_frame
	await get_tree().process_frame # Aguarda dois frames para garantir que tudo foi carregado
	_process_posicionamento()

func _process_posicionamento():
	if posicao_marcador == "":
		return

	var scene = get_tree().current_scene
	var marcador = scene.get_node_or_null(posicao_marcador)

	if not marcador:
		print("❌ Marcador não encontrado:", posicao_marcador)
		scene.print_tree_pretty()
		return

	var player = scene.get_node_or_null("Player")
	if not player:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player = players[0]

	if player:
		player.global_position = marcador.global_position
		print("✅ Player reposicionado em:", posicao_marcador, "->", marcador.global_position)
	else:
		print("❌ Player não encontrado na cena")

	posicao_marcador = ""
