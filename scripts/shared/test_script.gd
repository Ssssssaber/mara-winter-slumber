extends Node

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			DialogueManager.StartDialogue(Constants.TEST_DIALOG_PATH)
