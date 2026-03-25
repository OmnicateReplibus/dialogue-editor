@tool
extends GraphNode

@onready var class_dropdown : OptionButton = $MarginContainer/GridContainer/ClassDropdown
@onready var skill_dropdown : OptionButton = $MarginContainer/GridContainer/SkillDropdown
@onready var threshold : SpinBox = $MarginContainer/GridContainer/SpinBox
@onready var success_box : TextEdit = $MarginContainer/GridContainer/TextEdit
@onready var failure_box : TextEdit = $MarginContainer/GridContainer/TextEdit2

@onready var mar_cont : MarginContainer = $MarginContainer
	
var margin_top_value : int = 20
var margin_side_value : int = 0

var text_box_width : int = 500

var skill_class_array : Array = ["Persona","Emotion","Cognition","Chassis"]
var skill_dict : Dictionary = {
	"Persona":["Magnetism","Artifice","Tact"],
	"Emotion":["Piety","Empathy","Defiance"],
	"Cognition":["Three Churches","Natural Science","Insight"],
	"Chassis":["Arm","Fibre","Agility"]
}

func _ready() -> void:
	
	mar_cont.add_theme_constant_override("margin_top", margin_top_value)
	mar_cont.add_theme_constant_override("margin_bottom", margin_top_value)
	mar_cont.add_theme_constant_override("margin_left", margin_side_value)
	mar_cont.add_theme_constant_override("margin_right", margin_side_value)
	
	$MarginContainer/GridContainer/TextEdit.custom_minimum_size.x = text_box_width
	$MarginContainer/GridContainer/TextEdit2.custom_minimum_size.x = text_box_width
	
	set_slot(0,true,1,Color.AQUA,true,1,Color.RED)
	class_dropdown.clear()
	for i : String in skill_class_array:
		class_dropdown.add_item(i)
	_on_class_dropdown_item_selected(0)
		
func _on_class_dropdown_item_selected(index: int) -> void:
	skill_dropdown.clear()
	var op_arr : Array = skill_dict[str(skill_class_array[index])]
	for i : String in op_arr:
		skill_dropdown.add_item(i)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_DELETE && selected:
			_on_delete_request()

func _on_delete_request() -> void:
	queue_free()
