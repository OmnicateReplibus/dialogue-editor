@tool
extends GraphNode

@onready var condition_box : LineEdit = $LineEdit

func _ready() -> void:
	set_slot(0,true,1,Color.AQUA,false,1,Color.RED)
	set_slot(1,false,1,Color.AQUA,true,1,Color.RED)
	set_slot(2,false,1,Color.AQUA,true,1,Color.RED)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_DELETE && selected:
			_on_delete_request()

func _on_delete_request() -> void:
	queue_free()
