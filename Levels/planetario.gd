extends Node2D

@onready var return_button: Button = $HUD/ReturnToMapButton
@export var this_level_id: String = "planetario" # Mantenha se ainda usar em _level_was_completed
@onready var music = $AudioStreamPlayer2D

func _ready():
	music.play()
	ObjectiveManagement.add_objective("Fale com o cidadão local")

	return_button.visible = false

	if Global.posicao_marcador != "":
		var marcador = get_node_or_null(Global.posicao_marcador)
		if marcador:
			var player = get_tree().get_first_node_in_group("player")
			if player:
				player.global_position = marcador.global_position

	if _level_was_completed():
		_show_return_button()

func _level_was_completed() -> bool:
	if FileAccess.file_exists("user://progress.save"):
		var file = FileAccess.open("user://progress.save", FileAccess.READ)
		if file.get_length() > 0:
			var progress = file.get_var()
			# A fase "planetario" é considerada completa se "catedral" estiver desbloqueada.
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
