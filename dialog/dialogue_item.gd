extends ColorRect
var dialogue_line=null

func set_dialogue_line(d_line):
	dialogue_line=d_line
	$margin/richlabel.text=d_line.text
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
