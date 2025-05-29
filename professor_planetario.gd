extends Area2D

enum QUEST_STATE { BEGIN, END }
var estado_quest = QUEST_STATE.BEGIN

func _ready():
	$InteractPrompt.visible = false

func verifica_quest(player):
	if estado_quest == QUEST_STATE.BEGIN:
		estado_quest = QUEST_STATE.END
		return $dialogo1
	elif estado_quest == QUEST_STATE.END:
		return $dialogo2


func _on_dialogo_1_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		$InteractPrompt.visible = true

func _on_dialogo_1_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		$InteractPrompt.visible = false
