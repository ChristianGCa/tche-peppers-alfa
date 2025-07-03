extends CanvasLayer

signal finished

var phrases_english: Array[String] = []
var phrases_portuguese: Array[String] = []
var options: Array = []
var correct_answers: Array = []
var option_translations: Array = []

var current_index: int = 0

@onready var label_phrase = $TextureRect/VBoxContainer/LabelPhrase as RichTextLabel
@onready var label_translation = $TextureRect/VBoxContainer/LabelTranslation
@onready var option_buttons = [
	$TextureRect/HBoxContainer/Button1,
	$TextureRect/HBoxContainer/Button2,
	$TextureRect/HBoxContainer/Button3
]

func set_data_from_dict(data: Dictionary):
	for phrase in data.get("phrases", []):
		phrases_english.append(phrase.get("english", ""))
		phrases_portuguese.append(phrase.get("portuguese", ""))
	options = data.get("options", [])
	correct_answers = data.get("correct_answers", [])
	option_translations = data.get("option_translations", [])

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
	$AudioStreamPlayer2D.play()
	var selected = option_buttons[index].text
	var correct = correct_answers[current_index]

	for button in option_buttons:
		button.disabled = true

	var original = phrases_english[current_index]
	label_phrase.bbcode_enabled = true

	var filled: String
	if selected == correct:
		filled = original.replace("___", "[color=green]" + correct + "[/color]")
	else:
		filled = original.replace("___", "[color=red]" + selected + "[/color]")

	label_phrase.bbcode_text = filled
	label_translation.text = "Tradução: " + phrases_portuguese[current_index]
	label_translation.visible = true

	# Trocar texto do botão para a tradução
	if current_index < option_translations.size() and index < option_translations[current_index].size():
		var translation = option_translations[current_index][index]
		option_buttons[index].text = translation

	await get_tree().create_timer(1.0).timeout

	if selected == correct:
		current_index += 1

	show_phrase()

func end_minigame():
	hide()
	emit_signal("finished")
