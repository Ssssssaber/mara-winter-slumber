extends Node

var _canvas_controller : Node

func init_with_canvas_controller(canvas_controller : Node) -> void:
	_canvas_controller = canvas_controller
	_canvas_controller = GameManager.GetCanvasControl()
	_canvas_controller.speed_buff_activated.connect(_on_speed_buff_activated)
	_canvas_controller.ghost_ignore_activated.connect(_on_ingnore_ghost_debuff_activated)

func _on_speed_buff_activated() -> void:
	print("speed buff")
	pass
	
func _on_ingnore_ghost_debuff_activated() -> void:
	print("ignore ghosts")
	pass
	
func _on_teleportation_activated() -> void:
	pass
