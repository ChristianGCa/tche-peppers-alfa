extends Node2D

var level_atual = null

func unload_level(level):
	level.queue_free()

func load_level(level):
	var level_scene = load(level)
	level_atual = level_scene.instantiate()
	add_child(level_atual)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_level("res://scenes/planetario.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
