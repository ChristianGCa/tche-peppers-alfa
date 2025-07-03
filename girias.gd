extends Node2D

@onready var giria_list = $ColorRect/VScrollBar/VBoxContainer

func _ready():
	show_discovered_terms()

func show_discovered_terms():
	for term_english in GlossaryManager.known_terms.keys():
		var term_portuguese = GlossaryManager.known_terms[term_english]

		var label = Label.new()
		label.text = term_english + " — " + term_portuguese
		label.add_theme_font_size_override("font_size", 18)

		giria_list.add_child(label)

func _on_button_pressed() -> void:
	$AudioStreamPlayer2D.play()
	await $AudioStreamPlayer2D.finished
	get_tree().change_scene_to_file("res://UI/main_menu.tscn")
