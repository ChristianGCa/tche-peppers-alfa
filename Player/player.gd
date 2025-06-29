extends CharacterBody2D

@export var speed_running: float = 200.0
@export var speed_walking: float = 600.0
@onready var anim_sprite = $AnimatedSprite2D
@onready var audio_click = $AudioStreamPlayer2D

enum STATE { WALKING, DIALOG }

var state = STATE.WALKING
var last_direction := "down"
var dialogue_area = null
var inventory: Array[String] = []
var pending_quest_update := false
var npc_current: NPC = null
var can_interact_again := true



func to_dialog():
	state = STATE.DIALOG

	if dialogue_area == null:
		push_warning("dialogue_area nula.")
		return

	if dialogue_area.has_meta("quest_npc"):
		npc_current = dialogue_area.get_meta("quest_npc")
	else:
		push_warning("Área de diálogo sem meta 'quest_npc'.")
		to_walking()
		return
	
	if npc_current.has_node("DialogBaloon"):
		var baloon = npc_current.get_node("DialogBaloon")
		baloon.visible = false

	# ✅ ANTES de pegar o diálogo, atualiza para COMPLETED se já tiver o item
	if npc_current.quest != null:
		var quest = npc_current.quest
		if quest.state == QuestData.QuestState.IN_PROGRESS and inventory.has(quest.item_required):
			quest.state = QuestData.QuestState.COMPLETED
			inventory.erase(quest.item_required)

		# Marcar pendente se ainda for o primeiro diálogo
		pending_quest_update = quest.state == QuestData.QuestState.NOT_STARTED

	# Agora sim pega o diálogo certo
	var dialog_data = npc_current.get_current_dialog()
	DialogManagement.start_dialog(dialog_data, npc_current)
	DialogManagement.connect_finished(self, "to_walking")

	velocity = Vector2.ZERO
	_play_animation(Vector2.ZERO)

func to_walking():
	
	if npc_current != null:
		npc_current._on_dialog_finished()
	if npc_current.quest != null:
		if npc_current.quest.try_progress(inventory):
			pending_quest_update = false
		else:
			pending_quest_update = npc_current.quest.state == QuestData.QuestState.NOT_STARTED


		print("Flag adicionada: ", GameState.flags)
	
	state = STATE.WALKING
	pending_quest_update = false
	npc_current = null

	can_interact_again = false
	await get_tree().create_timer(0.5).timeout
	can_interact_again = true

	refresh_dialog_icons() # <- Aqui


	


func process_walking():
	if dialogue_area != null and Input.is_action_just_pressed("ok") and can_interact_again:
		if dialogue_area.has_meta("dialog_valid"):
			audio_click.play()
			to_dialog()
		return
	var direction := Vector2.ZERO
	if Input.is_action_pressed("up"):
		direction.y -= 1
	if Input.is_action_pressed("down"):
		direction.y += 1
	if Input.is_action_pressed("right"):
		direction.x += 1
	if Input.is_action_pressed("left"):
		direction.x -= 1

	if direction != Vector2.ZERO:
		direction = direction.normalized()
		velocity = direction * speed_walking
	else:
		velocity = Vector2.ZERO

	move_and_slide()
	_play_animation(direction)

func _play_animation(direction: Vector2):
	if direction == Vector2.ZERO:
		anim_sprite.play("idle_" + last_direction)
		return

	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			anim_sprite.play("walk_right")
			last_direction = "right"
		else:
			anim_sprite.play("walk_left")
			last_direction = "left"
	else:
		if direction.y > 0:
			anim_sprite.play("walk_down")
			last_direction = "down"
		else:
			anim_sprite.play("walk_up")
			last_direction = "up"
			
func refresh_dialog_icons():
	if dialogue_area != null:
		var npc = dialogue_area.get_meta("quest_npc")
		if npc:
			if npc.has_node("DialogBaloon"):
				var baloon = npc.get_node("DialogBaloon")
				baloon.visible = true
				baloon.play("default")
			if npc.has_node("Interaction"):
				npc.get_node("Interaction").visible = false


func _physics_process(delta):
	
	if state == STATE.WALKING:
		process_walking()
	else:
		velocity = Vector2.ZERO
		_play_animation(Vector2.ZERO)

	# 🐞 Printar flags registradas (debug)
	if Input.is_action_just_pressed("debug_print_flags"):
		print("📋 FLAGS REGISTRADAS:")
		for flag in GameState.flags.keys():
			print("- ", flag, ": ", GameState.flags[flag])


func _on_dialogue_detect_area_entered(area: Area2D) -> void:
	if area.is_in_group("dialogue_area"):
		dialogue_area = area
		var npc = area.get_meta("quest_npc")
		if npc and npc.has_node("DialogBaloon"):
			var baloon = npc.get_node("DialogBaloon")
			baloon.visible = true
			npc.get_node("Interaction").visible = false
			baloon.play("default")

func _on_dialogue_detect_area_exited(area: Area2D) -> void:
	if area == dialogue_area:
		var npc = area.get_meta("quest_npc")
		if npc and npc.has_node("DialogBaloon"):
			var baloon = npc.get_node("DialogBaloon")
			baloon.visible = false
			npc.get_node("Interaction").visible = true
		dialogue_area = null
		
