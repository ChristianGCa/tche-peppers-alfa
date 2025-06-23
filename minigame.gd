extends CanvasLayer

signal finished

var phrases_english: Array[String] = []
var phrases_portuguese: Array[String] = []
var options: Array = []
var correct_answers: Array = []

var current_index: int = 0

@onready var label_phrase = $TextureRect/VBoxContainer/LabelPhrase as RichTextLabel
@onready var label_translation = $TextureRect/VBoxContainer/LabelTranslation
@onready var option_buttons = [
	$TextureRect/VBoxContainer/CenterContainer/HBoxContainer/Button1,
	$TextureRect/VBoxContainer/CenterContainer/HBoxContainer/Button2,
	$TextureRect/VBoxContainer/CenterContainer/HBoxContainer/Button3
]

func set_data_from_dict(data: Dictionary):
	for phrase in data.get("phrases", []):
		phrases_english.append(phrase.get("english", ""))
		phrases_portuguese.append(phrase.get("portuguese", ""))
	options = data.get("options", [])
	correct_answers = data.get("correct_answers", [])

	show_phrase()

func show_phrase():
	if current_index >= phrases_english.size():
		end_minigame()
		return

	label_phrase.bbcode_enabled = false
	label_phrase.text = phrases_english[current_index]
	label_translation.text = ""
	label_translation.visible = false

	var current_options = options[current_index]
	for i in option_buttons.size():
		if i < current_options.size():
			option_buttons[i].text = current_options[i]
			option_buttons[i].visible = true
			option_buttons[i].disabled = false
		else:
			option_buttons[i].visible = false

func _ready():
	for i in range(option_buttons.size()):
		option_buttons[i].pressed.connect(func(): _on_option_pressed(i))

func _on_option_pressed(index: int):
	var selected = option_buttons[index].text
	var correct = correct_answers[current_index]

	if selected == correct:
		for button in option_buttons:
			button.disabled = true

		# ✅ Insere a resposta na frase com cor verde
		var original = phrases_english[current_index]
		var filled = original.replace("___", "[color=green]" + correct + "[/color]")
		label_phrase.bbcode_enabled = true
		label_phrase.bbcode_text = filled

		label_translation.text = "Tradução: " + phrases_portuguese[current_index]
		label_translation.visible = true

		await get_tree().create_timer(2.0).timeout

		current_index += 1
		show_phrase()
	else:
		label_phrase.bbcode_enabled = false
		label_phrase.text = "Tente novamente!"
		for button in option_buttons:
			button.disabled = true
		await get_tree().create_timer(1.5).timeout
		show_phrase()

func end_minigame():
	hide()
	emit_signal("finished")
