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

	var camera_forward = -_camera.global_transform.basis.z.normalized()

	# Cross product: direction_vector × camera_forward
	var cross_product = _direction_vector.cross(camera_forward)

	# Use the Y-component of the cross product to determine left/right
	sprite.flip_h = (cross_product.y > Constants.CAMERA_DOT_MIN_CROSS_RODUCT)
