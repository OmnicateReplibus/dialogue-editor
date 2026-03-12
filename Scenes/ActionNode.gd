extends GraphNode

@onready var condition_box : LineEdit = $LineEdit

func _ready() -> void:
	set_slot(0,true,1,Color.AQUA,true,1,Color.BLACK)
