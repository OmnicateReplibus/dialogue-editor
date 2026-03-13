extends Control

# TODO: Add in export functionality, to format graphs into json files.
# TODO: Set up saving of logic nodes, and make the condition transfer
# 		from the origin node

var con_node : Resource = load("res://Scenes/ConversationNode.tscn")
var con_node_op : Resource = load("res://Scenes/OptionSubNode.tscn")
var act_node : Resource = load("res://Scenes/ActionNode.tscn")
var log_node : Resource = load("res://Scenes/LogicNode.tscn")

# this ensures there are never any node-naming conflicts
# by giving each node a unique identifier
# and yes, this does mean some identifiers will be skipped if nodes are removed
# we have to save this to avoid conflicts
var node_index : int = 0

# this one's just the total number of nodes in the graph
# idk if it'll be needed
var total_nodes : int = 0

# the offset for nodes appearing at the cursor
# should be roughly half the height of the node (without any op_subs)
var con_node_offset : Vector2 = Vector2(0,-110)
var act_node_offset : Vector2 = Vector2(0,-40)
var log_node_offset : Vector2 = Vector2(0,-40)

@onready var graph_edit : GraphEdit = $GraphEdit
@onready var graph_edit_path : NodePath = graph_edit.get_path()

# for speaker inheritance check
@onready var inh_speaker_box : NodePath = "VBoxContainer/InheritSpeakerCheck"
@onready var sp_l_ed : NodePath = "VBoxContainer/HBoxContainer/SpeakerLineEdit"

# modals
@onready var new_file_modal : Control = $NewFileModal
@onready var right_click_menu : Control = $RightClickNodeMenu

@onready var file_menu : PopupMenu = $MenuBar/FileMenu
@onready var file_menu_options : Array = ["New","Save","Save As",
										 "Load","Export"]

@onready var save_as_modal : FileDialog = $SaveAs
@onready var load_modal : FileDialog = $Load
@onready var default_path : String = "res://SaveData/"
@onready var current_save_path : String = ""

func _ready() -> void:
	save_as_modal.current_dir = default_path
	load_modal.current_dir = default_path
	for i : String in file_menu_options:
		file_menu.add_item(i)
		
func _input(event: InputEvent) -> void:
	if event.is_action("SaveShortcut", true):
		general_case_save()

func _on_add_con_button_pressed() -> void: 						
	var new_con_node : Node = create_node("con_node", 
		get_viewport_rect().size / 2)
	new_con_node.remove_connections.connect(
		remove_connections.bind(new_con_node))
	
func _on_add_act_node_pressed() -> void:
	create_node("act_node", get_viewport_rect().size / 2)
	
func _on_add_log_node_pressed() -> void:
	create_node("log_node", get_viewport_rect().size / 2)

func remove_connections(node : GraphNode) -> void:
	if node.get_child_count() > 2:
		var connection_list : Array = graph_edit.get_connection_list_from_node(
																	node.name)
		var removed_slot_index : int = node.get_output_port_count()-1
		for dict : Dictionary in connection_list:
			if dict["from_port"] == removed_slot_index:
				graph_edit.disconnect_node(dict["from_node"],dict["from_port"],
											dict["to_node"],dict["to_port"])

func _on_graph_edit_connection_request(from_node: StringName, from_port: int, 
		to_node: StringName, to_port: int) -> void:
	graph_edit.connect_node(from_node, from_port, to_node, to_port)
														# connect them nodes=
	speaker_inheritance_check(from_node, to_node)

func speaker_inheritance_check(from_node : StringName, 
		to_node : StringName) -> void:
	if from_node.left(1) == "C":
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
				NodePath(to_node)).get_node(
					inh_speaker_box).button_pressed = true
					# set inherit speaker of next node to true too
					# the chain must grow

func _on_graph_edit_disconnection_request(from_node: StringName, from_port: int, 
		to_node: StringName, to_port: int) -> void:
	graph_edit.disconnect_node(from_node, from_port, to_node, to_port)
													# disconnect them nodes
func _on_graph_edit_connection_to_empty(from_node: StringName, from_port: int, 
			release_position: Vector2) -> void:
	var new_node : StringName
	var new_node_type : StringName
	var origin : Node = graph_edit.find_child(
				from_node,true,false)
	if origin.title == "ConversationNode" && origin.get_children().size() > 1: 
		if origin.get_child(from_port+1).replace_check_box.toggle_mode:
			new_node_type = "log_node"
		else:
			new_node_type = "con_node"
	else:
		new_node_type = "con_node"
	new_node = create_node(new_node_type, release_position).name
	graph_edit.connect_node(from_node, from_port, new_node, 0)
	speaker_inheritance_check(from_node, new_node)
	

