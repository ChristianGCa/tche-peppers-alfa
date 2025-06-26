extends Area2D

@export var tecla_acao: String = "ok"
@export var cena_destino_path: String = ""
@export var nome_ponto_entrada: String = ""
@export var interior: bool = false
@export var animacoes: SpriteFrames
@export var flags_requeridas: Array[String] = []

@onready var notificationPanel = $"../HUD/NotificationPanel"
@onready var interaction_icon = $Interaction

var jogador_na_area = false
var cena_destino: PackedScene
var porta_aberta = false

func _ready():
	print("🔧 Porta carregando...")
	if animacoes:
		$AnimatedSprite2D.frames = animacoes
	else:
		print("❌ ERRO: Sem animações definidas!")

	if interior:
		$AnimatedSprite2D.play("stair")
	else:
		$AnimatedSprite2D.play("out_closed")
		if interaction_icon:
			interaction_icon.visible = true
			interaction_icon.play("interaction")

	if cena_destino_path != "":
		cena_destino = load(cena_destino_path)
		if cena_destino:
			print("✅ Cena carregada:", cena_destino_path)
		else:
			print("❌ ERRO ao carregar cena:", cena_destino_path)

func tem_todas_flags() -> bool:
	for flag in flags_requeridas:
		if not GameState.get_flag(flag):
			print("🚫 Flag faltando:", flag)
			return false
	return true

func _on_body_entered(body):
	if not body.is_in_group("player"):
		return

	print("🚪 Jogador entrou")
	jogador_na_area = true

	if not tem_todas_flags():
		print("❌ Bloqueado: faltam flags necessárias.")
		if interaction_icon:
			interaction_icon.visible = false
		return

	if interior:
		if interaction_icon:
			interaction_icon.visible = true
			interaction_icon.play("exit")
	else:
		if not porta_aberta:
			print("🔓 Abrindo porta")
			$open.play()
			$AnimatedSprite2D.play("out_opened")
			porta_aberta = true

		if interaction_icon:
			interaction_icon.visible = true
			interaction_icon.play("enter")

func _on_body_exited(body):
	if not body.is_in_group("player"):
		return

	print("🚪 Jogador saiu")
	jogador_na_area = false

	if not tem_todas_flags():
		return

	if interior:
		if interaction_icon:
			interaction_icon.visible = false
	else:
		print("🔒 Fechando porta")
		$close.play()
		$AnimatedSprite2D.play("out_closed")
		porta_aberta = false

		if interaction_icon:
			interaction_icon.visible = true
			interaction_icon.play("interaction")

func _process(_delta):
	if jogador_na_area and Input.is_action_just_pressed(tecla_acao):
		print("🕹️ Tecla pressionada")
		if not tem_todas_flags():
			notificationPanel.show_message("Ainda parece trancado... talvez você precise conversar com alguém.")
			return

		if cena_destino:
			print("🌍 Mudando para cena:", cena_destino.resource_path)
			Global.posicao_marcador = nome_ponto_entrada
			get_tree().change_scene_to_packed(cena_destino)
		else:
			print("❌ Cena destino nula")
