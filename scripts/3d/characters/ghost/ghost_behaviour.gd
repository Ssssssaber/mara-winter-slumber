extends Sprite3DCharacterBody

class_name GhostBehaviour

@export var slow_modifier : float = 0.5
@export var slow_duration : float = Constants.INDEFINITE_DURATION

@onready var interaction_area : Area3D = get_node("InteractionArea")
@onready var vanish_timer : Timer = get_node("VanishTimer")

func _ready() -> void:
	interaction_area.body_entered.connect(_on_interaction_area_entered)
	interaction_area.body_exited.connect(_on_interaction_area_exited)
	vanish_timer.timeout.connect(vanish)

func _on_interaction_area_entered(body : Node3D) -> void:
	var movement_system = body.get_node_or_null("MovementSystem")
	if not movement_system:
		return
	
	movement_system.apply_speed_modifier(Constants.GHOST_MOVEMENT_MODIFIER, slow_modifier, slow_duration)

func _on_interaction_area_exited(body : Node3D) -> void:
	if slow_duration != Constants.INDEFINITE_DURATION:
		return

	var movement_system = body.get_node_or_null("MovementSystem")
	if not movement_system:
		return
	
	movement_system.remove_modifier(Constants.GHOST_MOVEMENT_MODIFIER)

func vanish() -> void:
	var parent_node = get_parent()
	if parent_node is PathFollower:
		parent_node.queue_free()
	else:
		queue_free()