extends Node

signal dialogue_started()
signal dialogue_ended()

signal start_dialogue(dialogue_json_path : String)

# 3d: call start dialogue
func StartDialogue(dialogue_json_path : String) -> void:
	dialogue_started.emit()
	start_dialogue.emit(dialogue_json_path)

# 2d: ends dialogue on "FIN"
func EndDialogue() -> void:
	dialogue_ended.emit()
	print("диалогу пизда")
