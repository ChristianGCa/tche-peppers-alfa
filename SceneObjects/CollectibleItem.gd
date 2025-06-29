extends Area2D

@export var item_name: String
@export var related_quest: QuestData

@onready var prompt := $AnimatedSprite2D
@onready var audio_pickup = $AudioStreamPlayer2D

var player_near := false
var has_been_activated := false

func _ready():
	visible = false
	prompt.visible = false

	if related_quest:
		related_quest.quest_state_changed.connect(_on_quest_state_changed)
		if related_quest.state == QuestData.QuestState.IN_PROGRESS:
			visible = true

func _on_quest_state_changed(new_state):
	if new_state == QuestData.QuestState.IN_PROGRESS:
		visible = true

func _process(delta):
	if not has_been_activated and related_quest and related_quest.state == QuestData.QuestState.IN_PROGRESS:
		visible = true
		has_been_activated = true

	if player_near and Input.is_action_just_pressed("ok"):
		var player = get_tree().get_first_node_in_group("player")
		if player and item_name != "":
			audio_pickup.play()
			player.inventory.append(item_name)
			queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_near = true
		prompt.visible = true
		prompt.play("default")

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_near = false
		prompt.visible = false
		prompt.stop()
