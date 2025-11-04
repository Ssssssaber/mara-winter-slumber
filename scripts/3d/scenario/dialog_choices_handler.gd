extends Node

@export var tree_area_trigger : Node3D
@export var evil_ghost_area_trigger : Node3D
@export var game_ui : Control

@onready var end_game_scene : PackedScene = load("res://scenes/3d/ui/end_game.tscn")

signal evil_ghost_trigger_activate()
signal special_tree_trigger_activate()
signal start_last_home()

var battles_out_of_time : int = 0
var battles_count : int = 0
var helped_count : int = 0

func _ready() -> void:
	DialogueManager.dialogue_ended.connect(_handle_dialogue_end)
	DialogueManager.battle_ended.connect(_handle_battle_end)
	DialogueManager.battle_ended_out_of_time.connect(_handle_battle_out_of_time)
	
func _handle_dialogue_end(ended_dialog_json_path : String) -> void:
	helped_count += 1
	var dialogue_id = ended_dialog_json_path
	if (dialogue_id == Constants.TEST_DIALOG_PATH):
		print("KEKEKEKE")
	elif (dialogue_id == Constants.CHILDREN_DIALOG_PATH):
		print("children")
	elif (dialogue_id == Constants.WIFE_DIALOG_PATH):
		evil_ghost_trigger_activate.emit()
	elif (dialogue_id == Constants.TREE_DIALOG_PATH):
		special_tree_trigger_activate.emit()
		start_last_home.emit()

func _handle_battle_out_of_time(ended_dialog_json_path : String) -> void:
	battles_out_of_time += 1
	_handle_battle_end(ended_dialog_json_path)

func _handle_battle_end(ended_dialog_json_path : String) -> void:
	battles_count += 1
	var dialogue_id = ended_dialog_json_path
	if (dialogue_id == Constants.TREE_DIALOG_PATH):
		start_last_home.emit()
	if (dialogue_id == Constants.LAST_BATTLE_ID):
		game_ui.visible = false
		# GameManager.call_deferred("Pause")
		var end_game_current = end_game_scene.instantiate()
		get_tree().root.get_node("MainScene").add_child(end_game_current)
		choose_ending(end_game_current)

func choose_ending(end_game_screen : Control) -> void:
	if helped_count == 3:
		end_game_screen.set_ending_text("Богиня эмпатии", "Выполнили последние желания всех жителей")
	elif battles_out_of_time == 5:
		end_game_screen.set_ending_text("Отпуск близко", "Меньше жителей - меньше работы")
	elif battles_count == 5:
		end_game_screen.set_ending_text("Холодная тюрьма", "Никогда не исполняли последние желания")
	else:
		end_game_screen.set_ending_text("Обычный рабочий день", "Все как обычно")
