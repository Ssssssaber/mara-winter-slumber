extends Node

signal dialogue_started()
signal dialogue_ended(ended_dialog_json_path : String)
signal battle_started_without_dialogue()
signal battle_ended()

signal start_dialogue(dialogue_json_path : String)

# 3d: call start dialogue
func StartDialogue(dialogue_json_path : String) -> void:
	dialogue_started.emit()
	start_dialogue.emit(dialogue_json_path)

func StartBattleWithoutDialogue() -> void:
	battle_started_without_dialogue.emit()

func EndBattle() -> void:
	battle_ended.emit()

# 2d: ends dialogue on "FIN"
func EndDialogue(ended_dialog_json_path : String) -> void:
	dialogue_ended.emit(ended_dialog_json_path)
	print("диалогу пизда")
