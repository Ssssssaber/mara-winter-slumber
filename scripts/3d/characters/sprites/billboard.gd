extends AnimatedSprite3D

@export var look_at_x: bool = true
@export var look_at_y: bool = true
@export var look_at_z: bool = true

@export var distance_scaling : bool = true

@export var max_scale: float = 3.0
@export var min_scale: float = 1.0
@export var min_distance: float = 20.0
@export var max_distance: float = 150.0

@onready var camera: Camera3D = GameManager.GetCamera()

func _process(_delta: float) -> void:
	if camera == null:
		return

	look_at(camera.global_transform.origin, Vector3.UP)  # Faces towards camera, keeps Y-up

	if not look_at_x:
		rotation.x = 0.0
	if not look_at_y:
		rotation.y = 0.0
	if not look_at_z:
		rotation.z = 0.0

	if not distance_scaling:
		scale = Vector3.ONE
		return

	var distance = global_transform.origin.distance_to(camera.global_transform.origin)
	distance = clamp(distance, min_distance, max_distance)
	var scale_factor = lerpf(min_scale, max_scale, (distance - min_distance) / (max_distance - min_distance))
	scale = Vector3(scale_factor, scale_factor, scale_factor)


