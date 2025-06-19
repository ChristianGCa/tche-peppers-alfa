extends CanvasLayer

@onready var speaker_label = $Panel/HBoxContainer/MarginContainer2/VBoxContainer/SpeakerLabel
@onready var text_label = $Panel/HBoxContainer/MarginContainer2/VBoxContainer/TextLabel
@onready var portrait = $Panel/HBoxContainer/MarginContainer/Portrait
@onready var choice_container = $Panel/OptionsCenterContainer/ChoiceContainer
@onready var your_answer = $Panel/YourAnswerCenterContainer/YourAnswerContainer/YourAnswer
@onready var translation_label = $Panel/YourAnswerCenterContainer/YourAnswerContainer/Translation
@onready var choice_button_1 = $Panel/OptionsCenterContainer/ChoiceContainer/Option1
@onready var choice_button_2 = $Panel/OptionsCenterContainer/ChoiceContainer/Option2
@onready var choice_button_3 = $Panel/OptionsCenterContainer/ChoiceContainer/Option3

var dialog_data: DialogData
var current_index := 0
var is_typing := false
var waiting_for_retry := false
var waiting_for_choice_result := false
var current_choices: Array[ChoiceOption] = []
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
	translation_label.visible = false
	your_answer.visible = false
	choice_container.visible = false
	text_label.text = ""

	if current_index >= dialog_data.lines.size():
		hide()
		emit_signal("dialog_finished")
		return

	var line: DialogLine = dialog_data.lines[current_index]
	handle_objective(line)

	match line.speaker_type:
		DialogLine.SpeakerType.NPC:
			speaker_label.text = speaker_owner.npc_name
			portrait.texture = speaker_owner.portrait_texture
		DialogLine.SpeakerType.PLAYER:
			speaker_label.text = GameState.player_name
			portrait.texture = GameState.player_portrait

	# 🔒 Verificação antecipada de escolhas
	if line.choices.size() > 0:
		is_typing = false
		full_text = ""
		text_label.text = ""  # Garante que o texto desapareça antes
		show_choices(line.choices)
	else:
		await type_text(line.text)

func handle_objective(line: DialogLine):
	if line.creates_objective:
		ObjectiveManagement.add_objective(line.objective_text)
	elif line.completes_objective:
		ObjectiveManagement.complete_objective(line.objective_text)

func type_text(text: String) -> void:
	is_typing = true
	full_text = text
	text_label.text = ""
	char_index = 0

	while is_typing and char_index < full_text.length():
		text_label.text += full_text[char_index]
		char_index += 1
		await get_tree().create_timer(0.03).timeout

	is_typing = false

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
	your_answer.visible = true

	translation_label.text = "Tradução: " + choice.text_portuguese
	translation_label.visible = true

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
		translation_label.visible = false
		your_answer.visible = false
		show_choices(dialog_data.lines[current_index].choices)
		return

	if not choice_container.visible:
		current_index += 1
		show_line()
