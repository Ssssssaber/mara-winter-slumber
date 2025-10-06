extends AnimatedSprite3D

@export var camera_node_path: NodePath

var camera: Camera3D

func _ready():
    if camera_node_path != null:
        camera = get_node(camera_node_path)
    else:
        camera = get_viewport().get_camera_3d()

func _process(_delta):
    if camera == null:
        return
    var to_camera = (camera.global_transform.origin - global_transform.origin).normalized()
    rotation.y = atan2(to_camera.x, to_camera.z)
