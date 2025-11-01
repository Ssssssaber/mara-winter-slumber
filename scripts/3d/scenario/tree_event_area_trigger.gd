extends Node3D

class_name TreeEventAreaTrigger

@export var special_tree : Node3D
var _triggered : bool = false

func _ready() -> void:
	special_tree.activated = false
	special_tree.visible = false

func _activate_special_tree() -> void:
	print("`	Activating special tree!")
	if special_tree:
		special_tree.activated = true
		special_tree.visible = true

func _on_body_entered(_body: Node3D) -> void:
	if (_triggered):
		return

	_triggered = true
	_activate_special_tree()
