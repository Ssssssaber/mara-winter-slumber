extends PathFollow3D

class_name PathFollower

@onready var movement_system: MovementSystem

@export var is_moving: bool = true
@export var inversed_movement: bool = false

func find_movement_system():
	for child in get_children():
		var ms = child.get_node_or_null("MovementSystem")
		if ms and ms is MovementSystem:
			movement_system = ms
			set_process(true)
			return
	push_error("MovementSystem not found under any child of PathFollower!")

func _process(delta: float) -> void:
	if not is_moving:
		return

	if inversed_movement:
		progress -= movement_system.effective_speed * delta
	else:
		progress += movement_system.effective_speed * delta
