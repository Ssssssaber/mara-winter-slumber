extends Node

class_name SpecialTree

@onready var interaction_area : Area3D = get_node("InteractionArea")
@export var speed_modifier : float = 3
@export var modifier_duration : float = 4.0
@export var activated = false

func _ready() -> void:
	interaction_area.body_entered.connect(_apply_buff)

func _apply_buff(body : Node3D):
	if not activated:
		return

	var movement_system = body.get_node_or_null("MovementSystem")
	if not movement_system:
		return
	
	movement_system.apply_speed_modifier(Constants.SPECIAL_TREE_MOVEMENT_MODIFIER, speed_modifier, modifier_duration)