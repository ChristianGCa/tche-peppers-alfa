extends Node

var flags := {}
var is_full_completed = false

var player_name: String = "Você"
var player_portrait: Texture = preload("res://Assets/Characters/Portraits/player.png") # substitua pelo caminho correto

signal level_marked_complete(completed_level_id: String)

func set_flag(key: String, value: bool = true) -> void:
	flags[key] = value

func get_flag(key: String) -> bool:
	return flags.get(key, false)
