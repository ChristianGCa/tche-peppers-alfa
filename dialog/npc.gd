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
	if player_in_area and Input.is_action_just_pressed("ui_accept"):
		print("Interação com NPC")
		get_parent().get_node("Player").can_move = false
		var dialog_instance = _DIALOG_SCREEN.instantiate()
		dialog_instance.data = _dialog_data
		planetario_hud.add_child(dialog_instance)
		dialog_instance.connect("dialog_closed", Callable(self, "_on_dialog_closed"))
		player_in_area = false
		
func _on_area_2d_body_entered(body: Node2D) -> void:
	print("Body entered:", body.name)
	if body.name == "Player":
		player_in_area = true
		print("Player entrou na área!")

func _on_area_2d_body_exited(body: Node2D) -> void:
	print(body.name)
	if body.name == "Player":
		player_in_area = false
		print("saiu")

func _on_dialog_closed():
	get_parent().get_node("Player").can_move = true
