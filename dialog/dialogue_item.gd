extends Control

var dialogue_line
var answered_correctly = false

@onready var label_text = $margin/LabelText as RichTextLabel
@onready var hbox_buttons = $margin/HBoxButtons
@onready var translation_label = $margin/LabelTranslation
@onready var button_show_translation = $margin/VBoxContainer/ButtonTranslation

func set_dialogue_line(line):
	await ready
	dialogue_line = line

	# Se não for minigame, consideramos como já respondido
	answered_correctly = not line.is_minigame

	label_text.bbcode_enabled = true
	label_text.text = line.text
	translation_label.text = line.translation
	translation_label.visible = false
	button_show_translation.visible = true

	# Limpa os botões anteriores
	for child in hbox_buttons.get_children():
		child.queue_free()

	if line.is_minigame:
		hbox_buttons.visible = true
		for option in line.word_options:
			var btn = Button.new()
			btn.text = option
			btn.pressed.connect(_on_option_pressed.bind(option, btn))
			hbox_buttons.add_child(btn)
	else:
		hbox_buttons.visible = false

	button_show_translation.pressed.connect(_on_show_translation)

func _on_option_pressed(selected_word, button):
	if selected_word == dialogue_line.correct_word:
		button.modulate = Color.GREEN
		label_text.text = dialogue_line.text.replace("____", "[b]" + selected_word + "[/b]")
		answered_correctly = true
	else:
		button.modulate = Color.RED

func _on_show_translation():
	translation_label.visible = true
	button_show_translation.visible = false
