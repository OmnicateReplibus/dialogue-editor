extends GraphNode

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#name = "SGN" + str(get_parent().get_parent().node_index)+"#"
	set_slot(0, true, 0, Color(1,1,1), true, 0, Color(0,1,0))
		# slot management

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
