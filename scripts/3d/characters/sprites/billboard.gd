extends AnimatedSprite3D

@export var look_at_x: bool = false  # Keep for optional pitch adjustment
@export var look_at_y: bool = true   # Yaw (horizontal facing)
@export var look_at_z: bool = false  # Roll (usually off)

@export var max_scale: float = 10.0
@export var min_scale: float = 0.5
@export var min_distance: float = 20.0
@export var max_distance: float = 150.0

@onready var camera: Camera3D = GameManager.GetCamera()

func _process(_delta: float) -> void:
    if camera == null:
        return

    # Scaling logic
    var distance = global_transform.origin.distance_to(camera.global_transform.origin)
    distance = clamp(distance, min_distance, max_distance)
    var scale_factor = lerpf(min_scale, max_scale, (distance - min_distance) / (max_distance - min_distance))
    scale = Vector3(scale_factor, scale_factor, scale_factor)

    look_at(camera.global_transform.origin, Vector3.UP)  # Faces towards camera, keeps Y-up

    if not look_at_x:
        rotation.x = 0.0
    if not look_at_y:
        rotation.y = 0.0
    if not look_at_z:
        rotation.z = 0.0
