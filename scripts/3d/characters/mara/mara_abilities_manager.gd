extends Node

@export var speed_buff_modifier : float = 3
@export var speed_buff_duration : float = 3

@export var ignore_ghosts_duration : float = 5

var _speed_buff_cooldown_timer : Timer
var _ignore_ghosts_cooldown_timer : Timer
var _mara : Node3D
var _movement : Node3D
var _canvas_controller : Node
var _speed_buff_sprite : Sprite3D
var _ignore_ghosts_sprite : Sprite3D
var _ghost_debuff_sprite : Sprite3D

func init_with_canvas_controller(canvas_controller : Node) -> void:
	_mara = get_parent()
	_speed_buff_sprite = _mara.get_node("RotatableNodes/Modifiers/SpeedBuffSprite")
	_ignore_ghosts_sprite = _mara.get_node("RotatableNodes/Modifiers/IgnoreGhostsSprite")
	_ghost_debuff_sprite = _mara.get_node("RotatableNodes/Modifiers/GhostDebuffSprite")

	_movement = _mara.get_node("MovementSystem")
	
	_movement.modifier_added.connect(_on_modifier_added)
	_movement.modifier_removed.connect(_on_modifier_removed)

	_canvas_controller = canvas_controller
	_canvas_controller = GameManager.GetCanvasControl()
	_canvas_controller.speed_buff_activated.connect(_on_speed_buff_activated)
	_canvas_controller.ghost_ignore_activated.connect(_on_ingnore_ghost_debuff_activated)

	_speed_buff_cooldown_timer = get_node("SpeedBuffCooldownTimer")
	_ignore_ghosts_cooldown_timer = get_node("SpeedBuffCooldownTimer")
	
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
	if not _speed_buff_cooldown_timer.is_stopped():
		print("speed buff on cooldown: ", _speed_buff_cooldown_timer.time_left)
		return

	_movement.apply_speed_modifier(Constants.MARA_SPEED_BUFF, speed_buff_modifier, speed_buff_duration)
	_speed_buff_cooldown_timer.start()
	
func _on_ingnore_ghost_debuff_activated() -> void:
	if not _ignore_ghosts_cooldown_timer.is_stopped():
		print("speed buff on cooldown: ", _ignore_ghosts_cooldown_timer.time_left)
		return
	_movement.apply_speed_modifier(Constants.MARA_IGNORE_GHOSTS, 1.0, ignore_ghosts_duration)	
	_ignore_ghosts_cooldown_timer.start()

func _on_teleportation_activated() -> void:
	pass
