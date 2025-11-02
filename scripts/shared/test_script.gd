extends Node

@export var init_on_input : bool = false

func _unhandled_input(event):
	if not init_on_input:
		return
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_F1:
			DialogueManager.StartOneLineDialogue(["f1", "f2", "f3"])
