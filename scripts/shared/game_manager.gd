extends Node

@onready var Camera : Camera3D = get_parent().get_node("World/CameraParent/Camera3D")
@onready var FloorGridMap : GridMap = get_parent().get_node("World/GridMaps/FloorGridMap")
@onready var MainPath : Path3D = get_parent().get_node("World/Paths/MainPath")

func GetCamera() -> Camera3D:
	return Camera

func GetMainPath() -> Path3D:
	return MainPath

func GetFloorGridMap() -> GridMap:
	return FloorGridMap
