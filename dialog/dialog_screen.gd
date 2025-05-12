extends Control
class_name DialogScreen

signal dialog_closed

var _step: float = 0.05
var _id: int = 0
var data: Dictionary = {}
var _showing_translation := false

@export_category("Objects")
@export var _name: Label = null
@export var _dialog: RichTextLabel = null
@export var _faceset: TextureRect = null
@export var _translate_button: Button = null


func _ready() -> void:
	_initialize_dialog()
	
func _process(_delta: float) -> void:
	if Input.is_action_pressed("ui_accept") and _dialog.visible_ratio < 1:
		_step = 0.01
		return
	
	_step = 0.05
	if Input.is_action_just_pressed("ui_accept"):
		_id += 1
		if _id == data.size():
			queue_free()
			emit_signal("dialog_closed")
			return
			
		_initialize_dialog()


func _initialize_dialog() -> void:
	_name.text = data[_id]["title"]
	_dialog.text = data[_id]["dialog"]
	_faceset.texture = load(data[_id]["faceset"])
	
	_dialog.visible_characters = 0
	while _dialog.visible_ratio < 1:
		await get_tree().create_timer(_step).timeout
		_dialog.visible_characters += 1
		pass





func _on_button_pressed() -> void:
	_showing_translation = !_showing_translation
	if _showing_translation:
		_dialog.text = data[_id]["traduction"]
		_translate_button.text = "Show original"
	else:
		_dialog.text = data[_id]["dialog"]
		_translate_button.text = "Mostrar tradução"
