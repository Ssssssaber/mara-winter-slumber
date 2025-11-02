extends Node

class_name PauseManager

func _ready() -> void:
	GameManager.pause_world_entities.connect(_on_dialog_started)
	GameManager.unpause_world_entities.connect(_on_dialog_ended)

	_set_node_process(GameManager.IsGamePause)

func _on_dialog_started() -> void:
	_set_node_process(false)

func _on_dialog_ended() -> void:
	_set_node_process(true)

func _set_node_process(value: bool) -> void:
	var parent_node = get_parent()
	parent_node.set_process(value)
	parent_node.set_physics_process(value)
	parent_node.set_process_input(value)

	var children = get_all_children(parent_node)
	for child in children:
		if child is AnimatedSprite3D:
			var animated_sprite = child as AnimatedSprite3D
			if not value:
				animated_sprite.stop()
			else:
				animated_sprite.play()
		if child is AudioStreamPlayer3D:
			var audio_stream = child as AudioStreamPlayer3D
			if not value:
				audio_stream.stop()
			else:
				audio_stream.play()

		child.set_process(value)
		child.set_physics_process(value)
		child.set_process_input(value)

func get_all_children(node: Node, children_list: Array = []) -> Array:
	for child in node.get_children():
		children_list.append(child)
		get_all_children(child, children_list)
	return children_list
