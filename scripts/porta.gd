extends Area2D

@export var cena_destino: PackedScene
@export var nome_ponto_entrada: String = "" # Nome do marcador no destino
@export var tecla_acao: String = "ui_accept"

var jogador_na_area = false

func _ready():
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("player"):
		jogador_na_area = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		jogador_na_area = false

func _process(delta):
	if jogador_na_area and Input.is_action_just_pressed(tecla_acao):
		if cena_destino:
			Global.ponto_entrada = nome_ponto_entrada
			get_tree().change_scene_to_packed(cena_destino)
