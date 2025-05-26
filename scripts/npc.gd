extends CharacterBody2D

enum QUEST_STATE { BEGIN, END }
var estado_quest = QUEST_STATE.BEGIN

@onready var interaction_prompt = $InteractionPrompt

func _ready():
	$InteractPrompt.visible = false

func verifica_quest(player):
	if estado_quest == QUEST_STATE.BEGIN:
		estado_quest = QUEST_STATE.END
		return $dialogo1
	elif estado_quest == QUEST_STATE.END:
		return $dialogo2

func _on_player_interacted():
	# Força o player a iniciar o diálogo
	if interaction_prompt.is_player_inside:
		var player = interaction_prompt.player_ref
		player.to_dialog()

func _on_dialogo_1_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		$InteractPrompt.visible = true

func _on_dialogo_1_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		$InteractPrompt.visible = false
