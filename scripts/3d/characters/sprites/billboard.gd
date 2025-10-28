extends Node3D
class_name Billboard

@onready var camera: Camera3D = GameManager.GetCamera()

func _process(_delta: float) -> void:
	if camera == null:
		return

	# Get the rotation from the camera's global transform
	# In Godot, global_transform.basis contains the rotation and scale
	var camera_basis = camera.global_transform.basis

	# Reset the billboard's rotation to the camera's rotation
	# The Basis.IDENTITY represents a default rotation with no scaling
	global_transform.basis = camera_basis
