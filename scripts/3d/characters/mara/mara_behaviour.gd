extends Sprite3DCharacterBody

class_name MaraBehaviour

@onready var interaction_area : Area3D = get_node("InteractionArea")

var movement : Node3D
var _path_follower : PathFollow3D
var abilities_manager : Node
var _canvas_controller : Node

func _init() -> void:
	GameManager.OnGameManagerReady.connect(_connect_canvas_signals)

func _connect_canvas_signals() -> void:
	_canvas_controller = GameManager.GetCanvasControl()
	_canvas_controller.change_direction.connect(_change_movement_direction)
	
	if not abilities_manager:
		abilities_manager = get_node("AbilitiesManager")
	abilities_manager.init_with_canvas_controller(_canvas_controller)

func _ready() -> void:
	interaction_area.body_entered.connect(_on_interaction_area_entered)
	movement = get_node_or_null("MovementSystem")

func set_path_follower(path_follower : PathFollow3D) -> void:
	print("path follower set")
	_path_follower = path_follower

	_animated_sprite.play("walk")
	set_process_input(true)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("change_direction"):
		_change_movement_direction()

func _change_movement_direction() -> void:
	if not _path_follower:
		return
	_path_follower.inversed_movement = not _path_follower.inversed_movement

func _on_interaction_area_entered(body : Node3D) -> void:
	var interactable = body.get_node_or_null("Interactable")
	if not interactable:
		return
	
	interactable.interact(self)
