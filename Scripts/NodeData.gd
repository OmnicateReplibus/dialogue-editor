extends Resource

class_name NodeData

# All the information about each node that's saved

# Universals
@export var type: StringName
@export var name: StringName
@export var title: String
@export var position_offset: Vector2

# ConversationNode
@export var speaker: String
@export var inherit_speaker: bool
@export var speaker_text: String
@export var choices: Array

# ActionNode
@export var action_string: String
