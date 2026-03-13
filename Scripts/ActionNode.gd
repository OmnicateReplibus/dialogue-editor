extends GraphNode

@onready var condition_box : LineEdit = $LineEdit

func _ready() -> void:
	set_slot(0,true,1,Color.AQUA,true,1,Color.BLACK)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Delete") && selected:
		_on_delete_request()

func _on_delete_request() -> void:
	queue_free()
