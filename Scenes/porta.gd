extends Area2D

@export var tecla_acao: String = "ok"
@export var cena_destino_path: String = "" # Caminho da cena: ex. res://scenes/exterior.tscn
@export var nome_ponto_entrada: String = "" # Nome do marcador de entrada
@export var interior: bool = false  # TRUE se esta porta está dentro de um prédio

var jogador_na_area = false
var cena_destino: PackedScene

func _ready():
	print("Porta carregando...")

	# Define animação inicial
	if interior:
		print("Porta inicializada como INTERIOR (stair)")
		$AnimatedSprite2D.play("stair")
	else:
		print("Porta inicializada como EXTERIOR (out_closed)")
		$AnimatedSprite2D.play("out_closed")

	# Carrega a cena de destino a partir do caminho (String)
	if cena_destino_path != "":
		cena_destino = load(cena_destino_path)
		if cena_destino:
			print("Cena carregada com sucesso:", cena_destino_path)
		else:
			print("ERRO: Falha ao carregar a cena:", cena_destino_path)
	else:
		print("AVISO: cena_destino_path está vazia")

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("Jogador entrou na área da porta")
		if not interior:
			$AnimatedSprite2D.play("out_opened")
		jogador_na_area = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		print("Jogador saiu da área da porta")
		if not interior:
			$AnimatedSprite2D.play("out_closed")
		jogador_na_area = false

func _process(_delta):
	if jogador_na_area and Input.is_action_just_pressed(tecla_acao):
		print("Tecla pressionada. Tentando mudar de cena...")
		if cena_destino:
			print("Cena destino válida:", cena_destino.resource_path)
			print("Nome do marcador de entrada:", nome_ponto_entrada)
			Global.posicao_marcador = nome_ponto_entrada
			get_tree().change_scene_to_packed(cena_destino)
		else:
			print("ERRO: cena_destino está nula")
