extends PathFollow3D

class_name PathFollower

@onready var movement_system: MovementSystem

@export var is_moving: bool = true
@export var inversed_movement: bool = false
var _direction_vector : Vector3 = Vector3.ZERO
var _camera : Camera3D
var _entity : Node3D

func init(entity : Node3D) -> void:
	_camera = GameManager.GetCamera()
	_entity = entity

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

	var tangent_direction = -global_transform.basis.z.normalized()  # Forward along path
	if inversed_movement:
		_direction_vector = -tangent_direction  # Reverse for inverted movement
		progress -= movement_system.effective_speed * delta
	else:
		_direction_vector = tangent_direction   # Forward for normal movement
		progress += movement_system.effective_speed * delta

	# Use camera's forward direction (where it's facing) instead of position vector
	# In Godot, camera forward is -global_transform.basis.z (negative Z points forward for cameras)
	var camera_forward = -_camera.global_transform.basis.z.normalized()

	# Dot product: >0 means moving towards camera's view direction, <0 means away
	var dot_product = _direction_vector.dot(camera_forward)

	# Flip if dot product indicates movement away from camera's view (adjust threshold as needed)
	_entity.set_flip(dot_product < Constants.CAMERA_DOT_MIN_DOT_RODUCT)
