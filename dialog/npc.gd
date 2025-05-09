extends CharacterBody2D

var player_in_area := false

# Certifique-se de que isso aponta para a .tscn da UI, e não para o script .gd
const _DIALOG_SCREEN: PackedScene = preload("res://dialog/dialog_screen.tscn")

# Busca o HUD dinamicamente quando a cena é carregada
@onready var planetario_hud = get_parent().get_node("HUD")  # HUD deve estar no mesmo nível do NPC

var _dialog_data: Dictionary = {
	0: {
		"faceset": "res://assets/character/npc1.png",
		"dialog": "Hi, man! Are you lost around here?",
		"traduction": "Buenas, tchê! Tá perdido por essas bandas?",
		"title": "Gaúcho"
	},
	1: {
		"faceset": "res://assets/character/npc1.png",
		"dialog": "I've never seen you around here... You're a foreigner, right?",
		"traduction": "Nunca te vi por aqui... Tu é estrangeiro, né?",
		"title": "Gaúcho"
	}
}

func _process(delta: float) -> void:
	if player_in_area:
		print("ta na area")
	if player_in_area and Input.is_action_just_pressed("ui_accept"):
		var dialog_instance = _DIALOG_SCREEN.instantiate()
		dialog_instance.data = _dialog_data  # Passa os dados de diálogo
		planetario_hud.add_child(dialog_instance)  # Adiciona no HUD visível
		player_in_area = false  # Evita múltiplas ativações seguidas

func _on_area_2d_body_entered(body: Node2D) -> void:
	print(body.name)
	print("aaaaa")
	if body.name == "player":
		player_in_area = true
		print("entrou")

func _on_area_2d_body_exited(body: Node2D) -> void:
	print(body.name)
	if body.name == "player":
		player_in_area = false
		print("saiu")
