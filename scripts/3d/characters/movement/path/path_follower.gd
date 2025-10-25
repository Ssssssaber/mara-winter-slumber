extends PathFollow3D

class_name PathFollower

@onready var movement_system : MovementSystem = get_node("BaseCharacter/MovementSystem") as MovementSystem

@export var is_moving : bool = true;

func _process(delta: float) -> void:
	progress += movement_system.base_speed * delta
