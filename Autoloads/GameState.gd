extends Node

# As variáveis globais devem vir depois do class_name
var flags := {}

var player_name: String = "Você"
var player_portrait: Texture = preload("res://Assets/Characters/Portraits/player.png")  # substitua pelo caminho correto

func set_flag(key: String, value: bool = true) -> void:
	flags[key] = value

func get_flag(key: String) -> bool:
	return flags.get(key, false)
