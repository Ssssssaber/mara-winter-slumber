extends Node

@export var tree_area_trigger : Node3D
@export var evil_ghost_area_trigger : Node3D

signal evil_ghost_trigger_activate()
signal special_tree_trigger_activate()

func _ready() -> void:
	DialogueManager.dialogue_ended.connect(_handle_dialogue_end)

func _handle_dialogue_end(ended_dialog_json_path : String) -> void:
	var dialogue_id = ended_dialog_json_path
	if (dialogue_id == Constants.TEST_DIALOG_PATH):
		print("KEKEKEKE")
	elif (dialogue_id == Constants.CHILDREN_DIALOG_PATH):
		print("children")
	elif (dialogue_id == Constants.WIFE_DIALOG_PATH):
		print("wife")
		evil_ghost_trigger_activate.emit()
	elif (dialogue_id == Constants.TREE_DIALOG_PATH):
		special_tree_trigger_activate.emit()
		print("tree")
