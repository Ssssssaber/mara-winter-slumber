extends Node3D

class_name EvilGhostSpawn

@onready var evil_ghost_scene = load("res://scenes/3d/characters/ghosts/evil_ghost.tscn")
@export var _activated : bool = false
@export var spawn_point : Node3D
var _spawned : bool = false

func _ready() -> void:
	GameManager.evil_ghost_trigger_activate.connect(_on_activated)
	if (_activated):
		GameManager.evil_ghost_trigger_activate.emit()

func _on_activated() -> void:
	_activated = true

func _spawn_evil_ghost() -> void:
	var evil_ghost = evil_ghost_scene.instantiate()

	get_tree().root.add_child(evil_ghost)

	if not spawn_point:
		evil_ghost.global_transform.origin = global_transform.origin
	else:
		evil_ghost.global_transform.origin = spawn_point.global_transform.origin

	GameManager.AddEntityToPathAutoProgress(evil_ghost, true)


func _on_body_entered(_body: Node3D) -> void:
	if (_spawned or not _activated):
		return

	_spawned = true
	_spawn_evil_ghost()
