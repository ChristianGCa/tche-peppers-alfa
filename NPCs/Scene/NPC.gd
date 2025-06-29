# NPC.gd
extends CharacterBody2D
class_name NPC

# Diálogo
@export var dialog_intro: DialogData
@export var dialog_in_progress: DialogData
@export var dialog_completed: DialogData

# Missão
@export var quest: QuestData = null

# Aparência
@export var sprite_frames: SpriteFrames
@export var portrait_texture: Texture
@export var npc_name: String = "Name"

# Minigame
@export var has_minigame: bool = false
@export var minigame_json_path: String = ""

# Progresso de fase
@export var level_id: String = ""  # Ex: "planetario", "catedral", etc.

# Flag do diálogo (pode ser personalizada)
@export var dialog_flag_name: String = ""

# Controle de visibilidade
@export var auto_hide_after_dialogue: bool = false   # Esconde após falar uma vez
@export var show_only_if_flag: bool = false          # Só aparece se flag existir
@export var required_flag_to_show: String = ""       # Flag necessária para aparecer

var minigame_started := false

func _ready():
	print("👤 NPC pronto:", npc_name)

	# Esconde o NPC se exige uma flag específica que ainda não foi ativada
	if show_only_if_flag and required_flag_to_show != "":
		if not GameState.get_flag(required_flag_to_show):
			print("🙈 NPC ocultado (aguardando flag):", required_flag_to_show)
			queue_free()
			return

	# Esconde o NPC se a flag de diálogo já foi criada e marcado para sumir
	if auto_hide_after_dialogue:
		var flag_name = _get_dialog_flag_name()
		if GameState.get_flag(flag_name):
			print("🙈 NPC ocultado após diálogo (flag presente):", flag_name)
			queue_free()
			return

	# Inicialização visual e configuração
	$AnimatedSprite2D.frames = sprite_frames
	$Area2D.add_to_group("dialogue_area")
	$Area2D.set_meta("dialog_valid", true)
	$Area2D.set_meta("quest_npc", self)
	$DialogBaloon.visible = false

func _get_dialog_flag_name() -> String:
	return dialog_flag_name if dialog_flag_name != "" else "talked_to_" + name

func get_current_dialog() -> DialogData:
	if quest == null:
		return dialog_intro

	match quest.state:
		QuestData.QuestState.NOT_STARTED:
			return dialog_intro
		QuestData.QuestState.IN_PROGRESS:
			return dialog_in_progress
		QuestData.QuestState.COMPLETED:
			return dialog_completed

	return dialog_intro

func _on_dialog_finished():
	print("💬 Diálogo finalizado com NPC:", name)

	if quest != null:
		if quest.state == QuestData.QuestState.COMPLETED:
			_register_flag()
		else:
			print("⏳ Quest ainda em progresso; flag não registrada.")
	else:
		_register_flag()

	if quest != null and quest.state == QuestData.QuestState.IN_PROGRESS:
		if quest.is_completed():
			print("🎯 Quest completada!")
			quest.state = QuestData.QuestState.COMPLETED
			if quest.objective_text != "":
				ObjectiveManagement.complete_objective(quest.objective_text)

	if has_minigame and not minigame_started:
		print("🎮 Iniciando minigame...")
		minigame_started = true
		call_deferred("_start_minigame")

	if quest == null or quest.state == QuestData.QuestState.COMPLETED:
		_complete_level() # Isso agora chamará a função que interage com o botão

func _register_flag():
	var flag_name = _get_dialog_flag_name()
	GameState.set_flag(flag_name)
	print("✅ Flag registrada:", flag_name)

func _complete_level():
	if level_id == "":
		print("⚠️ level_id não definido para NPC:", name)
		return

	print("🏁 Marcando level como completo:", level_id)

	var save_path = "user://progress.save"
	var progress := {}

	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		if file.get_length() > 0:
			progress = file.get_var()

	# Exemplo simples: desbloqueia o próximo level com base no atual
	# Isso aqui define qual fase será desbloqueada.
	if level_id == "planetario":
		progress["catedral"] = true
	elif level_id == "catedral":
		progress["base_aerea"] = true
	# ... adicione outras fases aqui

	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(progress)
	file.flush()

	# Tenta encontrar o botão e torná-lo visível
	_show_return_button_in_level()


func _show_return_button_in_level():

	var return_button = $"../../HUD/ReturnToMapButton"
	
	if return_button and return_button is Button:
		if return_button.is_visible(): # Evita animar se já estiver visível
			print("ℹ️ Botão 'Voltar ao Mapa' já está visível.")
			return
		
		return_button.visible = true
		# Animação de entrada (copiada do returnToMapButton.gd)
		return_button.position.y = -50
		var tween := return_button.create_tween()
		tween.tween_property(return_button, "position:y", 20, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		print("⬆️ NPC tornou o botão 'Voltar ao Mapa' visível e animado.")
	else:
		print("❌ Botão 'ReturnToMapButton' não encontrado ou não é um botão em 'HUD' da cena atual.")


func _start_minigame():
	print("📥 Carregando minigame:", minigame_json_path)
	var minigame = preload("res://Minigame/minigame.tscn").instantiate()
	get_tree().get_root().add_child(minigame)

	var json_data = _load_json_data(minigame_json_path)
	if json_data:
		print("✅ Dados do minigame carregados com sucesso")
		minigame.set_data_from_dict(json_data)
		minigame.finished.connect(_on_minigame_finished)
	else:
		push_error("❌ Minigame JSON inválido")

func _on_minigame_finished():
	print("🎉 Minigame finalizado com sucesso")
	var dialog_data = dialog_completed if quest == null else get_current_dialog()
	DialogManagement.start_dialog(dialog_data, self)

func _load_json_data(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var data = JSON.parse_string(content)
		if typeof(data) == TYPE_DICTIONARY:
			return data
		else:
			push_error("❌ JSON inválido em: " + path)
	else:
		push_error("❌ Falha ao abrir: " + path)
	return {}
