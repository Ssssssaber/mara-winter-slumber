extends Node

func _ready() -> void:
	GameManager.pause_world_entities.connect(_on_dialog_started)
	GameManager.unpause_world_entities.connect(_on_dialog_ended)

	_set_node_process(GameManager.IsGamePause)

func _on_dialog_started() -> void:
	_set_node_process(false)

func _on_dialog_ended() -> void:
	_set_node_process(true)

func _set_node_process(value : bool) -> void:

	var parent_node = get_parent() 

	parent_node.set_process(value)
	parent_node.set_physics_process(value)
	parent_node.set_process_input(value)
	
	for child in parent_node.get_children():
		child.set_process(value)
		child.set_physics_process(value)
		child.set_process_input(value)