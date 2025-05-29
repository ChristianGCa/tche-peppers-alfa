extends Node2D

signal interacted

@export var prompt_text: String = "Interagir (E)"
@onready var label = $Node2D/Label
@onready var visual = $Node2D

var is_player_inside := false
var player_ref := Node

func _ready():
	visual.visible = false
	label.text = prompt_text

func _process(_delta):
	if is_player_inside and Input.is_action_just_pressed("ok"):
		emit_signal("interacted")

func _on_body_entered(body):
	if body.name == "Player":
		is_player_inside = true
		player_ref = body
		visual.visible = true

func _on_body_exited(body):
	if body.name == "Player":
		is_player_inside = false
		player_ref = null
		visual.visible = false
