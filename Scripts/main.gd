extends Control

var con_node : Resource = load("res://Scenes/ConversationNode.tscn")
var node_index : int = 0

@onready var graph_edit : GraphEdit = $GraphEdit
@onready var graph_edit_path : NodePath = graph_edit.get_path()

@onready var inh_speaker_box : NodePath = "VBoxContainer/InheritSpeakerCheck"
@onready var sp_l_ed : NodePath = "VBoxContainer/HBoxContainer/SpeakerLineEdit"

@onready var conf : ConfirmationModal = $ConfirmationModal
@onready var right_click_menu : Control = $RightClickNodeMenu

func _on_button_pressed() -> void: 						
	create_node("con_node", get_viewport_rect().size / 5)			

func _on_graph_edit_connection_request(from_node: StringName, from_port: int, 
		to_node: StringName, to_port: int) -> void:
	graph_edit.connect_node(from_node, from_port, to_node, to_port)
														# connect them nodes
	speaker_inheritance_check(from_node, to_node)	

func speaker_inheritance_check(from_node : StringName, 
		to_node : StringName) -> void:
	if graph_edit.get_node(
		NodePath(from_node)).get_node(inh_speaker_box).button_pressed:
	# if the inherit speaker button is checked:
		var speaker_name : String = graph_edit.get_node(	
			NodePath(from_node)).get_node(sp_l_ed).text
				# get speaker name of initial node
		graph_edit.get_node(	
			NodePath(to_node)).get_node(sp_l_ed).text = speaker_name
				# set speaker name of connecting node to it
		graph_edit.get_node(	
			NodePath(to_node)).get_node(inh_speaker_box).button_pressed = true
				# set inherit speaker of next node to true too
				# the chain must grow
				
	# TODO: tidy this ^ up, remove repeated paths to the tickboxes and lineedits

func _on_graph_edit_disconnection_request(from_node: StringName, from_port: int, 
		to_node: StringName, to_port: int) -> void:
	graph_edit.disconnect_node(from_node, from_port, to_node, to_port)
														# disconnect them nodes				
func _on_graph_edit_connection_to_empty(from_node: StringName, from_port: int, 
			release_position: Vector2) -> void:
	var new_node : StringName = create_node("con_node", release_position + 
															Vector2(0,-75)).name
	graph_edit.connect_node(from_node, from_port, new_node, 0)
	speaker_inheritance_check(from_node, new_node)
	
# right_click_menu.show_menu(get_local_mouse_position())
#	right_click_menu.drag_info = [from_node, from_port, release_position]
#func make_node_from_drag(from_node: StringName, from_port: int, 
#		release_position: Vector2, node_type: String) -> void:

func create_node(node_type : String, position_offset : Vector2) -> Node:
	var node : Node 
	if node_type == "con_node":
		node = con_node.instantiate() 	
		node.name = "CN" + str(node_index)+"#"
		node_index += 1 									
		node.position_offset += graph_edit.scroll_offset + position_offset					
		node.title += " "+str(node_index)	
	graph_edit.add_child(node)
	return node

func _on_save_button_pressed() -> void:
	save_data("res://SaveData/DataSave.res")

func _on_load_button_pressed() -> void:
	var is_confirmed : bool = await conf.prompt(true)
	if is_confirmed:
		load_data("res://SaveData/DataSave.res")

func save_data(file_name: String) -> void:
	var graph_data : GraphData = GraphData.new()
#	graph_data.connections = graph_edit.get_connection_list()
	@warning_ignore("inferred_declaration")
	for node in graph_edit.get_children():
		if node is GraphNode:
			var node_data : NodeData = NodeData.new()
			node_data.name = node.name
			node_data.title = node.title
			node_data.position_offset = node.position_offset
			graph_data.nodes.append(node_data)
			# also save type of node
	graph_data.connections = graph_edit.connections
	if ResourceSaver.save(graph_data, file_name) == OK:
		print("saved")
	else:
		print("Error saving graph_data")
		
func init_graph(graph_data: GraphData) -> void:
	clear_graph()
	node_index = 0
	for node : Resource in graph_data.nodes:
		var gnode : Node = con_node.instantiate()
		# replace this with more versatile instantiation handling
		# multiple types of node
		gnode.position_offset = node.position_offset
		gnode.name = StringName(node.name)
		gnode.title = node.title
		graph_edit.add_child(gnode,true)
		node_index += 1
	for con : Dictionary in graph_data.connections:
		var _e : int = graph_edit.connect_node(con.from_node, 
		 	con.from_port, con.to_node, con.to_port, con.keep_alive)
		
func load_data(file_name: String) -> void:
	if ResourceLoader.exists(file_name):
		@warning_ignore("untyped_declaration")
		var graph_data = ResourceLoader.load(file_name)
		if graph_data is GraphData:
			init_graph(graph_data)
		else:
			# Error loading data
			pass
	else:
		# File not found
		pass
		
func clear_graph() -> void:
	graph_edit.clear_connections()
	var nodes : Array = graph_edit.get_children()
	for node : Node in nodes:
		if node is GraphNode:
			graph_edit.remove_child(node)
			node.queue_free()
	node_index = 0
