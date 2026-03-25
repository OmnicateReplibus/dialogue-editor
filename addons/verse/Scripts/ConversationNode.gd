@tool
extends GraphNode

signal remove_connections

var opsubnode : PackedScene = preload("res://addons/verse/Scenes/Nodes/OptionSubNode.tscn")

# all the components needed to be accessed when saving
@onready var speaker_line_edit : Node = $VBoxContainer/HBoxContainer/SpeakerLineEdit
@onready var inherit_speaker_check : Node = $VBoxContainer/InheritSpeakerCheck
@onready var node_text : Node = $VBoxContainer/TextEdit

func _ready() -> void:
	set_slot(0,true,1,Color.AQUA,true,1,Color.RED)
	
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_DELETE && selected:
			_on_delete_request()

func _on_delete_request() -> void:
	queue_free()

func _on_resize_request(new_size: Vector2) -> void:
	size = new_size

func _on_add_choice_pressed() -> void:
	add_choice()

func _on_remove_choice_pressed() -> void:
	remove_choice()
		
func add_choice() -> void:
	if get_child_count() == 1:
		set_slot(0,true,1,Color.AQUA,false,1,Color.RED)
	var opsubnode_inst : PanelContainer = opsubnode.instantiate()
	add_child(opsubnode_inst)
	var slot_num : int = get_child_count()-1
	set_slot(slot_num,false,1,Color.AQUA,true,1,Color.RED)
		
func remove_choice() -> void:
	var target_child : PanelContainer 
	if get_child(-1) is PanelContainer:
		target_child = get_child(-1)
		remove_connections.emit()
		# this stops the weird connection issues caused by removing a slot
		# with an active connection to it
		# see the similarly named method in main
		clear_slot(get_child_count()-1)
		target_child.queue_free()
		if get_child_count() == 2:
			# don't love this but it's because queue_free doesn't remove the 
			# final choice box from the child list in time (if at all)
			set_slot(0,true,1,Color.AQUA,true,1,Color.RED)
