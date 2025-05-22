extends Area2D

@export var nome_ponto_entrada: String = "porta_entrada_planetario" # Nome do marcador no destino
@export var tecla_acao: String = "ui_accept"
@export var cena_destino_path: String = ""
var cena_destino: PackedScene

func _ready():
	$AnimatedSprite2D.play("out_closed")
	if cena_destino_path != "":
		cena_destino = load(cena_destino_path)

var jogador_na_area = false

func _on_body_entered(body):
	print("ta na frente da porta")
	if body.is_in_group("player"):
		$AnimatedSprite2D.play("out_opened")
		jogador_na_area = true

func _on_body_exited(body):
	print("saiu da porta")
	if body.is_in_group("player"):
		$AnimatedSprite2D.play("out_closed")
		jogador_na_area = false

func _process(delta):
	if jogador_na_area and Input.is_action_just_pressed(tecla_acao):
		if cena_destino:
			Global.ponto_entrada = nome_ponto_entrada
			get_tree().change_scene_to_packed(cena_destino)
