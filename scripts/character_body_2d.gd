extends CharacterBody2D

@export var speed: float = 200.0

@onready var anim_sprite = $AnimatedSprite2D

var last_direction := "down"

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
