extends Panel

var dialogue_item_comp=preload("res://dialog/dialogue_item.tscn")
@export var color_selected=Color.DARK_SLATE_GRAY
@export var blink_freq=1.0
var color_unselected=Color(0,0,0,0)
var idx_selected=0
var t=0.0
@onready var items_vbox = $hbox/margin_items/vbox/vbox

func process_dialogue(action_up,action_down,action_ok,dialogue_area):
	if Input.is_action_just_pressed(action_up):
		select_previous()
	if Input.is_action_just_pressed(action_down):
		select_next()	
	if Input.is_action_just_pressed(action_ok):
		var lines=dialogue_area.get_next_lines(idx_selected)		
		if len(lines)==0:
			visible=false
			return false
		else:
			set_lines(lines)
			visible=true
			return true
	visible=true
	return true;
		


func set_lines(lines):
	for item in items_vbox.get_children():
		item.queue_free()
	for line in lines:
		add_dialogue_item(line)	
	idx_selected=0
	$hbox/margin_pic/picture.texture=lines[0].picture
	$hbox/margin_items/vbox/label_name.text=lines[0].char_name
	

func add_dialogue_item(line):
	var dialogue_item=dialogue_item_comp.instantiate()
	dialogue_item.set_dialogue_line(line)
	items_vbox.add_child(dialogue_item)
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	idx_selected=1
	pass # Replace with function body.

func select_next():
	var items=items_vbox.get_children()
	idx_selected=min(idx_selected+1,len(items)-1)
	$hbox/margin_pic/picture.texture=items[idx_selected].dialogue_line.picture
	$hbox/margin_items/vbox/label_name.text=items[idx_selected].dialogue_line.char_name
func select_previous():
	var items=items_vbox.get_children()
	idx_selected=max(idx_selected-1,0)
	$hbox/margin_pic/picture.texture=items[idx_selected].dialogue_line.picture
	$hbox/margin_items/vbox/label_name.text=items[idx_selected].dialogue_line.char_name
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var items=items_vbox.get_children()
			
	t+=delta
	var i=0
	for item in items:
		if i==idx_selected and len(items)>1:
			item.color=color_selected
			item.color.a=sin(t*2*PI*blink_freq)*0.2+0.8
		else:
			item.color=color_unselected
		i+=1
