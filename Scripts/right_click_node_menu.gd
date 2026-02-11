extends Control

var is_menu_shown : bool
var accessed_by_rmb : bool
var accessed_by_drag : bool

var menu_bound_margin : Vector2 = Vector2(10,10)
var menu_top_left_bound : Vector2
var menu_bottom_right_bound : Vector2
var mouse_pos : Vector2

var drag_info : Array

@onready var parent_scene : Node = $".."

const nodes : Array = [["con_node","Conversation Node"],["d_node","Dialogue Node"]]
# get these values from main - 1st is the internal name, second is what's shown

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	is_menu_shown = false
	accessed_by_rmb = false
	accessed_by_drag = false
	
	for node_array : Array in nodes:
		var button : Button = Button.new()
		button.name = node_array[0]
		button.text = node_array[1]
		button.pressed.connect(_on_button_pressed.bind(button))
		$HBoxContainer/VBoxContainer.add_child(button)
		
	hide_menu()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("RightClick"):
		if !is_menu_shown:
			mouse_pos = get_local_mouse_position()
			# something fucky is happening here, I think
			accessed_by_rmb = true
			show_menu(mouse_pos)
		else:
			hide_menu()

func show_menu(position_offset : Vector2) -> void:
	position += position_offset
	show()
	is_menu_shown = true

func hide_menu() -> void:
	hide()
	is_menu_shown = false
		
func _on_button_pressed(button : Button) -> void:
	if accessed_by_rmb:
		parent_scene.create_node(button.name,mouse_pos)
		accessed_by_rmb = false
	elif accessed_by_drag:
		parent_scene.make_node_from_drag(drag_info[0],drag_info[1],drag_info[2])
		accessed_by_drag = false
	hide_menu()
