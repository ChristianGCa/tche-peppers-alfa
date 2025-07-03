extends Node2D

@export var full_text: String = "Edward, um americano fascinado pelas histórias do avô, chegou em Santa Maria para desvendar a cultura local e as gírias gaúchas. Prepare-se para aprender inglês de um jeito único, explorando a cidade e seus costumes."
@export var typing_speed: float = 0.05 # Tempo em segundos entre cada caractere

@onready var rich_text_label: RichTextLabel = $ColorRect/RichTextLabel
@onready var next_button: Button = $Button # Pega a referência ao botão

var current_char_index: int = 0
var timer: Timer
var text_fully_displayed: bool = false

func _ready():
	rich_text_label.text = ""
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = typing_speed
	timer.start()
	timer.timeout.connect(_on_timer_timeout)
	next_button.pressed.connect(_on_next_button_pressed) # Conecta o sinal de clique do botão

func _on_timer_timeout():
	if not text_fully_displayed:
		if current_char_index < full_text.length():
			rich_text_label.text += full_text.substr(current_char_index, 1)
			current_char_index += 1
			timer.start()
		else:
			timer.queue_free()
			text_fully_displayed = true
			next_button.text = "Jogar" # Muda o texto do botão quando a animação termina

func _on_next_button_pressed():
	$AudioStreamPlayer2D.play()
	await $AudioStreamPlayer2D.finished
	if not text_fully_displayed:
		# Se o texto ainda não foi totalmente exibido, mostra tudo
		timer.queue_free() # Para a animação de digitação
		rich_text_label.text = full_text
		text_fully_displayed = true
		next_button.text = "Jogar"
	else:
		# Se o texto já está todo exibido, inicia a próxima fase
		get_tree().change_scene_to_file("res://UI/Map/map.tscn") # Certifique-se que o caminho está correto
