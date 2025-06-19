extends Node
class_name DialogManager

var dialog_box_scene := preload("res://HUD/DialogueSystem/dialog_box.tscn")
var dialog_box_instance: Node = null

func _ready():
	dialog_box_instance = dialog_box_scene.instantiate()
	get_tree().get_root().call_deferred("add_child", dialog_box_instance)
	dialog_box_instance.hide()

func start_dialog(dialog: DialogData, speaker_owner: NPC):
	dialog_box_instance.start(dialog, speaker_owner)

func connect_finished(target: Object, method_name: String):
	var callback := Callable(target, method_name)
	if dialog_box_instance.dialog_finished.is_connected(callback):
		dialog_box_instance.dialog_finished.disconnect(callback)
	dialog_box_instance.dialog_finished.connect(callback)
