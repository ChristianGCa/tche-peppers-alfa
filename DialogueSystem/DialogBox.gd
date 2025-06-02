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


signal dialog_finished

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

	if current_index >= dialog_data.lines.size():
		hide()
		emit_signal("dialog_finished")
		return

	var line = dialog_data.lines[current_index]
	speaker_label.text = line.speaker_name
	text_label.text = ""
	portrait.texture = line.portrait

	if line.choices.size() > 0:
		show_choices(line.choices)
	else:
		type_text(line.text)


func show_choices(choices: Array[ChoiceOption]):
	var buttons = [choice_button_1, choice_button_2, choice_button_3]

	for i in buttons.size():
		var button = buttons[i]
		if i < choices.size():
			var choice = choices[i]
			button.visible = true
			button.text = choice.text_english

			# Desconecta conexões antigas antes de conectar novamente
			for conn in button.get_signal_connection_list("pressed"):
				if typeof(conn) == TYPE_DICTIONARY and conn.has("method") and conn["method"] == "_on_choice_selected":
					button.disconnect("pressed", Callable(conn["target"], conn["method"]))

			button.connect("pressed", Callable(self, "_on_choice_selected").bind(choice))
		else:
			button.visible = false

	choice_container.visible = true


func _on_choice_selected(choice: ChoiceOption):
	choice_container.visible = false
	is_typing = false


	your_answer.text = "Sua resposta: " + choice.text_english
	your_answer.visible = true

	translation_label.text = "Tradução: " + choice.text_portuguese
	translation_label.visible = true
	

	# Reação do NPC
	text_label.text = choice.npc_response
	portrait.texture = choice.response_portrait if choice.response_portrait else portrait.texture

	# Verifica se a escolha é correta
	if choice.is_correct:
		# Avança no diálogo (vai para a próxima linha depois que o jogador apertar E)
		current_index += 1
	else:
		# Resposta errada: volta para mostrar as opções de novo,
		# porém só depois que o jogador apertar "ok" para avançar a reação do NPC.
		# Para isso, definimos uma flag para controlar este estado.
		waiting_for_retry = true



func type_text(text: String):
	is_typing = true
	text_label.text = text  # Mostra texto imediatamente (sem delay)
	is_typing = false


func _unhandled_input(event):
	if !visible: return

	if event.is_action_pressed("ok"):

		# Se estiver mostrando opções para tentar de novo
		if waiting_for_retry:
			waiting_for_retry = false
			translation_label.visible = false
			show_choices(dialog_data.lines[current_index].choices)
			return

		if choice_container.visible:
			# Ignorar avançar no diálogo se estiver mostrando escolhas
			return

		if is_typing:
			text_label.text = dialog_data.lines[current_index].text
			is_typing = false
		else:
			current_index += 1
			show_line()