func create_node(node_type : String, position_offset : Vector2) -> Node:
	var node : Node 
	if node_type == "con_node":
		node = con_node.instantiate() 	
		node.name = "CN" + str(node_index)								
		node.position_offset += ((graph_edit.scroll_offset + position_offset
			) / graph_edit.zoom) + con_node_offset
	elif node_type == "act_node":
		node = act_node.instantiate()
		node.name = "AN" + str(node_index)	
		node.position_offset += ((graph_edit.scroll_offset + position_offset
			) / graph_edit.zoom) + act_node_offset
	elif node_type == "log_node":
		node = log_node.instantiate()
		node.name = "LN" + str(node_index)	
		node.position_offset += ((graph_edit.scroll_offset + position_offset
			) / graph_edit.zoom) + act_node_offset
	node_index += 1 
	graph_edit.add_child(node)
	total_nodes += 1
	return node
	

func _on_graph_edit_delete_nodes_request(nodes: Array[StringName]) -> void:
	total_nodes -= len(nodes)
	

# SAVING, LOADING & EXPORTING #

# MENU

func _on_file_menu_id_pressed(id: int) -> void:
	if id == 0:
		# New
		var bhvr : int = await new_file_modal.prompt(true)
		if bhvr == 0:
			general_case_save()
		if bhvr in [0,1]:
			clear_graph()
			current_save_path = ""
	elif id == 1:
		# Save
		general_case_save()
	elif id == 2:
		# Save As
		save_as_modal.show()
	elif id == 3:
		# Load
		load_modal.show()
	elif id == 4:
		export()
		
func general_case_save() -> void:
	if current_save_path == "":
		save_as_modal.show()
	else:
		save_data(current_save_path)
			
func _on_save_as_file_selected(path: String) -> void:
	if path.right(4) != ".res":
		path += ".res"
	if save_data(path):
		current_save_path = path
		save_as_modal.hide()
		
func _on_load_file_selected(path: String) -> void:
	if load_data(path):
		current_save_path = path
		load_modal.hide()

# SAVE

func save_data(file_name: String) -> bool:
	var graph_data : GraphData = GraphData.new()
	@warning_ignore("inferred_declaration")
	for node in graph_edit.get_children():
		if node is GraphNode:
			var node_data : NodeData = read_node_data(node)
			graph_data.nodes.append(node_data)
	graph_data.connections = graph_edit.connections
	graph_data.node_index = node_index
	if ResourceSaver.save(graph_data, file_name) == OK:
		print("Graph saved successfully")
		return true
	else:
		push_error("Error saving graph_data")
		return false
		
func read_node_data(node : Node) -> NodeData:
	var node_data : NodeData = NodeData.new()
	node_data.name = node.name
	node_data.title = node.titlez
	node_data.position_offset = node.position_offset
	if node_data.name == "ConversationNode":
		var choice_data : Array = []
		node_data.speaker = node.speaker_line_edit.text
		node_data.inherit_speaker = node.inherit_speaker_check.button_pressed
		node_data.speaker_text = node.node_text.text
		for i : Node in node.get_children():
			if i is PanelContainer:
				choice_data.append(read_choice_data(i))
		node_data.choices = choice_data
	elif node_data.name == "ActionNode":
		node_data.action_string = node.condition_box.text
	
	return node_data

func read_choice_data(osn : PanelContainer) -> Dictionary:
	# osn = option_sub_node
	return {"choice_text_box": osn.choice_text_box.text, 
			"condition_check_box": osn.condition_check_box.button_pressed,
			"condition_text_box": osn.condition_text_box.text, 
			"hide_check_box": osn.hide_check_box.button_pressed, 
			"replace_check_box": osn.replace_check_box.button_pressed, 
			"replace_text_box": osn.replace_text_box.text}

func clear_graph() -> void:
	graph_edit.clear_connections()
	var nodes : Array = graph_edit.get_children()
	for node : Node in nodes:
		if node is GraphNode:
			graph_edit.remove_child(node)
			node.queue_free()
	node_index = 0
	total_nodes = 0
	graph_edit.scroll_offset = Vector2(0,0)

# LOAD

