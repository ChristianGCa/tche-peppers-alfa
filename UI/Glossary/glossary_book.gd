extends TextureRect

@onready var list = $MarginContainer/VBoxContainer
@onready var notification_panel = $"../NotificationPanel"
@onready var close_button = $CloseButton
@onready var glossary_button = $"../GlossaryButton"
@onready var glossary_empty_label = $GlossaryEmpty

func _ready():
	self.visible = false
	close_button.pressed.connect(_on_close_pressed)
	GlossaryManager.new_term_unlocked.connect(_on_new_term)
	refresh()

func _on_close_pressed():
	visible = false
	if is_instance_valid(glossary_button):
		glossary_button.visible = true

func refresh():
	for child in list.get_children():
		child.queue_free()

	for term in GlossaryManager.known_terms.keys():
		var translation = GlossaryManager.known_terms[term]
		var label = Label.new()
		label.text = term + " → " + translation
		list.add_child(label)

	# Mostra ou esconde o aviso de glossário vazio
	glossary_empty_label.visible = GlossaryManager.known_terms.is_empty()

func _on_new_term(term: String, translation: String):
	glossary_empty_label.visible = false
	refresh()
	notification_panel.show_message("Nova gíria aprendida: %s → %s" % [term, translation])
