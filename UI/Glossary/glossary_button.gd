extends TextureButton

@onready var glossary_book_scene = preload("res://UI/Glossary/glossary_book.tscn") # Ajuste o caminho se for diferente
@onready var new_term_indicator = $NewTermIndicator

@onready var glossary_book_instance = $"../GlossaryBook"

func _ready():
	pressed.connect(_on_glossary_button_pressed)
	GlossaryManager.new_term_unlocked.connect(_on_new_term_unlocked)
	_update_indicator_visibility()

func _on_glossary_button_pressed():
	if not is_instance_valid(glossary_book_instance):
		glossary_book_instance = glossary_book_scene.instantiate()
		get_tree().get_root().get_node("HUD").add_child(glossary_book_instance)

	glossary_book_instance.visible = true
	glossary_book_instance.set_process_input(true)

	GlossaryManager.mark_all_as_viewed()
	_update_indicator_visibility()

	self.visible = false  # <- oculta o botão depois de abrir



func _on_new_term_unlocked(term: String, translation: String):
	_update_indicator_visibility()

func _update_indicator_visibility():
	new_term_indicator.visible = GlossaryManager.has_unviewed_terms()
