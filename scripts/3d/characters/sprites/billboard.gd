extends AnimatedSprite3D

@onready var camera: Camera3D = GameManager.GetCamera()

func _process(_delta):
    if camera == null:
        return
    var to_camera = (camera.global_transform.origin - global_transform.origin).normalized()
    rotation.y = atan2(to_camera.x, to_camera.z)
