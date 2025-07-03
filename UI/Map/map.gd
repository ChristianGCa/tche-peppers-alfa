extends Node2D

const SAVE_PATH = "user://progress.save"

@onready var catedral_button = $catedralButton
@onready var catedral_lock = $catedralButton/cadeado
@onready var base_button = $baseAereaButton
@onready var base_lock = $baseAereaButton/cadeado
@onready var message_label: Label = $MessageLabel # Certifique-se de que este Label está na sua cena

var progress = {
	"planetario": true, # Planetário começa desbloqueado por padrão
	"catedral": false,
	"base_aerea": false
}

# Variável para evitar múltiplos carregamentos de cena
var is_loading_level: bool = false
# NOVA VARIÁVEL: Para controlar o tween da mensagem do label
var message_tween: Tween = null

func _ready():
	# Inicializa o label de mensagem oculto e transparente
	if message_label:
		message_label.visible = false
		message_label.modulate = Color(1, 1, 1, 0) # Totalmente transparente inicialmente
		message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		message_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP) # Apenas para centralizar o pivot
	
	load_progress()
	update_map_locks() # Atualiza a visibilidade dos cadeados ao carregar o mapa

func start_level(scene_path):
	if is_loading_level: # Se já estiver carregando, ignore
		return
	
	# Desativa todos os botões do mapa para evitar mais cliques
	set_map_buttons_disabled(true)
	
	is_loading_level = true 
	call_deferred("change_scene_to_file_deferred", scene_path)

func change_scene_to_file_deferred(scene_path: String):
	get_tree().change_scene_to_file(scene_path)

func set_map_buttons_disabled(disabled: bool):
	# Itera sobre os botões e os desativa/ativa
	# Certifique-se de que esses botões existem na sua cena de mapa!
	# Remova a linha abaixo se 'new_game_button' não for um botão da cena do mapa
	# new_game_button.disabled = disabled 
	catedral_button.disabled = disabled
	base_button.disabled = disabled
	# Adicione quaisquer outros botões de fase que você tenha aqui

func save_progress():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_var(progress)
	print("Progresso salvo: ", progress)

func load_progress():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file.get_length() > 0: # Verifica se o arquivo não está vazio
			progress = file.get_var()
			print("Progresso carregado: ", progress)
		else:
			print("Arquivo de progresso vazio, usando progresso padrão.")
	else:
		print("Arquivo de progresso não encontrado, usando progresso padrão.")

func update_map_locks():
	# Catedral desbloqueia se "catedral" for true no progresso
	if progress.get("catedral", false):
		catedral_lock.visible = false
		print("Cadeado da Catedral removido.")
	else:
		catedral_lock.visible = true # Garante que esteja visível se bloqueado

	# Base Aérea desbloqueia se "base_aerea" for true no progresso
	if progress.get("base_aerea", false):
		base_lock.visible = false
		print("Cadeado da Base Aérea removido.")
	else:
		base_lock.visible = true # Garante que esteja visível se bloqueado

func show_locked_message(message: String, target_button_position: Vector2):
	if not message_label:
		return

	# NOVO CÓDIGO AQUI: Cancela o tween anterior se existir
	if message_tween and message_tween.is_valid() and message_tween.is_running():
		message_tween.stop() # Ou .kill() se quiser parar completamente e descartar
	
	# Posiciona o label um pouco acima do botão
	message_label.global_position = target_button_position + Vector2(0, -30)
	message_label.global_position.x -= message_label.size.x / 7.0
	
	message_label.text = message
	message_label.modulate = Color(1, 1, 1, 0) # Começa transparente
	message_label.visible = true
	
	message_tween = create_tween() # Atribui o novo tween à variável
	message_tween.set_parallel(false)
	
	# Fade in
	message_tween.tween_property(message_label, "modulate", Color(1, 1, 1, 1), 0.5)
	# Wait
	message_tween.tween_interval(2.0)
	# Fade out
	message_tween.tween_property(message_label, "modulate", Color(1, 1, 1, 0), 0.5)
	# Hide when fade out is complete and clear the tween variable
	message_tween.tween_callback(func(): 
		message_label.visible = false
		message_tween = null # Limpa a referência ao tween quando ele termina
	)


func _on_planetario_button_pressed():
	$AudioStreamPlayer2D.play()
	await $AudioStreamPlayer2D.finished
	start_level("res://Levels/planetario.tscn")

func _on_catedral_button_pressed():
	$AudioStreamPlayer2D.play()
	await $AudioStreamPlayer2D.finished
	if progress.get("catedral", false):
		start_level("res://Levels/catedral.tscn")
	else:
		show_locked_message("Local bloqueado", catedral_button.global_position)
		print("Tentativa de acessar Catedral bloqueada.")

func _on_base_aerea_button_pressed() -> void:
	$AudioStreamPlayer2D.play()
	await $AudioStreamPlayer2D.finished
	if progress.get("base_aerea", false):
		start_level("res://Levels/BaseAerea.tscn")
	else:
		show_locked_message("Local bloqueado", base_button.global_position)
		print("Tentativa de acessar Base Aérea bloqueada.")

func _on_voltar_pressed() -> void:
	$AudioStreamPlayer2D.play()
	await $AudioStreamPlayer2D.finished
	if is_loading_level:
		return

	is_loading_level = true
	call_deferred("change_scene_to_file_deferred", "res://UI/main_menu.tscn")
