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
@export var minigame_json_path: String = "" # exemplo: res://minigames/nivel_1.json
@export var has_minigame: bool = false
var minigame_started := false


func _ready():
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
	GameState.set_flag("talked_to_" + name)

	if quest != null and quest.state == QuestData.QuestState.IN_PROGRESS:
		if quest.is_completed():
			quest.state = QuestData.QuestState.COMPLETED
			if quest.objective_text != "":
				ObjectiveManagement.complete_objective(quest.objective_text)

	# ✅ Inicia o minigame após o primeiro diálogo, se aplicável
	if has_minigame and not minigame_started:
		minigame_started = true
		call_deferred("_start_minigame") # Aguarda retorno do diálogo

func _start_minigame():
	var minigame = preload("res://Minigame/minigame.tscn").instantiate()
	get_tree().get_root().add_child(minigame)

	# Carrega JSON do caminho exportado
	var json_data = _load_json_data(minigame_json_path)
	if json_data:
		minigame.set_data_from_dict(json_data)
		minigame.finished.connect(_on_minigame_finished)
	else:
		push_error("Minigame JSON não pôde ser carregado.")

func _on_minigame_finished():
	print("Minigame finalizado")
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
			push_error("JSON inválido em: " + path)
	else:
		push_error("Falha ao abrir: " + path)
	return {}
