extends CanvasLayer

@onready var speaker_label = $Panel/HBoxContainer/MarginContainer2/VBoxContainer/SpeakerLabel
@onready var text_label = $Panel/HBoxContainer/MarginContainer2/VBoxContainer/TextLabel
@onready var portrait = $Panel/HBoxContainer/MarginContainer/Portrait

var dialog_data: DialogData
var current_index := 0
var is_typing := false
var type_speed := 0.03

signal dialog_finished

func start(dialog: DialogData):
	if dialog == null:
		push_error("DialogData está nulo! Verifique se o NPC tem o recurso atribuído.")
		hide()
		return
	dialog_data = dialog
	current_index = 0
	show()
	show_line()


func show_line():
	if current_index >= dialog_data.lines.size():
		hide()
		emit_signal("dialog_finished")
		return


	var line = dialog_data.lines[current_index]
	speaker_label.text = line.speaker_name
	text_label.text = ""
	portrait.texture = line.portrait
	type_text(line.text)

func type_text(text: String):
	is_typing = true
	text_label.clear()
	await get_tree().process_frame
	for char in text:
		text_label.append_text(char)
		await get_tree().create_timer(type_speed).timeout
	is_typing = false

func _unhandled_input(event):
	if !visible: return
	if event.is_action_pressed("ok"):
		if is_typing:
			text_label.text = dialog_data.lines[current_index].text
			is_typing = false
		else:
			current_index += 1
			show_line()
