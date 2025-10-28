extends Node

@export var speed_buff_modifier : float = 1.5
@export var speed_buff_duration : float = 1.5

@export var ignore_ghosts_duration : float = 5.0

var _mara : Node3D
var _movement : Node3D
var _canvas_controller : Node
var _speed_buff_sprite : Sprite3D
var _ignore_ghosts_sprite : Sprite3D
var _ghost_debuff_sprite : Sprite3D

func init_with_canvas_controller(canvas_controller : Node) -> void:
	_mara = get_parent()
	_speed_buff_sprite = _mara.get_node("Modifiers/SpeedBuffSprite")
	_ignore_ghosts_sprite = _mara.get_node("Modifiers/IgnoreGhostsSprite")
	_ghost_debuff_sprite = _mara.get_node("Modifiers/GhostDebuffSprite")

	_movement = _mara.get_node("MovementSystem")
	
	_movement.modifier_added.connect(_on_modifier_added)
	_movement.modifier_removed.connect(_on_modifier_removed)

	_canvas_controller = canvas_controller
	_canvas_controller = GameManager.GetCanvasControl()
	_canvas_controller.speed_buff_activated.connect(_on_speed_buff_activated)
	_canvas_controller.ghost_ignore_activated.connect(_on_ingnore_ghost_debuff_activated)

func _on_modifier_added(modifier_name : String) -> void:
	if modifier_name == Constants.MARA_SPEED_BUFF:
		_speed_buff_sprite.visible = true
	elif modifier_name == Constants.MARA_IGNORE_GHOSTS:
		_ignore_ghosts_sprite.visible = true
	elif modifier_name == Constants.GHOST_MOVEMENT_MODIFIER:
		_ghost_debuff_sprite.visible = true

func _on_modifier_removed(modifier_name : String) -> void:
	if modifier_name == Constants.MARA_SPEED_BUFF:
		_speed_buff_sprite.visible = false
	elif modifier_name == Constants.MARA_IGNORE_GHOSTS:
		_ignore_ghosts_sprite.visible = false
	elif modifier_name == Constants.GHOST_MOVEMENT_MODIFIER:
		_ghost_debuff_sprite.visible = false

func _on_speed_buff_activated() -> void:
	_movement.apply_speed_modifier(Constants.MARA_SPEED_BUFF, speed_buff_modifier, speed_buff_duration)
	
func _on_ingnore_ghost_debuff_activated() -> void:
	_movement.apply_speed_modifier(Constants.MARA_IGNORE_GHOSTS, 1.0, ignore_ghosts_duration)	
	
func _on_teleportation_activated() -> void:
	pass
