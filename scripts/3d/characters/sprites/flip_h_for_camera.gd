extends Node

class_name FlipHCamera

@onready var sprite : AnimatedSprite3D = get_parent().get_node("RotatableNodes/AnimatedSprite3D")
var _direction_vector := Vector3.ZERO

var _camera : Camera3D

func SetDirection(dir : Vector3) -> void:
	_direction_vector = dir

func _process(_delta: float) -> void:
	if not _camera:
		_camera = GameManager.GetCamera()
		return

	# Use camera's forward direction (where it's facing) instead of position vector
	# In Godot, camera forward is -global_transform.basis.z (negative Z points forward for cameras)
	var camera_forward = -_camera.global_transform.basis.z.normalized()

	# Dot product: >0 means moving towards camera's view direction, <0 means away
	var dot_product = _direction_vector.dot(camera_forward)

	# Flip if dot product indicates movement away from camera's view (adjust threshold as needed)
	sprite.flip_h = (dot_product < Constants.CAMERA_DOT_MIN_DOT_RODUCT)
