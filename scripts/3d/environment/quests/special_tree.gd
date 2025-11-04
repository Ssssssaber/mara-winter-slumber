extends Node

class_name SpecialTree

@onready var interaction_area : Area3D = get_node("InteractionArea")
@export var speed_modifier : float = 1.5
@export var modifier_duration : float = 4.0
@export var apply_buff_timer : Timer

@export var activated : bool = false

func _ready() -> void:
	if activated:
		apply_buff_timer.start()
	else:
		apply_buff_timer.stop()
	#interaction_area.body_entered.connect(_apply_buff)
	#interaction_area.body_exited.connect(_apply_buff)
	apply_buff_timer.timeout.connect(_buff_entities_in_area)

func set_activate(value : bool) -> void:
	activated = value
	if activated:
		apply_buff_timer.start()
	else:
		apply_buff_timer.stop()

func _buff_entities_in_area() -> void:
	var bodies = interaction_area.get_overlapping_bodies()
	for body in bodies:
		_apply_buff(body)

func _apply_buff(body : Node3D):
	if not activated:
		return

	var movement_system = body.get_node_or_null("MovementSystem")
	if not movement_system:
		return
	movement_system.apply_speed_modifier(Constants.SPECIAL_TREE_MOVEMENT_MODIFIER, speed_modifier, modifier_duration)