func load_data(file_name: String) -> bool:
	if ResourceLoader.exists(file_name):
		@warning_ignore("untyped_declaration")
		var graph_data = ResourceLoader.load(file_name)
		if graph_data is GraphData:
			init_graph(graph_data)
			return true
		else:
			push_error("Error loading data")
			return false
	else:
		push_warning("File not found")
		return false

func init_graph(graph_data: GraphData) -> void:								 # okay
																			 # are you ready for the pain?
	
	clear_graph()															 # first we reset the graph and make sure no nodes are retained
	node_index = graph_data.node_index
	
	for node : Resource in graph_data.nodes: 									 # then we check the save for each saved node...
		var gnode : Node 
		if node.title == "ConversationNode":
			gnode = con_node.instantiate()								 	 # ...and instance a new node for each one, which we will fill with data
			gnode.remove_connections.connect(remove_connections.bind(gnode))	 # don't forget to hook it up to the signal!
		elif node.title == "ActionNode":
			gnode = act_node.instantiate()
		
		gnode.position_offset = node.position_offset							 # we begin with the basic stuff....
		gnode.name = StringName(node.name)
		gnode.title = node.title
		
		if node.title == "ConversationNode":									 # and then we get to the choices
			var choice_data_array : Array = node.choices						 # which we grab from the save...
			for i : int in len(choice_data_array):							 # ...then make a fresh option subnode for each...
				var op_node : Node = con_node_op.instantiate()
				gnode.add_child(op_node)											 

			graph_edit.add_child(gnode,true)									 # ...and add the node to the graph.
																			 # we need to do this before we fill in the choice data
																			 # because of the @onready variables in option_sub_node;
																			 # we can't assign them until the node has been instanced
			gnode.speaker_line_edit.text = node.speaker 						 # this goes for all this stuff too
			gnode.inherit_speaker_check.button_pressed = node.inherit_speaker
			gnode.node_text.text = node.speaker_text								
			
																			 # *now* we pour in the choice data for each one
			var k : int = 0													 # using k to track which choice we're on
			for i : Node in gnode.get_children():
				if i is PanelContainer:
					write_choice_data(i,choice_data_array[k])
					gnode.set_slot(k+1,false,1,Color.AQUA,true,1,Color.BLACK)
					k += 1
			if k != 0:
				gnode.set_slot(0,true,1,Color.AQUA,false,1,Color.BLACK)
			else:
				gnode.set_slot(0,true,1,Color.AQUA,true,1,Color.BLACK)
		
		elif node.title == "ActionNode":										 # the action nodes are comparatively much simpler
			gnode.condition_box.text = node.action_string
			graph_edit.add_child(gnode,true)
		total_nodes += 1
																			 # and that's the nodes set up
																			 # all that's left is to hook everything up again!
	for con : Dictionary in graph_data.connections:
		var _e : int = graph_edit.connect_node(con.from_node, 
		 	con.from_port, con.to_node, con.to_port, con.keep_alive)

func write_choice_data(osn : PanelContainer, data : Dictionary) -> void:
	# osn = option_sub_node
	osn.choice_text_box.text = data["choice_text_box"]
	osn.condition_check_box.button_pressed = data["condition_check_box"]
	osn.condition_text_box.text = data["condition_text_box"] 
	osn.hide_check_box.button_pressed = data["hide_check_box"] 
	osn.replace_check_box.button_pressed = data["replace_check_box"] 
	osn.replace_text_box.text = data["replace_text_box"]

# EXPORT

func export() -> void:
	var nodes : Array = graph_edit.get_children()
	for node : Node in nodes:
		if node is GraphNode:
			var node_json : Dictionary = {}
			if node.title == "ConversationNode":
				node_json["speaker"] = node.speaker_line_edit.text
				node_json["text"] = node.node_text.text
				for i : Node in node.get_children():
					if i is PanelContainer:
						var choice_dict_raw : Dictionary = read_choice_data(i)
						var choice_dict : Dictionary = {}
						choice_dict["text"] = choice_dict_raw[
														 "choice_text_box"]
						if choice_dict_raw["condition_check_box"]:
							choice_dict["condition"] = choice_dict_raw[
														 "condition_text_box"]
							choice_dict["hide"] = choice_dict_raw[
														 "hide_check_box"]
							if choice_dict_raw["replace_check_box"]:
								choice_dict["replace_with"] = choice_dict_raw[
														 "replace_text_box"]
						print(choice_dict_raw)
			print(node_json)
