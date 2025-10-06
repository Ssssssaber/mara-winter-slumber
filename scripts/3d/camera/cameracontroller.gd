extends Camera3D

@export var speed : float = 20

var direction : Vector3 = Vector3.ZERO

func _process(delta: float) -> void:
    direction.x = Input.get_axis("ui_left", "ui_right")
    direction.z = Input.get_axis("ui_down", "ui_up")

    position += direction.normalized() * speed * delta
