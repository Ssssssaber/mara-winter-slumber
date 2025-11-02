extends Node

signal one_line_dialogue_started(line : String)
signal one_line_dialogue_ended()

signal battle_ended_out_of_time(ended_dialog_json_path : String)

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

func EndBattleOutOfTime(ended_dialog_json_path : String) -> void:
	battle_ended_out_of_time.emit(ended_dialog_json_path)

func StartOneLineDialogue(line : String) -> void:
	one_line_dialogue_started.emit(line)

func EndOneLineDialogue(line : String) -> void:
	one_line_dialogue_ended.emit(line)