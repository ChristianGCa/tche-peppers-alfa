extends Panel

var dialogue_item_comp=preload("res://dialog/dialogue_item.tscn")
@export var color_selected=Color.DARK_SLATE_GRAY
@export var blink_freq=1.0
var color_unselected=Color(0,0,0,0)
var idx_selected=0
var t=0.0
var player : Node = null
var dialogue_area


@onready var items_vbox = $hbox/margin_items/vbox/vbox
@onready var button_next = $hbox/margin_items/vbox/ButtonNext


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
	var items = items_vbox.get_children()
	if not items[idx_selected].answered_correctly:
		print("Responda corretamente antes de continuar.")
		return

	idx_selected = min(idx_selected + 1, len(items) - 1)
	$hbox/margin_pic/picture.texture = items[idx_selected].dialogue_line.picture
	$hbox/margin_items/vbox/label_name.text = items[idx_selected].dialogue_line.char_name

func select_previous():
	var items = items_vbox.get_children()
	if not items[idx_selected].answered_correctly:
		print("Responda corretamente antes de voltar.")
		return

	idx_selected = max(idx_selected - 1, 0)
	$hbox/margin_pic/picture.texture = items[idx_selected].dialogue_line.picture
	$hbox/margin_items/vbox/label_name.text = items[idx_selected].dialogue_line.char_name

func get_selected_item():
	var items = items_vbox.get_children()
	if idx_selected >= 0 and idx_selected < items.size():
		return items[idx_selected]
	return null

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

func start_dialogue(p, area, lines):
	player = p
	dialogue_area = area
	set_lines(lines)
	visible = true

func _on_button_next_pressed():
	var current_item = get_selected_item()
	if current_item and not current_item.answered_correctly:
		$"../NotificationPanel".show_message("Selecione a palavra correta")
		return

	var lines = dialogue_area.get_next_lines(idx_selected)
	if lines.size() == 0:
		dialogue_area.reset_lines()
		visible = false
		player.state = player.STATE.WALKING
	else:
		set_lines(lines)
