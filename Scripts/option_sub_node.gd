extends PanelContainer

@onready var choice_text_box : TextEdit = $VBoxContainer/choice_text
@onready var condition_check_box : CheckBox = $VBoxContainer/condition
@onready var condition_text_box : LineEdit = $VBoxContainer/condition_text
@onready var hide_check_box : CheckBox = $VBoxContainer/hide_if_not_met
@onready var replace_check_box : CheckBox = $VBoxContainer/replace_hidden
@onready var replace_text_box : TextEdit = $VBoxContainer/replacement_text

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	condition_text_box.hide()
	hide_check_box.hide()
	replace_check_box.hide()
	replace_text_box.hide()

func _on_condition_toggled(toggled_on: bool) -> void:
	if toggled_on:
		condition_text_box.show()
		hide_check_box.show()
		if hide_check_box.button_pressed:
			replace_check_box.show()
			if replace_check_box.button_pressed:
				replace_text_box.show()
	else:
		condition_text_box.hide()
		hide_check_box.hide()
		replace_check_box.hide()
		replace_text_box.hide()

func _on_hide_if_not_met_toggled(toggled_on: bool) -> void:
	if toggled_on:
		replace_check_box.show()
		if replace_check_box.button_pressed:
			replace_text_box.show()
	else:
		replace_check_box.hide()
		replace_text_box.hide()

func _on_replace_hidden_toggled(toggled_on: bool) -> void:
	if toggled_on:
		replace_text_box.show()
	else:
		replace_text_box.hide()
