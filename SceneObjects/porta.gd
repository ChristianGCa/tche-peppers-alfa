extends Area2D

@export var tecla_acao: String = "ok"
@export var cena_destino_path: String = "" # Caminho da cena: ex. res://scenes/exterior.tscn
@export var nome_ponto_entrada: String = "" # Nome do marcador de entrada
@export var interior: bool = false  # TRUE se esta porta está dentro de um prédio
@export var animacoes: SpriteFrames
@export var flag_requerida: String = "" # ← Nome da flag que o jogador precisa ter (opcional)

@onready var notificationPanel = $"../HUD/NotificationPanel"
@onready var interaction_icon = $Interaction
var jogador_na_area = false
var cena_destino: PackedScene

func _ready():
	print("Porta carregando...")

	if animacoes:
		$AnimatedSprite2D.frames = animacoes
	else:
		print("ERRO: Nenhum recurso de animações (.tres) definido!")

	# Define animação inicial
	if interior:
		print("Porta inicializada como INTERIOR (stair)")
		$AnimatedSprite2D.play("stair")
	else:
		print("Porta inicializada como EXTERIOR (out_closed)")
		$AnimatedSprite2D.play("out_closed")
		# Começa com interação visível
		if interaction_icon:
			interaction_icon.visible = true
			interaction_icon.play("interaction")

	# Carrega a cena de destino
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
		jogador_na_area = true

		if flag_requerida != "" and not GameState.get_flag(flag_requerida):
			return

		if interior:
			# Porta de saída de prédio → mostra "exit"
			if interaction_icon:
				interaction_icon.visible = true
				interaction_icon.play("exit")
		else:
			# Porta de entrada (exterior) → anima porta abrindo e mostra "enter"
			$open.play()
			$AnimatedSprite2D.play("out_opened")
			if interaction_icon:
				interaction_icon.visible = true
				interaction_icon.play("enter")

func _on_body_exited(body):
	if body.is_in_group("player"):
		print("Jogador saiu da área da porta")
		jogador_na_area = false

		if flag_requerida != "" and not GameState.get_flag(flag_requerida):
			return

		if interior:
			# Oculta o ícone quando sai de dentro do prédio
			if interaction_icon:
				interaction_icon.visible = false
		else:
			# Porta de entrada → toca som de fechar e volta para 'interaction'
			$close.play()
			$AnimatedSprite2D.play("out_closed")
			if interaction_icon:
				interaction_icon.visible = true
				interaction_icon.play("interaction")


func _process(_delta):
	if jogador_na_area and Input.is_action_just_pressed(tecla_acao):
		print("Tecla pressionada. Tentando mudar de cena...")

		# Verifica a flag (se necessário)
		if flag_requerida != "" and not GameState.get_flag(flag_requerida):
			print("Flag necessária não encontrada:", flag_requerida)
			notificationPanel.show_message("Parece trancado... fale com alguém primeiro!")
			return

		if cena_destino:
			print("Cena destino válida:", cena_destino.resource_path)
			print("Nome do marcador de entrada:", nome_ponto_entrada)
			Global.posicao_marcador = nome_ponto_entrada
			get_tree().change_scene_to_packed(cena_destino)
		else:
			print("ERRO: cena_destino está nula")
