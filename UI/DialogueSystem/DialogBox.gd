extends CanvasLayer

@onready var speaker_label = $Panel/HBoxContainer/MarginContainer2/VBoxContainer/SpeakerLabel
@onready var text_label = $Panel/HBoxContainer/MarginContainer2/VBoxContainer/TextLabel
@onready var portrait = $Panel/HBoxContainer/MarginContainer/Portrait
@onready var choice_container = $Panel/OptionsCenterContainer/ChoiceContainer
@onready var your_answer = $Panel/YourAnswerCenterContainer/MarginContainer/MarginContainer/YourAnswerContainer/YourAnswer
@onready var translation_label = $Panel/YourAnswerCenterContainer/MarginContainer/MarginContainer/YourAnswerContainer/Translation
@onready var choice_button_1 = $Panel/OptionsCenterContainer/ChoiceContainer/Option1
@onready var choice_button_2 = $Panel/OptionsCenterContainer/ChoiceContainer/Option2
@onready var choice_button_3 = $Panel/OptionsCenterContainer/ChoiceContainer/Option3
@onready var your_answer_container = $Panel/YourAnswerCenterContainer

var dialog_data: DialogData
var current_index := 0
var is_typing := false
var waiting_for_retry := false
var waiting_for_choice_result := false
var current_choices: Array = []
var full_text := ""
var char_index := 0
var speaker_owner: NPC = null

signal dialog_finished

func _ready():
	choice_button_1.pressed.connect(func(): _on_choice_button_pressed(0))
	choice_button_2.pressed.connect(func(): _on_choice_button_pressed(1))
	choice_button_3.pressed.connect(func(): _on_choice_button_pressed(2))

func start(dialog: DialogData, npc: NPC):
	if dialog == null:
		push_error("DialogData está nulo! Verifique se o NPC tem o recurso atribuído.")
		hide()
		return

	dialog_data = dialog
	speaker_owner = npc
	current_index = 0
	show()
	show_line()

func show_line():
	your_answer_container.visible = false
	choice_container.visible = false
	text_label.text = ""

	if current_index >= dialog_data.lines.size():
		hide()
		emit_signal("dialog_finished")
		return

	var line: DialogLine = dialog_data.lines[current_index]

	# Se a linha inicia minigame, pausa diálogo e inicia o minigame
	if line.triggers_minigame:
		hide()
		_start_minigame_from_line(line)
		return

	# Processa objetivo se houver
	handle_objective(line)

	match line.speaker_type:
		0: # NPC
			speaker_label.text = speaker_owner.npc_name
			portrait.texture = speaker_owner.portrait_texture
		1: # PLAYER
			speaker_label.text = GameState.player_name
			portrait.texture = GameState.player_portrait

	if line.choices.size() > 0:
		is_typing = false
		full_text = ""
		text_label.text = ""
		show_choices(line.choices)
	else:
		await type_text(line.text)

func _start_minigame_from_line(line: DialogLine) -> void:
	var minigame_scene = preload("res://Minigame/minigame.tscn")
	var minigame = minigame_scene.instantiate()
	get_tree().get_root().add_child(minigame)

	var json_data = _load_json_data(line.minigame_json_path)
	if json_data:
		minigame.set_data_from_dict(json_data)
		minigame.finished.connect(_on_minigame_finished_continue_dialog)
	else:
		push_error("JSON não pôde ser carregado da linha: " + line.minigame_json_path)

func _on_minigame_finished_continue_dialog() -> void:
	show()
	current_index += 1
	show_line()

