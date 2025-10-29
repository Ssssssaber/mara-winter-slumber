extends Node3D

class_name EvilGhostSpawn

@onready var evil_ghost_scene = load("res://scenes/3d/characters/evil_ghost.tscn")
@export var spawn_point : Node3D
var _spawned : bool = false

func _spawn_evil_ghost() -> void:
	var evil_ghost = evil_ghost_scene.instantiate()

	get_tree().root.add_child(evil_ghost)

	if not spawn_point:
		evil_ghost.global_transform.origin = global_transform.origin
	else:
		evil_ghost.global_transform.origin = spawn_point.global_transform.origin

	GameManager.AddEntityToPathAutoProgress(evil_ghost)


func _on_body_entered(_body: Node3D) -> void:
	if (_spawned):
		return

	_spawned = true
	_spawn_evil_ghost()
