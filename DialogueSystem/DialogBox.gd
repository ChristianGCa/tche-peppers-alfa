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


signal dialog_finished

func _ready():
	choice_button_1.pressed.connect(func(): _on_choice_button_pressed(0))
	choice_button_2.pressed.connect(func(): _on_choice_button_pressed(1))
	choice_button_3.pressed.connect(func(): _on_choice_button_pressed(2))

func start(dialog: DialogData):
	if dialog == null:
		push_error("DialogData está nulo! Verifique se o NPC tem o recurso atribuído.")
		hide()
		return

	dialog_data = dialog
	current_index = 0
	show()
	show_line()

func show_line():
	translation_label.text = ""
	translation_label.visible = false
	your_answer.text = ""
	your_answer.visible = false
	choice_container.visible = false
	waiting_for_retry = false
	waiting_for_choice_result = false

	if current_index >= dialog_data.lines.size():
		hide()
		emit_signal("dialog_finished")
		return

	var line = dialog_data.lines[current_index]
	speaker_label.text = line.speaker_name
	text_label.text = ""
	portrait.texture = line.portrait

	if line.text != "":
		type_text(line.text)
	else:
		check_if_should_show_choices()


func type_text(text: String) -> void:
	is_typing = true
	text_label.clear()
	
	for i in text.length():
		# Se o jogador apertar E, finaliza a digitação
		if not is_typing:
			text_label.text = text
			break
		
		text_label.append_text(text[i])
		await get_tree().create_timer(0.03).timeout

	is_typing = false


func check_if_should_show_choices():
	var line = dialog_data.lines[current_index]
	if line.choices.size() > 0:
		show_choices(line.choices)


func show_choices(choices: Array[ChoiceOption]):
	current_choices = choices
	var buttons = [choice_button_1, choice_button_2, choice_button_3]

	for i in buttons.size():
		var button = buttons[i]
		if i < choices.size():
			var choice = choices[i]
			button.visible = true
			button.text = choice.text_english
		else:
			button.visible = false

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

	text_label.text = choice.npc_response
	portrait.texture = choice.response_portrait if choice.response_portrait else portrait.texture

	if choice.is_correct:
		waiting_for_choice_result = true  # Espera o jogador apertar E para prosseguir
	else:
		waiting_for_retry = true  # Volta para tentar a escolha de novo


func _unhandled_input(event: InputEvent) -> void:
	if !visible: return
	if not event.is_action_pressed("ok"): return

	# Caso 1: O jogador apertou E enquanto está digitando
	if is_typing:
		is_typing = false  # Interrompe o efeito e exibe o texto completo imediatamente
		return

	# Caso 2: Acertou uma resposta com reação, agora pode continuar
	if waiting_for_choice_result:
		waiting_for_choice_result = false
		current_index += 1
		show_line()
		return

	# Caso 3: Errou a resposta e vai tentar de novo
	if waiting_for_retry:
		waiting_for_retry = false
		translation_label.visible = false
		your_answer.visible = false
		show_choices(dialog_data.lines[current_index].choices)
		return

	# Caso 4: Nada especial — segue o fluxo normal
	if not choice_container.visible:
		current_index += 1
		show_line()
