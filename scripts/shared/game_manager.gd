extends Node

@onready var Camera : Camera3D = get_parent().get_node("World/CameraParent/Camera3D")
@onready var BuildingGridMap : GridMap= get_parent().get_node_or_null("World/GridMaps/BuildingsGridMap")
@onready var FloorGridMap : GridMap = get_parent().get_node("World/GridMaps/FloorGridMap")
@onready var MainPath : Path3D = get_parent().get_node("World/Paths/MainPath")

signal OnGameManagerReady()

func _ready() -> void:
	OnGameManagerReady.emit()
	print("Game Manager initialized")

func GetCamera() -> Camera3D:
	return Camera

func GetMainPath() -> Path3D:
	return MainPath

func GetFloorGridMap() -> GridMap:
	return FloorGridMap

func GetBuildingGridMap() -> GridMap:
	if BuildingGridMap == null:
		push_error("BuildingGridMap node not found!")
	return BuildingGridMap

func AddEntityToPath(entity: Node3D, initial_progress: float = 0.0, inversed_movement = false, keep_global_transform = true) -> PathFollow3D:
	if MainPath == null:
		push_error("MainPath was not initialized!")
		return null
	
	var path_follower = PathFollow3D.new()

	var script = load("res://scripts/3d/characters/movement/path/path_follower.gd")
	if script:
		path_follower.set_script(script)
	else:
		push_error("Failed to load PathFollower script!")
		return null

	entity.reparent(path_follower, keep_global_transform)
	if not keep_global_transform:
		entity.transform.origin = Vector3.ZERO

	path_follower.progress = initial_progress
	path_follower.inversed_movement = inversed_movement

	MainPath.add_child(path_follower)

	print("Added entity '" + entity.name + "' to path at progress: ", initial_progress)
	return path_follower
