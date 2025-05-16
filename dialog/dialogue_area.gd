extends Area2D
var current_lines=null

func reset_lines():
	current_lines=null

func get_next_lines(idx):
	var lines=[]
	var line=null
	if current_lines==null:
		line=self
	else:
		idx = clamp(idx,0,len(current_lines)-1)
		line=current_lines[idx]
	for node in line.get_children():
		if node.is_in_group("dialogue_line"):
			lines.append(node)
	current_lines=lines
	return lines
	

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
