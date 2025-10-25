extends Node

class_name MaraBehaviour

@onready var interaction_area : Area3D = get_node("InteractionArea")

var movement : Node3D;

func _ready() -> void:
	interaction_area.body_entered.connect(_on_interaction_area_entered)
	movement = get_node_or_null("MovementSystem")

func _process(_delta: float) -> void:
	print(movement.effective_speed)

func _on_interaction_area_entered(body : Node3D) -> void:
	var interactable = body.get_node_or_null("Interactable")
	if not interactable:
		return
	
	interactable.interact(self)
