extends CharacterBody2D

@export var speed_running: float = 200.0
@export var speed_walking: float = 80.0
@onready var dialog_panel = $"../../HUD/dialogue_panel"
@onready var anim_sprite = $AnimatedSprite2D

enum STATE { WALKING, DIALOG }

var state = STATE.WALKING
var last_direction := "down"
var can_move = true
var dialogue_area = null

func to_dialog():
	state = STATE.DIALOG
	dialog_panel.visible = true
	dialogue_area = dialogue_area.get_node("..").verifica_quest(self)
	dialogue_area.reset_lines()
	var linhas = dialogue_area.get_next_lines(0)
	dialog_panel.set_lines(linhas)

func process_dialogue():
	var res = dialog_panel.process_dialogue("up", "down", "ok", dialogue_area)
	if res == false:
		to_walking()

func to_walking():
	state = STATE.WALKING

func process_walking():
	if dialogue_area != null and Input.is_action_just_pressed("ok"):
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

func _physics_process(delta):
	if state == STATE.WALKING:
		process_walking()
	elif state == STATE.DIALOG:
		process_dialogue()

func _on_dialog_detect_area_entered(area: Area2D) -> void:
	if area.is_in_group("dialogue_area"):
		dialogue_area = area

func _on_dialog_detect_area_exited(area: Area2D) -> void:
	if area == dialogue_area:
		dialogue_area = null
