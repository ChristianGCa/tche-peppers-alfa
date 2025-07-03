extends Node2D

@onready var return_button: Button = $HUD/ReturnToMapButton
@export var this_level_id: String = "planetario"
@onready var music = $AudioStreamPlayer2D
@onready var decoracoes_node = $decoracoes  # ajusta conforme o nome exato na sua cena

func _ready():
	music.play()
	return_button.visible = false

	# Reposiciona o player, se necessário
	if Global.posicao_marcador != "":
		var marcador = get_node_or_null(Global.posicao_marcador)
		if marcador:
			var player = get_tree().get_first_node_in_group("player")
			if player:
				player.global_position = marcador.global_position

	# Exibe o botão se a fase foi completada
	if _level_was_completed():
		_show_return_button()

	# Espera um pouco e verifica se o NPC está presente
	await get_tree().create_timer(0.1).timeout
	_check_for_npc()

func _check_for_npc():
	if decoracoes_node.has_node("CidadaoLocal"):
		ObjectiveManagement.add_objective("Fale com o cidadão local")
		print("🎯 Objetivo ativado: Fale com o cidadão local")
	else:
		ObjectiveManagement.add_objective("Busque mais pessoas para conversar")
		print("👻 NPC 'CidadaoLocal' não encontrado em Decorações")

func _level_was_completed() -> bool:
	if FileAccess.file_exists("user://progress.save"):
		var file = FileAccess.open("user://progress.save", FileAccess.READ)
		if file.get_length() > 0:
			var progress = file.get_var()
			return progress.get("catedral", false)
	return false

func _show_return_button():
	if return_button.visible:
		return
	return_button.visible = true
	return_button.position.y = -50
	var tween := create_tween()
	tween.tween_property(return_button, "position:y", 20, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	print("⬆️ Botão 'Voltar ao Mapa' visível (pela carga da cena ou outra lógica).")

func on_level_complete():
	_show_return_button()
