extends Node

@onready var Camera : Node3D = get_parent().get_node("World/CameraParent/CameraController")
@onready var BuildingGridMap : GridMap= get_parent().get_node_or_null("World/GridMaps/BuildingsGridMap")
@onready var FloorGridMap : GridMap = get_parent().get_node("World/GridMaps/FloorGridMap")
@onready var MainPath : Path3D = get_parent().get_node("World/Paths/MainPath")
@onready var CanvasControl : Node = get_parent().get_node("World/CanvasLayer/CanvasController")
@onready var GhostScene = load("res://scenes/3d/characters/ghosts/Ghost.tscn")
@onready var PauseManagerScene = load("res://scenes/3d/characters/base/pause_manager.tscn")

var IsCameraInInnerArea : bool = false
var IsGamePause : bool = false

signal pause_world_entities()
signal unpause_world_entities()

signal OnGameManagerReady()
func _ready() -> void:
	OnGameManagerReady.emit()
	print("Game Manager initialized")

func GetCamera() -> Camera3D:
	return Camera

func SetCameraTarget(target : Node3D) -> void:
	Camera.set_target(target) 

func GetMainPath() -> Path3D:
	return MainPath

func GetCanvasControl() -> Node:
	return CanvasControl

func GetFloorGridMap() -> GridMap:
	return FloorGridMap

func GetBuildingGridMap() -> GridMap:
	if BuildingGridMap == null:
		push_error("BuildingGridMap node not found!")
	return BuildingGridMap

func GetMainPathProgress(entity: Node3D) -> float:
	if MainPath == null or MainPath.curve == null:
		push_error("MainPath or its curve is not initialized!")
		return 0.0
	
	var curve = MainPath.curve
	var entity_global_pos = entity.global_transform.origin
	# Transform global position to Path3D's local space
	var entity_local_pos = MainPath.to_local(entity_global_pos)
	
	var offset = curve.get_closest_offset(entity_local_pos)
	var total_length = curve.get_baked_length()
	
	if total_length <= 0.0:
		push_error("Total length = 0")
		return 0.0
	
	var progress = offset / total_length
	print(entity.name, "progress:", progress)
	return clamp(progress, 0.0, 1.0)  # Ensure it's between 0 and 1

func SpawnGhost() -> Node3D:
	var ghost = GhostScene.instantiate()
	return ghost

func AddEntityToPathAutoProgress(entity : Node3D, inversed_movement = false, keep_global_transform = false):
	AddEntityToPath(entity, GetMainPathProgress(entity), inversed_movement, keep_global_transform);

func AddEntityToPath(entity: Node3D, initial_progress: float = 0.0, inversed_movement = false, keep_global_transform = false) -> PathFollow3D:
	if MainPath == null:
		push_error("MainPath was not initialized!")
		return null
	
	var path_follower = PathFollow3D.new()


	MainPath.add_child(path_follower)

	var current_parent = entity.get_parent()
	# Remove the child node from its current parent
	if current_parent:
		current_parent.remove_child(entity)
	path_follower.add_child(entity)

	var PathFollowerScript = load("res://scripts/3d/characters/movement/path/path_follower.gd")
	if PathFollowerScript:
		path_follower.set_script(PathFollowerScript)
	else:
		push_error("Failed to load PathFollower script!")
		return null
	
	if not keep_global_transform:
		entity.transform.origin = Vector3.ZERO

	path_follower.progress_ratio = initial_progress
	path_follower.inversed_movement = inversed_movement

	path_follower.add_child(PauseManagerScene.instantiate())

	path_follower.init(entity)
	path_follower.call_deferred("find_movement_system")

	if entity.has_method("set_path_follower"):
		entity.set_path_follower(path_follower)

	print("Added entity '" + entity.name + "' to path at progress: ", initial_progress)
	return path_follower
