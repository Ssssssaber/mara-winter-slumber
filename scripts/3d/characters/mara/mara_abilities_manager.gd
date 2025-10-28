extends Node

@export var speed_buff_modifier : float = 1.5
@export var speed_buff_duration : float = 1.5

@export var ignore_ghosts_duration : float = 5.0

var _mara : Node3D
var _canvas_controller : Node

func init_with_canvas_controller(canvas_controller : Node) -> void:
	_mara = get_parent()
	_canvas_controller = canvas_controller
	_canvas_controller = GameManager.GetCanvasControl()
	_canvas_controller.speed_buff_activated.connect(_on_speed_buff_activated)
	_canvas_controller.ghost_ignore_activated.connect(_on_ingnore_ghost_debuff_activated)

func _on_speed_buff_activated() -> void:
	_mara.movement.apply_speed_modifier(Constants.MARA_SPEED_BUFF, speed_buff_modifier, speed_buff_duration)
	
func _on_ingnore_ghost_debuff_activated() -> void:
	_mara.movement.apply_speed_modifier(Constants.MARA_IGNORE_GHOSTS, 1.0, ignore_ghosts_duration)	
	
func _on_teleportation_activated() -> void:
	pass
