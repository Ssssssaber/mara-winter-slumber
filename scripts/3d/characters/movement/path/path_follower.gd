extends PathFollow3D

class_name PathFollower

@onready var movement_system: MovementSystem

@export var is_moving: bool = true
@export var inversed_movement: bool = false
var _direction_vector : Vector3 = Vector3.ZERO
var _camera : Camera3D
var _entity : Node3D
var _flipH : FlipHCamera

func init(entity : Node3D) -> void:
	_camera = GameManager.GetCamera()
	_entity = entity
	_flipH = _entity.get_node_or_null("FlipH")

func find_movement_system():
	for child in get_children():
		var ms = child.get_node_or_null("MovementSystem")
		if ms and ms is MovementSystem:
			movement_system = ms
			var pause_manager = get_node_or_null("PauseManager")
			if pause_manager and pause_manager is PauseManager:
				pause_manager._set_node_process(true)
			# var billboard = _entity.get_node_or_null("RotatableNodes")
			# if billboard and billboard is Billboard:
			# 	billboard.set_process(true)
			return
	push_error("MovementSystem not found under any child of PathFollower!")

func _process(delta: float) -> void:
	if not is_moving:
		return

	var tangent_direction = -global_transform.basis.z.normalized()  # Forward along path
	if inversed_movement:
		_direction_vector = -tangent_direction  # Reverse for inverted movement
		progress -= movement_system.effective_speed * delta
	else:
		_direction_vector = tangent_direction   # Forward for normal movement
		progress += movement_system.effective_speed * delta

	_flipH.SetDirection(_direction_vector)
