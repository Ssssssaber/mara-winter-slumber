extends PathFollow3D

class_name PathFollower

@onready var movement_system: MovementSystem = find_movement_system()

@export var is_moving: bool = true
@export var inversed_movement: bool = false

func find_movement_system() -> MovementSystem:
	for child in get_children():
		var ms = child.get_node_or_null("MovementSystem")
		if ms and ms is MovementSystem:
			return ms as MovementSystem
	push_error("MovementSystem not found under any child of PathFollower!")
	return null

func _process(delta: float) -> void:
	if inversed_movement:
		progress -= movement_system.effective_speed * delta
	else:
		progress += movement_system.effective_speed * delta
