extends Node2D

@export var max_speed := 300.0
@export var acceleration := 500.0
@export var wait_time := 1.0
@export var drive_direction := Vector2.RIGHT  # Use Vector2.LEFT ou Vector2.RIGHT

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
@onready var accelerating_audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

@export var flag_required_to_not_spawn: String = ""  # Ex: "taxi_cena1_concluido"

var moving := false
var current_speed := 0.0

func _ready():
	if flag_required_to_not_spawn != "" and GameState.get_flag(flag_required_to_not_spawn):
		print("🚕 Táxi removido: flag já registrada:", flag_required_to_not_spawn)
		queue_free()
		return
	if drive_direction.x < 0:
		sprite.play("stop_left")
	else:
		sprite.play("stop_right")

	timer.wait_time = wait_time
	timer.start()


func _process(delta):
	if moving:
		# Toca a animação de direção correta
		if drive_direction.x < 0:
			sprite.play("drive_left")
		else:
			sprite.play("drive_right")

		# Aceleração progressiva
		current_speed = min(current_speed + acceleration * delta, max_speed)
		position += drive_direction.normalized() * current_speed * delta

		# Quando sair da tela, remove
		if not get_viewport_rect().grow(100).has_point(position):
			queue_free()

func _on_timer_timeout() -> void:
	moving = true
	accelerating_audio.play()
