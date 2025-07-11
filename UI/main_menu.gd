# main_menu.gd
extends Node2D

@onready var new_game_button = $CenterContainer2/VBoxContainer/NewGameButton
@onready var how_to_play_button = $CenterContainer2/VBoxContainer/HowPlayButton
@onready var credits_button = $CenterContainer2/VBoxContainer/CreditsButton
@onready var quit_button = $CenterContainer2/VBoxContainer/QuitButton
@onready var continue_button = $CenterContainer2/VBoxContainer/ContinueButton
@onready var click = $AudioStreamPlayer2D

func _ready():
	new_game_button.pressed.connect(_on_new_game_pressed)
	how_to_play_button.pressed.connect(_on_how_to_play_pressed)
	credits_button.pressed.connect(_on_credits_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	continue_button.pressed.connect(_on_continue_pressed)

func _on_new_game_pressed():
	click.play()
	await click.finished
	var save_path = "user://progress.save"
	
	# Verifica se o arquivo de save existe e o deleta
	if FileAccess.file_exists(save_path):
		var dir = DirAccess.open("user://")
		if dir:
			dir.remove(save_path)
			print("✅ Arquivo de save existente ('progress.save') foi deletado.")
		else:
			push_error("❌ Não foi possível acessar o diretório 'user://'.")
	else:
		print("ℹ️ Nenhum arquivo de save ('progress.save') encontrado para deletar.")
	# --- FIM DO NOVO CÓDIGO ---
	
	get_tree().change_scene_to_file("res://UI/intro.tscn") # ou outro caminho para o menu de fases

func _on_continue_pressed():
	click.play()
	await click.finished
	get_tree().change_scene_to_file("res://UI/Map/map.tscn")
	
func _on_how_to_play_pressed():
	click.play()
	await click.finished
	get_tree().change_scene_to_file("res://UI/how_to_play.tscn")

func _on_credits_pressed():
	click.play()
	await click.finished
	get_tree().change_scene_to_file("res://UI/creditos.tscn")

func _on_quit_pressed():
	click.play()
	await click.finished
	get_tree().quit()
