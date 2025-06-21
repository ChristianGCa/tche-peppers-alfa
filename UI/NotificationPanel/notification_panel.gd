extends Control

@export var display_time := 2.0
@export var fade_time := 0.3
@onready var label := $Center/MarginContainer/MarginContainer/Text

var is_showing := false

func show_message(text: String):
	if is_showing:
		return

	is_showing = true
	label.text = text
	visible = true
	modulate.a = 0.0

	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_time)
	await tween.finished

	await get_tree().create_timer(display_time - 2 * fade_time).timeout

	tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_time)
	await tween.finished

	visible = false
	is_showing = false
	print("Mostrou mensagem")
