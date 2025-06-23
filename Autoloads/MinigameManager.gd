extends Node

var minigame_scene = preload("res://Minigame/minigame.tscn")

func start_minigame(json_path: String, callback_target: Object, callback_method: String):
	var file = FileAccess.open(json_path, FileAccess.READ)
	if file == null:
		push_error("Erro ao abrir JSON: " + json_path)
		return

	var content = file.get_as_text()
	var data = JSON.parse_string(content)
	if typeof(data) != TYPE_DICTIONARY:
		push_error("Erro ao parsear JSON")
		return

	var minigame = minigame_scene.instantiate()
	get_tree().get_root().add_child(minigame)
	minigame.set_data_from_dict(data)
	minigame.finished.connect(Callable(callback_target, callback_method))
