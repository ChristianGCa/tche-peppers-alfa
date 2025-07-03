# base_aerea.gd
extends Node2D

@onready var return_button: Button = $HUD/ReturnToMapButton
@export var this_level_id: String = "base_aerea"
@onready var music = $AudioStreamPlayer2D

func _ready():
	music.play()
	ObjectiveManagement.clear_all_objectives()
	ObjectiveManagement.add_objective("Converse com o soldado no portão")

	return_button.visible = false

	if Global.posicao_marcador != "":
		var marcador = get_node_or_null(Global.posicao_marcador)
		if marcador:
			var player = get_tree().get_first_node_in_group("player")
			if player:
				player.global_position = marcador.global_position

func _level_was_completed() -> bool:
	if FileAccess.file_exists("user://progress.save"):
		var file = FileAccess.open("user://progress.save", FileAccess.READ)
		if file.get_length() > 0:
			var progress = file.get_var()
			return progress.get("base_aerea", false)
	return false

func _show_return_button():
	if return_button.visible:
		return
	return_button.visible = true
	return_button.position.y = -50
	var tween := create_tween()
	tween.tween_property(return_button, "position:y", 20, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	print("⬆️ Botão 'Voltar ao Mapa' visível.")

func on_level_complete():
	_show_return_button()
