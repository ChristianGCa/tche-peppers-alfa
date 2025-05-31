extends CanvasLayer

var player_money: int = 100

@export var texture_action: Texture
@export var texture_up: Texture
@export var texture_down: Texture
@export var texture_left: Texture
@export var texture_right: Texture


@onready var money_display: Label = $MoneyDisplay
@onready var action_button: TextureButton = $ActionButton
@onready var btn_up = $MovementButtons/BtnUp
@onready var btn_down = $MovementButtons/BtnDown
@onready var btn_left = $MovementButtons/BtnLeft
@onready var btn_right = $MovementButtons/BtnRight

signal action_pressed
signal move_input(direction: Vector2)

func _ready():
	update_money()
	action_button.pressed.connect(_on_action_pressed)
	btn_up.pressed.connect(func(): emit_signal("move_input", Vector2(0, -1)))
	btn_down.pressed.connect(func(): emit_signal("move_input", Vector2(0, 1)))
	btn_left.pressed.connect(func(): emit_signal("move_input", Vector2(-1, 0)))
	btn_right.pressed.connect(func(): emit_signal("move_input", Vector2(1, 0)))

func update_money():
	money_display.text = "Pila $ " + str(player_money)

func _on_action_pressed():
	emit_signal("action_pressed")

func add_money(amount: int):
	player_money += amount
	update_money()

func subtract_money(amount: int):
	player_money -= amount
	update_money()
