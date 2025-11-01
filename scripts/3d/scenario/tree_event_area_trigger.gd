extends Node3D

class_name TreeEventAreaTrigger

@export var _activated : bool = false
@export var special_tree : Node3D
var _triggered : bool = false

func _ready() -> void:
	special_tree.activated = false
	special_tree.visible = false
	GameManager.special_tree_trigger_activate.connect(_on_activated)
	if (_activated):
		GameManager.special_tree_trigger_activate.emit()

func _on_activated() -> void:
	_activated = true

func _activate_special_tree() -> void:
	print("`	Activating special tree!")
	if special_tree:
		special_tree.activated = true
		special_tree.visible = true

func _on_body_entered(_body: Node3D) -> void:
	if (_triggered or not _activated):
		return

	_triggered = true
	_activate_special_tree()
