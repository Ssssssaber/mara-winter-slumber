extends Node

signal dialogue_started()
signal dialogue_ended(ended_dialog_json_path : String)
signal battle_started_without_dialogue(battle_id : String)
signal battle_ended(ended_dialog_json_path : String)

signal start_dialogue(dialogue_json_path : String)

# 3d: call start dialogue
func StartDialogue(dialogue_json_path : String) -> void:
	dialogue_started.emit()
	start_dialogue.emit(dialogue_json_path)

func StartBattleWithoutDialogue(battle_id : String) -> void:
	battle_started_without_dialogue.emit(battle_id)

func EndBattle(ended_dialog_json_path : String) -> void:
	battle_ended.emit(ended_dialog_json_path)

# 2d: ends dialogue on "FIN"
func EndDialogue(ended_dialog_json_path : String) -> void:
	dialogue_ended.emit(ended_dialog_json_path)
