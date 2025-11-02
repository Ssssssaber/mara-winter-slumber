extends Node

const WORLD_NODE_PATH = "MainScene/World/"

var Camera : Node3D 
var BuildingGridMap : GridMap
var FloorGridMap : GridMap 
var MainPath : Path3D 
var CanvasControl : Node 
var MainMenuRef : Node 

var GhostScene = load("res://scenes/3d/characters/ghosts/Ghost.tscn")
var PauseManagerScene = load("res://scenes/3d/characters/base/pause_manager.tscn")
var WorldScene = load("res://scenes/3d/environment/world.tscn")

var IsCameraInInnerArea : bool = false
var IsGamePause : bool = false
var Initialized : bool = false
var _auto_initilize : bool = false

signal pause_world_entities()
signal unpause_world_entities()

signal OnGameManagerReady()

func Pause() -> void:
	pause_world_entities.emit()

func Unpause() -> void:
	unpause_world_entities.emit()

func _ready() -> void:
	if _auto_initilize:
		Initialize()

func Initialize() -> void:
	Camera = get_parent().get_node(WORLD_NODE_PATH + "CameraParent/CameraController")
	BuildingGridMap = get_parent().get_node_or_null(WORLD_NODE_PATH + "GridMaps/BuildingsGridMap")
	FloorGridMap = get_parent().get_node(WORLD_NODE_PATH + "GridMaps/FloorGridMap")
	MainPath = get_parent().get_node(WORLD_NODE_PATH + "Paths/MainPath")
	CanvasControl = get_parent().get_node(WORLD_NODE_PATH + "CanvasLayer/CanvasController")
	
	Initialized = true

	DialogueManager.dialogue_ended.connect(func unfreeze(_name : String): unpause_world_entities.emit())
	DialogueManager.battle_ended.connect(func unfreeze(_from_dialogue : String): unpause_world_entities.emit())
	DialogueManager.battle_ended_out_of_time.connect(func unfreeze(_from_dialogue : String): unpause_world_entities.emit())

	OnGameManagerReady.emit()
	pass

func are_all_nodes_ready(node: Node) -> bool:
	if not node.is_inside_tree():
		return false
	for child in node.get_children():
		if not child.is_inside_tree() or not are_all_nodes_ready(child):
			return false
	return true

func load_scene_and_wait_for_ready(scene_path: String) -> Node:
	var MyScene = load(scene_path)
	var my_scene_instance = MyScene.instantiate()
	add_child(my_scene_instance)

	await get_tree().process_frame

	while not are_all_nodes_ready(my_scene_instance):
		await get_tree().process_frame

	return my_scene_instance

func StartGame(mainMenu : Node) -> void:
	if (GameManager.Initialized):
		return

	MainMenuRef = mainMenu
	MainMenuRef.visible = false
	var world = WorldScene.instantiate()
	get_tree().root.get_node("MainScene").add_child(world)

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
