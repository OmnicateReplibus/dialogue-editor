@tool
extends GraphNode

func _ready() -> void:
	set_slot(0,true,1,Color.AQUA,false,1,Color.RED)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_DELETE && selected:
			_on_delete_request()

func _on_delete_request() -> void:
	queue_free()
