extends Node2D

const SAVE_PATH = "user://progress.save"

@onready var catedral_button = $catedralButton
@onready var catedral_lock = $catedralButton/cadeado
@onready var base_button = $baseAereaButton
@onready var base_lock = $baseAereaButton/cadeado

var progress = {
	"planetario": true,
	"catedral": false,
	"base_aerea": false
}

func _ready():
	load_progress()
	update_buttons()

func start_level(scene_path):
	get_tree().change_scene_to_file(scene_path)

func update_buttons():
	catedral_button.disabled = not progress["catedral"]
	catedral_lock.visible = not progress["catedral"]

	base_button.disabled = not progress["base_aerea"]
	base_lock.visible = not progress["base_aerea"]

func save_progress():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_var(progress)

func load_progress():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		progress = file.get_var()

func _on_planetario_button_pressed():
	start_level("res://Levels/planetario.tscn")

func _on_catedral_button_pressed():
	start_level("res://Levels/catedral.tscn")

func _on_base_aerea_button_pressed() -> void:
	start_level("res://Levels/BaseAerea.tscn")
