extends StaticBody2D

const TRANSPARENT_OPACITY := 0.4

var sprite: Sprite2D
var collision_shape: CollisionShape2D
var detection_area: Area2D
var detection_collision_shape: CollisionShape2D

func _ready():
	await get_tree().process_frame
	_setup_nodes()

func _setup_nodes():
	# Pega o Sprite2D (primeiro filho que for Sprite2D)
	sprite = get_node_or_null("Sprite2D")
	if not sprite:
		for child in get_children():
			if child is Sprite2D:
				sprite = child
				break

	# Pega o CollisionShape2D direto
	collision_shape = get_node_or_null("CollisionShape2D")

	# Pega a Área e seu CollisionShape2D
	detection_area = get_node_or_null("DetectionArea")
	if detection_area:
		detection_collision_shape = detection_area.get_node_or_null("CollisionShape2D")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player" and sprite:
		sprite.modulate.a = TRANSPARENT_OPACITY


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player" and sprite:
		sprite.modulate.a = 1.0
