@tool
class_name ConfirmationModal extends Control

signal confirmed(option : int)

@onready var yes_button: Button = %YesButton
@onready var no_button: Button = %NoButton
@onready var cancel_button: Button = %CancelButton

var is_open : bool = false
var _should_unpause : bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process_unhandled_key_input(false)
	if yes_button:
		yes_button.pressed.connect(_on_yes_button_pressed)
	if no_button:
		no_button.pressed.connect(_on_no_button_pressed)
	if cancel_button:
		cancel_button.pressed.connect(_on_cancel_button_pressed)
	hide()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		cancel()
		
func prompt(pause : bool = false) -> int:
	_should_unpause = (get_tree().paused == false) and pause
	if pause:
		get_tree().paused = true
	show()
	is_open = true
	set_process_unhandled_key_input(true)
	var confirmed_option : int = await confirmed
	return confirmed_option
		
func yes() -> void:
	_close_modal(0)
	
func no() -> void:
	_close_modal(1)
	
func cancel() -> void:
	_close_modal(2)
		
func _close_modal(option : int) -> void:
	set_process_unhandled_key_input(false)
	confirmed.emit(option)
	set_deferred("is_open", false)
	hide()
	if _should_unpause:
		get_tree().paused = false

func _on_yes_button_pressed() -> void:
	yes()
	
func _on_no_button_pressed() -> void:
	no()

func _on_cancel_button_pressed() -> void:
	cancel()
