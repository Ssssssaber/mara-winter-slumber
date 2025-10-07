extends Node

@onready var Camera : Camera3D = get_parent().get_node("World/Camera3D")
@onready var MainPath : Path3D = get_parent().get_node("World/GridMap/MainPath")

func GetCamera() -> Camera3D:
    return Camera

func GetMainPath() -> Path3D:
    return MainPath
