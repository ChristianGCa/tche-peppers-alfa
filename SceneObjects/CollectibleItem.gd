extends Area2D

@export var item_name: String

func _on_body_entered(body):
	if body.name == "Player":
		if item_name != "":
			body.inventory.append(item_name)
			queue_free()
