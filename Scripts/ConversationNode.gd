extends GraphNode

var opsubnode : PackedScene = preload("res://Scenes/OptionSubNode.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_slot(0,true,1,Color.AQUA,true,1,Color.BLACK)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Delete") && selected:
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
		set_slot(0,true,1,Color.AQUA,false,1,Color.BLACK)
	var opsubnode_inst : PanelContainer = opsubnode.instantiate()
	add_child(opsubnode_inst)
	var slot_num : int = get_child_count()-1
	set_slot(slot_num,false,1,Color.AQUA,true,1,Color.BLACK)
	
func remove_choice() -> void:
	var target_child : PanelContainer = get_child(-1)
	clear_slot(get_child_count()-1)
	target_child.queue_free()
	if get_child_count() == 2:
		# don't love this but it's because queue_free doesn't remove the final choice box
		# from the child list in time (if at all)
		set_slot(0,true,1,Color.AQUA,true,1,Color.BLACK)

func _on_slot_updated(slot_index: int) -> void:
	print(slot_index)
