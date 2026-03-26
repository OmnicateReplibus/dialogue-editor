@tool
extends Resource

class_name NodeData

# All the information about each node that's saved

# Universals
@export var name : StringName
@export var title : String
@export var position_offset : Vector2

# ConversationNode
@export var speaker : String
@export var inherit_speaker : bool
@export var speaker_text : String
@export var has_choices : bool = false
@export var choices : Array[Dictionary]

# ActionNode
@export var action_string : String

# LogicNode
@export var logic_string : String
@export var editable : bool

# SkillNode

@export var skill_class_name : String
@export var skill_name : String
@export var threshold : int
@export var success_text : String
@export var failure_text : String
