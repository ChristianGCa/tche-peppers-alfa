extends CharacterBody2D
class_name NPC

@export var dialog_intro: DialogData
@export var dialog_in_progress: DialogData
@export var dialog_completed: DialogData
@export var quest: QuestData = null
@export var sprite_frames: SpriteFrames
@export var dialog_flag_name: String = ""
@export var npc_name: String = "Name"
@export var portrait_texture: Texture
@export var minigame_json_path: String = ""
@export var has_minigame: bool = false
@export var level_id: String = "" # Ex: "planetario", "catedral", etc.


var minigame_started := false

func _ready():
	print("👤 NPC pronto:", npc_name)
	$AnimatedSprite2D.frames = sprite_frames
	$Area2D.add_to_group("dialogue_area")
	$Area2D.set_meta("dialog_valid", true)
	$Area2D.set_meta("quest_npc", self)
	$DialogBaloon.visible = false

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

	# Se tiver quest:
	if quest != null:
		# Se a quest já estiver concluída, seta a flag (ex: depois do minigame)
		if quest.state == QuestData.QuestState.COMPLETED:
			_register_flag()
		else:
			print("⏳ Quest ainda não foi concluída, não será criada flag ainda.")
	else:
		# Sem quest → seta a flag normalmente
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

func _register_flag():
	var flag_name = dialog_flag_name if dialog_flag_name != "" else "talked_to_" + name
	GameState.set_flag(flag_name)
	print("✅ Flag registrada:", flag_name)


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

func _complete_level():
	if level_id == "":
		print("⚠️ level_id não definido para NPC", name)
		return

	print("🏁 Marcando level como completo:", level_id)

	var save_path = "user://progress.save"
	var progress = {}

	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		if file.get_length() > 0:
			progress = file.get_var()

	progress[level_id] = true

	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(progress)
	file.flush()