func _load_json_data(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		# JSON.parse_string() retorna o valor parseado diretamente, ou null em caso de erro.
		var parsed_data = JSON.parse_string(content)

		# Verifica se o parsing foi bem-sucedido e se o resultado é um dicionário.
		if parsed_data == null:
			push_error("JSON inválido ou mal formatado em: " + path)
			return {}
		elif typeof(parsed_data) == TYPE_DICTIONARY:
			return parsed_data
		else:
			push_error("JSON em: " + path + " não retornou um dicionário.")
	else:
		push_error("Erro ao abrir arquivo JSON em: " + path)
	return {}

func handle_objective(line: DialogLine) -> void:
	if line.creates_objective:
		ObjectiveManagement.add_objective(line.objective_text)
	elif line.completes_objective:
		ObjectiveManagement.complete_objective(line.objective_text)

func type_text(text: String) -> void:
	is_typing = true
	# Desliga BBCode temporariamente para garantir que não processe durante a digitação
	text_label.bbcode_enabled = false
	text_label.text = "" # Limpa o texto antes de começar a digitar
	char_index = 0

	full_text = _parse_glossary_tags(text)
	var plain_text := _strip_bbcode(full_text) # Isso já remove as tags BBCode

	while is_typing and char_index < plain_text.length():
		# Adiciona apenas o caracter "limpo" (sem BBCode)
		text_label.append_text(plain_text[char_index])
		char_index += 1
		await get_tree().create_timer(0.03).timeout

	# Digitação terminou. Agora, habilita BBCode e atribui o texto completo com as tags
	is_typing = false
	text_label.bbcode_enabled = true
	text_label.bbcode_text = full_text

func _strip_bbcode(text: String) -> String:
	var pattern := "\\[/?[a-zA-Z0-9=_]+\\]"
	var regex := RegEx.new()
	regex.compile(pattern)
	return regex.sub(text, "", true)


func _parse_glossary_tags(text: String) -> String:
	var pattern := "\\[gloss:(.+?)\\|(.+?)\\]"
	var regex = RegEx.new()
	regex.compile(pattern)

	var result := ""
	var start := 0

	for match in regex.search_all(text):
		var range := match.get_start(0)
		var end := match.get_end(0)

		# Texto antes da gíria
		result += text.substr(start, range - start)

		var term := match.get_string(1)
		var translation := match.get_string(2)

		# Adiciona ao glossário
		GlossaryManager.unlock_term(term, translation)

		# Adiciona como BBCode com cor
		result += "[color=yellow]" + term + "[/color]"

		start = end

	# Adiciona o que sobrou
	result += text.substr(start)

	return result


func show_choices(choices: Array[ChoiceOption]):
	# Garante que o texto principal suma
	text_label.text = ""

	# Força o nome e retrato do jogador toda vez que forem mostrar as escolhas
	speaker_label.text = GameState.player_name
	portrait.texture = GameState.player_portrait

	current_choices = choices
	var buttons = [choice_button_1, choice_button_2, choice_button_3]

	for i in buttons.size():
		if i < choices.size():
			buttons[i].visible = true
			buttons[i].text = choices[i].text_english
		else:
			buttons[i].visible = false

	choice_container.visible = true

func _on_choice_button_pressed(index: int):
	if index >= 0 and index < current_choices.size():
		var choice = current_choices[index]
		_on_choice_selected(choice)

func _on_choice_selected(choice: ChoiceOption):
	choice_container.visible = false
	is_typing = false

	your_answer.text = "Sua resposta: " + choice.text_english
	translation_label.text = "Tradução: " + choice.text_portuguese

	your_answer_container.visible = true

	# Mostra resposta do NPC
	speaker_label.text = speaker_owner.npc_name
	portrait.texture = choice.response_portrait if choice.response_portrait else speaker_owner.portrait_texture

	await type_text(choice.npc_response)

	if choice.is_correct:
		waiting_for_choice_result = true
	else:
		waiting_for_retry = true

func _unhandled_input(event: InputEvent) -> void:
	if not visible: return
	if not event.is_action_pressed("ok"): return

	if is_typing:
		is_typing = false
		text_label.text = full_text
		return

	if waiting_for_choice_result:
		waiting_for_choice_result = false
		current_index += 1
		show_line()
		return

	if waiting_for_retry:
		waiting_for_retry = false
		your_answer_container.visible = false
		show_choices(dialog_data.lines[current_index].choices)
		return

	if not choice_container.visible:
		current_index += 1
		show_line()
