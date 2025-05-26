extends Control

var dialogue_line
var answered_correctly = false
signal dialogue_item_selected(item)

@onready var label_text = $margin/LabelText as RichTextLabel
@onready var hbox_buttons = $margin/HBoxButtons
@onready var translation_label = $margin/LabelTranslation
@onready var button_show_translation = $margin/VBoxContainer/ButtonTranslation

func _ready():
	connect("gui_input", Callable(self, "_on_gui_input"))

	# Ignora clique nos filhos (para que passe para o pai)
	label_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox_buttons.mouse_filter = Control.MOUSE_FILTER_IGNORE
	translation_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button_show_translation.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _on_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("dialogue_item_selected", self)

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
