extends CharacterBody2D

@export var speed_running: float = 200.0
@export var speed_walking: float = 80.0

@onready var anim_sprite = $AnimatedSprite2D

var last_direction := "down"
var can_move = true

func _physics_process(delta):
	
	if not can_move:
		return
	var input_vector = Vector2.ZERO

	# Verificando as entradas de direção
	input_vector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_vector.y = Input.get_action_strength("down") - Input.get_action_strength("up")

	input_vector = input_vector.normalized()

	# Alterando a velocidade dependendo se o shift está pressionado
	if Input.is_key_pressed(KEY_SHIFT):
		velocity = input_vector * speed_running
	else:
		velocity = input_vector * speed_walking
		
	move_and_slide()

	_play_animation(input_vector)

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
