@tool
extends EditorPlugin

const MainPanel : PackedScene = preload("res://addons/verse/Scenes/Main.tscn")

var main_panel_instance : Node

var file_menu_options : Array = ["New","Save","Save As","Load","Export"]
var node_menu_options : Array = ["Conversation","Action","Logic",
								"Skill","Start","End"]

signal is_visible

func _enable_plugin() -> void:
	pass
	
func _disable_plugin() -> void:
	pass

func _enter_tree() -> void:
	
	var s = InputEventKey.new()
	s.alt_pressed = false
	s.keycode = KEY_S
	s.physical_keycode = KEY_S
	s.key_label = KEY_S
	s.ctrl_pressed = true
	InputMap.add_action("s")
	InputMap.action_add_event("s",s)
	
	main_panel_instance = MainPanel.instantiate()
	# Add the main panel to the editor's main viewport.
	EditorInterface.get_editor_main_screen().add_child(main_panel_instance)
	# Hide the main panel. Very much required.
	_make_visible(false)
	
	for i : String in file_menu_options:
		main_panel_instance.file_menu.add_item(i)
	for i : String in node_menu_options:
		main_panel_instance.node_menu.add_item(i)
	
func _exit_tree():
	main_panel_instance.file_menu.clear()
	if main_panel_instance:
		main_panel_instance.queue_free()
	InputMap.erase_action("s")

func _has_main_screen():
	return true

func _make_visible(visible):
	if main_panel_instance:
		main_panel_instance.visible = visible
		
func _get_plugin_name():
	return "Verse"

func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("FontVariation", "EditorIcons")
