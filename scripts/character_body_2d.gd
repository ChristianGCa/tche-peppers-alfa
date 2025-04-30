extends CharacterBody2D

@export var speed: float = 200.0

# Vamos assumir que você tem um AnimatedSprite2D chamado "AnimatedSprite2D"
@onready var anim_sprite = $AnimatedSprite2D

func _physics_process(delta):
	var input_vector = Vector2.ZERO

	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	input_vector = input_vector.normalized()

	velocity = input_vector * speed
	move_and_slide()

	_play_animation(input_vector)

func _play_animation(direction: Vector2):
	if direction == Vector2.ZERO:
		anim_sprite.play("idle")
		return

	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			anim_sprite.play("walk_right")
		else:
			anim_sprite.play("walk_left")
	else:
		if direction.y > 0:
			anim_sprite.play("walk_down")
		else:
			anim_sprite.play("walk_up")
